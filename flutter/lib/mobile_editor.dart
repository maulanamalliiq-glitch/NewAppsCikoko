import 'dart:io';
import 'package:flutter/material.dart';
import 'premium_ui.dart';
import 'api.dart';
import 'v211_features.dart';
import 'package:image_picker/image_picker.dart';

class MobileEditor extends StatefulWidget {
  final String mode;
  final CikokoApi api;
  const MobileEditor({super.key,required this.mode,required this.api});
  @override State<MobileEditor> createState()=>_MobileEditorState();
}
class _MobileEditorState extends State<MobileEditor> {
 final title=TextEditingController(),body=TextEditingController(),reference=TextEditingController(),deceased=TextEditingController(),year=TextEditingController();
 bool sending=false;final List<String> newsPhotos=[];
 bool get archive=>widget.mode=='archive';
 @override void dispose(){title.dispose();body.dispose();reference.dispose();deceased.dispose();year.dispose();super.dispose();}
 Future<void> submit() async {
  if (sending) return;
  if (!archive && (title.text.trim().length < 5 ||
      body.text.trim().length < 10)) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content:Text('Judul minimal 5 karakter dan isi minimal 10 karakter.')));
    return;
  }
  setState(()=>sending=true);
  try {
   final isNews=widget.mode=='berita';
   if(archive){await widget.api.call('archive_create',body:{'archive_year':int.tryParse(year.text)??0,'reference_no':reference.text.trim(),'applicant_name':title.text.trim(),'deceased_name':deceased.text.trim(),'notes':body.text.trim()});}
   else {final created=await widget.api.call('content_create',body:{'type':isNews?'berita':'pengumuman','title':title.text.trim(),'body':body.text.trim()});
      if(isNews){final id='${created['id']??''}';for(final path in newsPhotos){await widget.api.upload('v211_news_upload',{'id':id},{'photo':[path]});}newsPhotos.clear();}}
   if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Informasi berhasil diterbitkan.')));title.clear();body.clear();reference.clear();deceased.clear();year.clear();}
  } catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Gagal: $e')));}
  finally {if(mounted)setState(()=>sending=false);}
 }
 Future<void> _addNewsImage(ImageSource source) async {
  if(newsPhotos.length>=5)return;
  final img=await ImagePicker().pickImage(source:source,
    imageQuality:82,maxWidth:2200);
  if(img!=null&&mounted)setState(()=>newsPhotos.add(img.path));
 }
 Future<void> _replaceNewsImage(int index,ImageSource source) async {
  final img=await ImagePicker().pickImage(source:source,
    imageQuality:82,maxWidth:2200);
  if(img!=null&&mounted&&index>=0&&index<newsPhotos.length){
    setState(()=>newsPhotos[index]=img.path);
  }
 }
 Widget entry(String label,TextEditingController controller,{int lines=1,TextInputType? keyboard}) => Padding(padding:const EdgeInsets.only(bottom:12),child:TextField(controller:controller,maxLines:lines,keyboardType:keyboard,decoration:InputDecoration(labelText:label)));
 @override
 Widget build(BuildContext context)=>ListView(
  padding:const EdgeInsets.fromLTRB(14,12,14,30),
  children:[
   CikokoPremiumHeader(
    title:archive?'Tambah Arsip Ahli Waris':
      widget.mode=='berita'?'Publikasi Berita':'Tambah Pengumuman',
    subtitle:archive?'Catat metadata arsip resmi secara aman.':
      'Tulis konten layanan publik yang dapat dibaca warga.',
    icon:archive?Icons.folder_copy_outlined:
      widget.mode=='berita'?Icons.newspaper_outlined:Icons.campaign_outlined),
   const SizedBox(height:13),
   CikokoPremiumSurface(child:Column(
    crossAxisAlignment:CrossAxisAlignment.stretch,
    children:[
     Text(archive?'Informasi Arsip':'Informasi Publikasi',
       style:Theme.of(context).textTheme.titleMedium),
     const SizedBox(height:12),
     if(archive)...[
      entry('Tahun surat',year,keyboard:TextInputType.number),
      entry('Nomor surat',reference),
      entry('Nama pemohon',title),
      entry('Nama pewaris',deceased),
      entry('Catatan arsip',body,lines:4),
     ]else...[
      entry('Judul',title),
      entry('Isi ${widget.mode}',body,lines:8),
     ],
    ],
   )),
   if(widget.mode=='berita')...[
    const SizedBox(height:12),
    CikokoPremiumSurface(child:Column(
     crossAxisAlignment:CrossAxisAlignment.stretch,
     children:[
      Text('Dokumentasi Berita',
        style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:4),
      Text('Maksimal 5 foto. Lihat setiap pratinjau dan ganti jika diperlukan.',
        style:Theme.of(context).textTheme.bodySmall),
      const SizedBox(height:10),
      for(var index=0;index<newsPhotos.length;index++)...[
       Container(
        margin:const EdgeInsets.only(bottom:11),
        padding:const EdgeInsets.all(9),
        decoration:BoxDecoration(
         color:Theme.of(context).colorScheme.surfaceContainerLow,
         borderRadius:BorderRadius.circular(13),
         border:Border.all(
          color:Theme.of(context).colorScheme.outlineVariant)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
         Text('Foto ${index+1} dari 5',
          style:Theme.of(context).textTheme.titleMedium),
         const SizedBox(height:7),
         ClipRRect(
          borderRadius:BorderRadius.circular(10),
          child:Image.file(File(newsPhotos[index]),
           height:135,fit:BoxFit.contain,
           errorBuilder:(_,__,___)=>const SizedBox(
            height:110,
            child:Center(child:Text('Pratinjau foto tidak tersedia')))),
         ),
         Wrap(spacing:7,runSpacing:5,children:[
          OutlinedButton.icon(
           onPressed:()=>_replaceNewsImage(index,ImageSource.gallery),
           icon:const Icon(Icons.photo_library_outlined,size:17),
           label:const Text('Ganti Foto')),
          OutlinedButton.icon(
           onPressed:()=>_replaceNewsImage(index,ImageSource.camera),
           icon:const Icon(Icons.camera_alt_outlined,size:17),
           label:const Text('Foto Ulang')),
          TextButton.icon(
           onPressed:()=>setState(()=>newsPhotos.removeAt(index)),
           icon:const Icon(Icons.delete_outline_rounded,size:17),
           label:const Text('Hapus')),
         ]),
        ]),
       ),
      ],
      if(newsPhotos.isEmpty)
       const CikokoEmptyState(
        icon:Icons.add_photo_alternate_outlined,
        title:'Belum ada foto berita',
        subtitle:'Foto akan muncul di sini setelah dipilih.'),
      Wrap(spacing:8,runSpacing:6,children:[
       OutlinedButton.icon(
        onPressed:newsPhotos.length>=5?null:
          ()=>_addNewsImage(ImageSource.camera),
        icon:const Icon(Icons.camera_alt_outlined),
        label:const Text('Kamera')),
       OutlinedButton.icon(
        onPressed:newsPhotos.length>=5?null:
          ()=>_addNewsImage(ImageSource.gallery),
        icon:const Icon(Icons.photo_library_outlined),
        label:const Text('Galeri')),
      ]),
     ],
    )),
   ],
   const SizedBox(height:13),
   FilledButton.icon(
    onPressed:sending?null:submit,
    icon:const Icon(Icons.save_outlined),
    label:Text(sending?'Menyimpan...':'Simpan dan Terbitkan')),
   if(archive)...[
    const SizedBox(height:8),
    Text('Lampiran arsip lama tetap dikelola melalui layanan administrasi '
     'yang berwenang; formulir ini menyimpan metadata.',
     style:Theme.of(context).textTheme.bodySmall),
   ],
   const CikokoPageSignature(),
  ],
 );

}
class ArchiveList extends StatefulWidget {final CikokoApi api;const ArchiveList({super.key,required this.api});@override State<ArchiveList> createState()=>_ArchiveListState();}
class _ArchiveListState extends State<ArchiveList> {late Future<Map<String,dynamic>> result;@override void initState(){super.initState();result=widget.api.call('archives');}
 @override Widget build(BuildContext c)=>FutureBuilder<Map<String,dynamic>>(future:result,builder:(ctx,s){if(s.hasError)return Center(child:Text('Gagal memuat arsip: ${s.error}'));if(!s.hasData)return const Center(child:CircularProgressIndicator());final rows=(s.data!['items'] as List<dynamic>? ??[]);return ListView.builder(padding:const EdgeInsets.all(12),itemCount:rows.length,itemBuilder:(ctx,i){final row=rows[i] as Map<String,dynamic>;return Card(child:ListTile(leading:const Icon(Icons.folder_copy_outlined),title:Text('${row['reference_no']??''} • ${row['archive_year']??''}'),subtitle:Text('Pemohon: ${row['applicant_name']??''}\nPewaris: ${row['deceased_name']??''}'),trailing:const Icon(Icons.edit_outlined),onTap:()async{await Navigator.of(ctx).push(MaterialPageRoute<void>(builder:(_)=>Scaffold(appBar:AppBar(title:const Text('Edit Arsip Ahli Waris')),body:ArchiveEditorPage(api:widget.api,editId:int.parse('${row['id']}')))));if(mounted)setState(()=>result=widget.api.call('archives'));}));});});}
