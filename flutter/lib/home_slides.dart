import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api.dart';
import 'premium_ui.dart';

String cikokoHomeSlideUrl(String name)=>Uri.parse(CikokoApi.root).replace(
  queryParameters:{'action':'home_slide_photo','name':name}).toString();
List<String> cikokoHomeSlideNames(Map<String,dynamic> result)=>(result['slides'] as List? ?? const [])
  .whereType<Map>().map((r)=>'${r['name']??''}')
  .where((name)=>RegExp(r'^[a-f0-9]{40}\.(jpg|png|webp)$').hasMatch(name)).take(5).toList();

class CikokoHomeSlideshow extends StatefulWidget {
  final CikokoApi api;
  final int refreshToken;
  const CikokoHomeSlideshow({super.key,required this.api,this.refreshToken=0});
  @override State<CikokoHomeSlideshow> createState()=>_CikokoHomeSlideshowState();
}
class _CikokoHomeSlideshowState extends State<CikokoHomeSlideshow> with WidgetsBindingObserver {
  final controller=PageController();
  List<String> names=[];
  Timer? timer;
  int current=0,loadVersion=0;
  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);load();}
  @override void didUpdateWidget(covariant CikokoHomeSlideshow old){super.didUpdateWidget(old);if(old.refreshToken!=widget.refreshToken||old.api!=widget.api)load();}
  Future<void> load()async{
    final version=++loadVersion;
    try{
      final result=await widget.api.call('home_slides');
      if(!mounted||version!=loadVersion)return;
      timer?.cancel();
      setState((){names=cikokoHomeSlideNames(result);current=0;});
      WidgetsBinding.instance.addPostFrameCallback((_){if(mounted&&controller.hasClients)controller.jumpToPage(0);});
      startTimer();
    }catch(_){/* Keep the last published images during a temporary interruption. */}
  }
  void startTimer(){
    timer?.cancel();if(names.length<2)return;
    timer=Timer.periodic(const Duration(seconds:5),(_){
      if(!mounted||!controller.hasClients)return;
      controller.animateToPage((current+1)%names.length,duration:const Duration(milliseconds:600),curve:Curves.easeInOut);
    });
  }
  @override void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.resumed){startTimer();}else{timer?.cancel();}}
  @override void dispose(){timer?.cancel();WidgetsBinding.instance.removeObserver(this);controller.dispose();super.dispose();}
  Widget fallback()=>Image.asset('assets/kantor-cikoko.jpg',fit:BoxFit.cover,width:double.infinity);
  @override Widget build(BuildContext context)=>ClipRRect(borderRadius:BorderRadius.circular(20),child:AspectRatio(
    aspectRatio:16/9,
    child:names.isEmpty?fallback():Stack(fit:StackFit.expand,children:[
      PageView.builder(controller:controller,itemCount:names.length,
        onPageChanged:(index)=>setState(()=>current=index),
        itemBuilder:(_,index)=>Image.network(cikokoHomeSlideUrl(names[index]),fit:BoxFit.cover,
          errorBuilder:(_,error,trace)=>fallback())),
      if(names.length>1)Positioned(left:0,right:0,bottom:10,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        for(var index=0;index<names.length;index++)Container(width:current==index?18:7,height:7,margin:const EdgeInsets.symmetric(horizontal:3),
          decoration:BoxDecoration(color:current==index?Colors.white:Colors.white60,borderRadius:BorderRadius.circular(8))),
      ])),
    ])));
}

class HomeSlidesEditor extends StatefulWidget {
  final CikokoApi api;
  const HomeSlidesEditor({super.key,required this.api});
  @override State<HomeSlidesEditor> createState()=>_HomeSlidesEditorState();
}
class _HomeSlidesEditorState extends State<HomeSlidesEditor> {
  List<String?> slots=List.filled(5,null);
  bool loading=true,busy=false;
  String? error;
  @override void initState(){super.initState();load();}
  Future<void> load()async{
    setState((){loading=true;error=null;});
    try{
      final names=cikokoHomeSlideNames(await widget.api.call('home_slides'));
      if(mounted)setState(()=>slots=List.generate(5,(index)=>index<names.length?names[index]:null));
    }catch(e){if(mounted)setState(()=>error=cikokoFormalMessage(e));}
    finally{if(mounted)setState(()=>loading=false);}
  }
  Future<void> choose(int index)async{
    if(busy)return;
    setState(()=>busy=true);
    try{
      final image=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:90,maxWidth:1920);
      if(image==null)return;
      final result=await widget.api.upload('home_slide_upload',{}, {'photo':[image.path]});
      final name='${result['name']??''}';
      if(!RegExp(r'^[a-f0-9]{40}\.(jpg|png|webp)$').hasMatch(name))throw ApiError('Foto belum dapat disimpan. Silakan coba kembali.');
      if(mounted)setState(()=>slots[index]=name);
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(cikokoFormalMessage(e))));}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> save()async{
    if(busy||loading)return;
    setState(()=>busy=true);
    try{
      await widget.api.call('home_slides_save',body:{'slides':slots.whereType<String>().toList()});
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Foto beranda berhasil diperbarui.')));
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(cikokoFormalMessage(e))));}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(14),children:[
    const CikokoPremiumHeader(title:'Foto Beranda',subtitle:'Atur hingga 5 foto. Foto berganti otomatis setiap 5 detik.',icon:Icons.photo_library_outlined),
    const SizedBox(height:14),
    if(loading)const Center(child:CircularProgressIndicator())
    else if(error!=null)...[Text(error!),TextButton(onPressed:load,child:const Text('Coba Kembali'))]
    else ...[
      const Text('Gunakan foto mendatar dengan perbandingan 16:9. Simpan untuk menampilkan perubahan di Beranda.'),
      for(var index=0;index<5;index++)Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text('Foto ${index+1}',style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:8),
        AspectRatio(aspectRatio:16/9,child:slots[index]==null?const Center(child:Icon(Icons.add_photo_alternate_outlined,size:42)):
          Image.network(cikokoHomeSlideUrl(slots[index]!),headers:widget.api.authHeaders(),fit:BoxFit.cover,
            errorBuilder:(_,error,trace)=>const Center(child:Text('Pratinjau belum tersedia.')))),
        Wrap(spacing:8,children:[
          TextButton.icon(onPressed:busy?null:()=>choose(index),icon:const Icon(Icons.photo_library_outlined),label:Text(slots[index]==null?'Pilih Foto':'Ganti Foto')),
          if(slots[index]!=null)TextButton(onPressed:busy?null:()=>setState(()=>slots[index]=null),child:const Text('Hapus')),
          if(index>0)IconButton(tooltip:'Pindahkan ke Atas',onPressed:busy?null:()=>setState((){final previous=slots[index-1];slots[index-1]=slots[index];slots[index]=previous;}),icon:const Icon(Icons.arrow_upward)),
          if(index<4)IconButton(tooltip:'Pindahkan ke Bawah',onPressed:busy?null:()=>setState((){final next=slots[index+1];slots[index+1]=slots[index];slots[index]=next;}),icon:const Icon(Icons.arrow_downward)),
        ]),
      ]))),
      FilledButton.icon(onPressed:busy?null:save,icon:const Icon(Icons.save_outlined),label:Text(busy?'Memproses...':'Simpan Foto Beranda')),
    ],
  ]);
}
