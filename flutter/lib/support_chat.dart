import 'dart:async';
import 'package:flutter/material.dart';
import 'api.dart';
import 'premium_ui.dart';

class SupportChatPage extends StatefulWidget {
  final CikokoApi api;
  final String? residentId;
  final String residentName;
  const SupportChatPage({super.key,required this.api,this.residentId,this.residentName='Warga'});
  @override State<SupportChatPage> createState()=>_SupportChatState();
}
class _SupportChatState extends State<SupportChatPage> with WidgetsBindingObserver {
  final message=TextEditingController();
  List<dynamic> messages=[];
  Timer? timer;
  bool sending=false,loading=true,fetching=false;
  String? error;
  bool get admin=>widget.residentId!=null;
  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);refresh();startPolling();}
  void startPolling(){timer?.cancel();timer=Timer.periodic(const Duration(seconds:3),(_)=>refresh());}
  @override void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.resumed){startPolling();refresh();}else{timer?.cancel();}}
  @override void dispose(){WidgetsBinding.instance.removeObserver(this);timer?.cancel();message.dispose();super.dispose();}
  Future<void> refresh()async{
    if(fetching)return;fetching=true;
    try{
      final result=admin?await widget.api.callWithParams('support_admin_thread',{'user_id':widget.residentId!}):await widget.api.call('chat');
      if(mounted)setState((){messages=List<dynamic>.from(result['messages'] as List? ?? const []);error=null;});
    }catch(e){if(mounted)setState(()=>error=cikokoFormalMessage(e));}
    finally{fetching=false;if(mounted)setState(()=>loading=false);}
  }
  Future<void> send()async{
    final text=message.text.trim();if(sending||text.isEmpty)return;
    setState(()=>sending=true);
    try{
      await widget.api.call(admin?'chat_reply':'chat_send',body:{'message':text,if(admin)'user_id':widget.residentId});
      message.clear();await refresh();
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(cikokoFormalMessage(e))));}
    finally{if(mounted)setState(()=>sending=false);}
  }
  @override Widget build(BuildContext context){
    final scheme=Theme.of(context).colorScheme;
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(12,12,12,8),child:CikokoPremiumHeader(
        title:admin?'Percakapan Warga':'Hubungi Admin',
        subtitle:admin?widget.residentName:'Sampaikan pertanyaan atau kebutuhan bantuan Anda.',icon:Icons.support_agent_outlined)),
      if(error!=null)Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:Row(children:[
        Expanded(child:Text(error!)),TextButton(onPressed:refresh,child:const Text('Coba Kembali'))])),
      Expanded(child:loading?const Center(child:CircularProgressIndicator()):RefreshIndicator(onRefresh:refresh,child:ListView(
        padding:const EdgeInsets.all(14),physics:const AlwaysScrollableScrollPhysics(),children:[
          if(messages.isEmpty&&error==null)const CikokoEmptyState(icon:Icons.chat_bubble_outline_rounded,title:'Belum ada pesan',subtitle:'Mulai percakapan dengan mengirim pesan.'),
          for(final row in messages)Align(alignment:(row['sender']=='admin')==admin?Alignment.centerRight:Alignment.centerLeft,
            child:Container(constraints:const BoxConstraints(maxWidth:340),margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),
              decoration:BoxDecoration(color:(row['sender']=='admin')==admin?scheme.primaryContainer:scheme.surfaceContainerHighest,borderRadius:BorderRadius.circular(16)),
              child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('${row['message']??''}',style:TextStyle(color:scheme.onSurface)),
                const SizedBox(height:4),Text('${row['created_at']??''}',style:Theme.of(context).textTheme.labelSmall),
              ]))),
        ]))),
      SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(12),child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
        Expanded(child:TextField(controller:message,enabled:!sending,minLines:1,maxLines:4,maxLength:2500,
          decoration:InputDecoration(hintText:admin?'Tulis balasan untuk warga...':'Tulis pesan untuk admin...',counterText:''))),
        const SizedBox(width:8),IconButton.filled(tooltip:'Kirim Pesan',onPressed:sending?null:send,icon:const Icon(Icons.send_rounded)),
      ]))),
    ]);
  }
}
