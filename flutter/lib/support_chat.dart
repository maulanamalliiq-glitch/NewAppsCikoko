import 'adaptive_poll.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'premium_ui.dart';
import 'chat_receipt_indicator.dart';

class SupportChatPage extends StatefulWidget {
  final CikokoApi api;
  final String? residentId;
  final String residentName;
  const SupportChatPage({super.key,required this.api,this.residentId,this.residentName='Warga'});
  @override State<SupportChatPage> createState()=>_SupportChatState();
}

class _SupportChatState extends State<SupportChatPage> with WidgetsBindingObserver {
  final message=TextEditingController();
  final scroll=ScrollController();
  List<Map<String,dynamic>> messages=[];
  AdaptivePoller? timer;
  bool sending=false,loading=true,fetching=false,hasOlder=false;
  bool refreshAfterInFlight=false;
  String? error;
  bool get admin=>widget.residentId!=null;
  String get ownSender=>admin?'admin':'warga';
  @override void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    startPolling();
  }
  void startPolling(){
    timer?.cancel();
    timer=AdaptivePoller(()async{
      final before=messages.map((e)=>'${e['id']}:${e['delivery_status']}').join(',');
      await refresh();
      if(error!=null)throw StateError('offline');
      return before!=messages.map((e)=>'${e['id']}:${e['delivery_status']}').join(',');
    })..start(immediate:false);
  }
  @override void didChangeAppLifecycleState(AppLifecycleState state){
    if(state==AppLifecycleState.resumed){startPolling();refresh();}
    else{timer?.cancel();}
  }
  @override void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();scroll.dispose();message.dispose();super.dispose();
  }
  static int _order(Map<String,dynamic> row)=>
    int.tryParse('${row['id']??''}')??0x7FFFFFFFFFFFFFFF;
  void _sort(){
    messages.sort((a,b)=>_order(a).compareTo(_order(b)));
  }
  void _scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!mounted||!scroll.hasClients)return;
      scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }
  Future<void> refresh({bool older=false,bool forceLatest=false})async{
    if(fetching){
      // Never discard the post-send refresh while an older GET is in flight.
      if(!older)refreshAfterInFlight=true;
      return;
    }
    fetching=true;
    try{
      final serverRows=messages.where((r)=>int.tryParse('${r['id']}')!=null).toList();
      // A successful send must request the newest page, rather than
      // reusing the cursor from before the message was sent.
      final query=<String,String>{
        if(admin)'user_id':widget.residentId!,
        if(!forceLatest && serverRows.isNotEmpty)(older?'before_id':'after_id'):
          '${older?serverRows.first['id']:serverRows.last['id']}',
      };
      final result=await widget.api.callWithParams(admin?'support_admin_thread':'chat',query);
      if(!mounted)return;
      final received=List<Map<String,dynamic>>.from(
        (result['messages'] as List? ?? const []).map((e)=>Map<String,dynamic>.from(e as Map)));
      final updates=Map<String,dynamic>.from(result['receipt_updates'] as Map? ?? {});
      final wasEmpty=messages.isEmpty;
      final shouldScroll=!older&&(wasEmpty||
        (scroll.hasClients && scroll.position.pixels>=scroll.position.maxScrollExtent-90));
      setState((){
        final byId=<String,Map<String,dynamic>>{
          for(final row in messages)'${row['id']}':row
        };
        for(final row in received){
          // Reconcile messages confirmed by an older backend without a POST ID.
          // Do not discard an unmatched outgoing local message.
          final serverId=int.tryParse('${row['id']}')??0;
          String? matchingLocal;
          for(final entry in byId.entries){
            final old=entry.value;
            if(!entry.key.startsWith('pending-')||
              old['sender']!=row['sender']||old['message']!=row['message'])continue;
            if(serverId>(int.tryParse('${old['after_id']??0}')??0)){
              matchingLocal=entry.key;
              break;
            }
          }
          if(matchingLocal!=null)byId.remove(matchingLocal);
          final existing=byId['${row['id']}'];
          byId['${row['id']}']={
            if(existing!=null)...existing,
            ...row,
          };
        }
        for(final entry in updates.entries){
          final row=byId[entry.key];
          if(row!=null)row['delivery_status']=entry.value;
        }
        messages=byId.values.toList();_sort();
        if(older||forceLatest||serverRows.isEmpty)hasOlder=result['has_more']==true;
        error=null;
      });
      if(shouldScroll) _scrollToBottom();
    }catch(e){
      if(mounted)setState(()=>error=cikokoFormalMessage(e));
    }finally{
      fetching=false;
      if(mounted)setState(()=>loading=false);
      if(refreshAfterInFlight && mounted){
        refreshAfterInFlight=false;
        await refresh(forceLatest:true);
      }
    }
  }
  Future<void> send()async{
    final text=message.text.trim();
    if(sending||text.isEmpty)return;
    final key='pending-${DateTime.now().microsecondsSinceEpoch}';
    final newestServerId=messages
      .map((r)=>int.tryParse('${r['id']}')??0)
      .fold<int>(0,(maxId,id)=>id>maxId?id:maxId);
    message.clear();
    setState((){
      sending=true;
      messages.add({'id':key,'sender':ownSender,'message':text,
        'created_at':'Sekarang','delivery_status':'pending','after_id':newestServerId});
      _sort();
    });
    _scrollToBottom();
    try{
      final result=await widget.api.call(admin?'chat_reply':'chat_send',
        body:{'message':text,if(admin)'user_id':widget.residentId});
      if(!mounted)return;
      setState((){
        final id=int.tryParse('${result['id']??''}');
        if(id!=null&&id>0){
          messages.removeWhere((row)=>row['id']==key);
          final fresh={'id':id,'sender':ownSender,'message':text,
            'created_at':result['created_at']??'', 'delivery_status':'sent'};
          final index=messages.indexWhere((r)=>r['id']==id||'${r['id']}'=='$id');
          if(index>=0)messages[index]={...messages[index],...fresh};
          else messages.add(fresh);
        }else{
          // Legacy backend confirms the POST without an ID.
          // Keep the SAME local bubble instead of deleting/recreating it.
          final index=messages.indexWhere((r)=>r['id']==key);
          if(index>=0)messages[index]['delivery_status']='sent';
        }
        _sort();
      });
      _scrollToBottom();
      await refresh(forceLatest:true);
    }catch(e){
      if(mounted){
        setState((){
          final index=messages.indexWhere((row)=>row['id']==key);
          if(index>=0)messages[index]['delivery_status']='failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:Text(cikokoFormalMessage(e))));
      }
    }finally{
      if(mounted)setState(()=>sending=false);
    }
  }
  @override Widget build(BuildContext context){
    final scheme=Theme.of(context).colorScheme;
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(12,12,12,8),
        child:CikokoPremiumHeader(title:admin?'Percakapan Warga':'Hubungi Admin',
          subtitle:admin?widget.residentName:'Sampaikan pertanyaan atau kebutuhan bantuan Anda.',
          icon:Icons.support_agent_outlined)),
      if(error!=null)Padding(padding:const EdgeInsets.symmetric(horizontal:14),
        child:Row(children:[
          Expanded(child:Text(error!)),
          TextButton(onPressed:()=>refresh(),child:const Text('Coba Kembali'))
        ])),
      Expanded(child:loading&&messages.isEmpty?const Center(child:CircularProgressIndicator()):
        RefreshIndicator(onRefresh:()=>refresh(),child:ListView(
          controller:scroll,padding:const EdgeInsets.all(14),
          physics:const AlwaysScrollableScrollPhysics(),
          children:[
            if(hasOlder)TextButton(onPressed:fetching?null:()=>refresh(older:true),
              child:const Text('Muat Pesan Sebelumnya')),
            if(messages.isEmpty&&error==null)const CikokoEmptyState(
              icon:Icons.chat_bubble_outline_rounded,title:'Belum ada pesan',
              subtitle:'Mulai percakapan dengan mengirim pesan.'),
            for(final row in messages)
              Align(alignment:row['sender']==ownSender?
                  Alignment.centerRight:Alignment.centerLeft,
                child:Container(
                  constraints:const BoxConstraints(maxWidth:340),
                  margin:const EdgeInsets.only(bottom:10),
                  padding:const EdgeInsets.all(13),
                  decoration:BoxDecoration(
                    color:row['sender']==ownSender?scheme.primaryContainer:
                      scheme.surfaceContainerHighest,
                    borderRadius:BorderRadius.circular(16)),
                  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text('${row['message']??''}',style:TextStyle(color:scheme.onSurface)),
                    const SizedBox(height:5),
                    Row(mainAxisSize:MainAxisSize.min,children:[
                      Flexible(child:Text('${row['created_at']??''}',
                        style:Theme.of(context).textTheme.labelSmall)),
                      if(row['sender']==ownSender)...[
                        const SizedBox(width:8),
                        CikokoChatReceiptIndicator(status:
                          '${row['delivery_status']??'sent'}'),
                      ],
                    ]),
                    if(row['delivery_status']=='failed')
                      TextButton(
                        onPressed:(){
                          message.text='${row['message']??''}';
                          messages.remove(row);
                          setState((){});
                        },
                        child:const Text('Kirim ulang')),
                  ]))),
          ],
        ))),
      SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(12),
        child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
          Expanded(child:TextField(controller:message,enabled:!sending,
            minLines:1,maxLines:4,maxLength:2500,
            decoration:InputDecoration(
              hintText:admin?'Tulis balasan untuk warga...':'Tulis pesan untuk admin...',
              counterText:''))),
          const SizedBox(width:8),
          IconButton.filled(
            tooltip:'Kirim Pesan',onPressed:sending?null:send,
            style:IconButton.styleFrom(
              backgroundColor:scheme.primary,foregroundColor:Colors.white),
            icon:const Icon(Icons.send_rounded,color:Colors.white)),
        ]))),
    ]);
  }
}
