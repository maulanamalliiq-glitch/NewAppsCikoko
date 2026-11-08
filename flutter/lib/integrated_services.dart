import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'premium_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';

const _ink = Color(0xff12375d);
const _accent = Color(0xff246ac5);

/// Available to signed-in residents. Entries are read from the server when
/// configured, otherwise this public, read-only starting catalog is shown.
/// Missing links are deliberately NOT fabricated.
List<Map<String,dynamic>> cikokoDefaultIntegratedServices() => [
  {'id':'ptsp','title':'PTSP','description':'Pelayanan perizinan dan nonperizinan DKI Jakarta.','url':'https://ptsp.jakarta.go.id/','logo_url':'','active':true},
  {'id':'dukcapil','title':'Dukcapil','description':'Informasi dan layanan administrasi kependudukan.','url':'https://kependudukancapil.jakarta.go.id/layanan-online/','logo_url':'','active':true},
  {'id':'alpukat','title':'Alpukat Betawi','description':'Pengajuan dokumen kependudukan secara daring.','url':'https://alpukat-dukcapil.jakarta.go.id/','logo_url':'','active':true},
  {'id':'jakevo','title':'Jak Evo','description':'Pengurusan perizinan melalui JAKEVO.','url':'https://jakevo.jakarta.go.id/','logo_url':'','active':true},
  {'id':'sosial','title':'Sosial','description':'Informasi layanan kesejahteraan sosial Jakarta.','url':'https://dinsos.jakarta.go.id/','logo_url':'','active':true},
  {'id':'puskesmas','title':'Puskesmas','description':'Layanan kesehatan dan pendaftaran Puskesmas.','url':'https://www.jakarta.go.id/index.php/aplikasi-jaksehat','logo_url':'','active':true},
  {'id':'kecamatan','title':'Kecamatan','description':'Informasi pelayanan Kecamatan Pancoran.','url':'','logo_url':'','active':true},
  {'id':'pajak','title':'Pajak Online','description':'Pelayanan pajak daerah dan informasi PBB.','url':'https://pajakonline.jakarta.go.id/','logo_url':'','active':true},
  {'id':'jawara','title':'Jawara','description':'Akses layanan Jawara sesuai pengaturan Admin Utama.','url':'','logo_url':'','active':true},
  {'id':'jaksehat','title':'Jak-Sehat','description':'Akses aplikasi dan layanan kesehatan Jakarta.','url':'https://www.jakarta.go.id/index.php/aplikasi-jaksehat','logo_url':'','active':true},
  {'id':'bpjstk','title':'BPJS Ketenagakerjaan','description':'Informasi kepesertaan dan pelayanan jaminan sosial ketenagakerjaan.','url':'https://www.bpjsketenagakerjaan.go.id/','logo_url':'','active':true},
];

class CikokoIntegratedServices extends StatefulWidget {
  final CikokoApi api;
  final bool admin;
  const CikokoIntegratedServices({super.key,required this.api,this.admin=false});
  @override State<CikokoIntegratedServices> createState()=>_CikokoIntegratedServicesState();
}
class _CikokoIntegratedServicesState extends State<CikokoIntegratedServices> {
  List<Map<String,dynamic>> entries=[];
  bool loading=true,saving=false;
  String search='';
  String? notice;
  @override void initState(){super.initState();load();}
  Future<void> load()async{
    if(mounted)setState(()=>loading=true);
    try{
      final result=await widget.api.call('integrated_services');
      final rows=List<dynamic>.from(result['items']??[]);
      if(mounted)setState((){entries=rows.map((e)=>Map<String,dynamic>.from(e as Map)).toList();notice=null;});
    }catch(_){
      if(mounted)setState((){
        entries=cikokoDefaultIntegratedServices();
        notice=widget.admin
          ?'Pengaturan layanan belum dapat dimuat. Perubahan belum dapat disimpan.'
          :'Daftar layanan dasar ditampilkan. Beberapa tautan dapat diperbarui oleh pengelola.';
      });
    }finally{if(mounted)setState(()=>loading=false);}
  }
  Future<void> openLink(String raw)async{
    final target=Uri.tryParse(raw.trim());
    if(target==null||target.scheme!='https'||target.host.isEmpty){
      _message('Tautan layanan ini belum tersedia. Silakan hubungi pengelola.');return;
    }
    try{
      final ok=await launchUrl(target,mode:LaunchMode.externalApplication);
      if(!ok)_message('Tautan belum dapat dibuka. Silakan coba kembali.');
    }catch(_){_message('Layanan tujuan belum dapat dibuka. Silakan coba kembali.');}
  }
  void _message(String text){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));}
  Future<void> save(List<Map<String,dynamic>> next)async{
    setState(()=>saving=true);
    try{
      await widget.api.call('integrated_services_save',body:{'items':next});
      if(mounted){setState(()=>entries=next);_message('Perubahan layanan berhasil disimpan.');}
    }catch(_){_message('Perubahan belum dapat disimpan. Periksa koneksi atau pengaturan layanan.');}
    finally{if(mounted)setState(()=>saving=false);}
  }
  Future<String?> pickLogo()async{
    try{
      final photo=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:78,maxWidth:720,maxHeight:720);
      if(photo==null)return null;
      final bytes=await photo.readAsBytes();
      if(bytes.length>2*1024*1024){_message('Logo maksimal 2 MB. Pilih gambar lebih kecil.');return null;}
      final uri=Uri.parse('${CikokoApi.root}?action=integrated_services_logo_upload');
      final request=http.MultipartRequest('POST',uri);
      request.headers.addAll(widget.api.authHeaders());
      request.files.add(http.MultipartFile.fromBytes('logo',bytes,filename:photo.name));
      final response=await http.Response.fromStream(await request.send().timeout(const Duration(seconds:40)));
      final data=jsonDecode(utf8.decode(response.bodyBytes)) as Map<String,dynamic>;
      if(response.statusCode!=200||data['ok']!=true)throw Exception('${data['error']??'Upload gagal'}');
      return '${data['url']??''}';
    }on TimeoutException{
      _message('Unggah logo terlalu lama. Periksa jaringan dan coba kembali.');
      return null;
    }on SocketException{
      _message('Koneksi terputus saat mengunggah logo. Coba kembali.');
      return null;
    }on FormatException{
      _message('Logo belum dapat disimpan. Silakan coba kembali atau hubungi petugas.');
      return null;
    }catch(e){
      _message('Unggah logo gagal: ${cikokoFormalMessage(e)}');
      return null;
    }
  }
  Future<void> edit([Map<String,dynamic>? old])async{
    final title=TextEditingController(text:'${old?['title']??''}');
    final desc=TextEditingController(text:'${old?['description']??''}');
    final logo=TextEditingController(text:'${old?['logo_url']??''}');
    final link=TextEditingController(text:'${old?['url']??''}');
    bool active=old?['active']!=false;
    bool uploading=false;
    final form=GlobalKey<FormState>();
    try{
      final updated=await showDialog<Map<String,dynamic>>(context:context,builder:(c)=>StatefulBuilder(builder:(ctx,change)=>AlertDialog(
        title:Text(old==null?'Tambah Layanan':'Edit Layanan'),
        content:SingleChildScrollView(child:Form(key:form,child:Column(mainAxisSize:MainAxisSize.min,children:[
          TextFormField(controller:title,decoration:const InputDecoration(labelText:'Judul layanan'),maxLength:80,
              validator:(v)=>(v??'').trim().isEmpty?'Judul wajib diisi':null),
          TextFormField(controller:desc,decoration:const InputDecoration(labelText:'Keterangan'),maxLines:3,maxLength:300),
          OutlinedButton.icon(
            onPressed:uploading?null:()async{
              change(()=>uploading=true);
              final uploaded=await pickLogo();
              if(ctx.mounted)change((){
                if(uploaded!=null)logo.text=uploaded;
                uploading=false;
              });
            },
            icon:Icon(uploading?Icons.hourglass_top:Icons.photo_library_outlined),
            label:Text(uploading?'Mengunggah logo...':'Pilih Logo dari Galeri'),
          ),
          if(logo.text.isNotEmpty)Padding(
            padding:const EdgeInsets.symmetric(vertical:8),
            child:Image.network(logo.text,height:64,width:64,fit:BoxFit.contain,
              errorBuilder:(_,__,___)=>const Icon(Icons.image_not_supported_outlined)),
          ),
          TextFormField(controller:link,decoration:const InputDecoration(labelText:'Link Lihat Selengkapnya'),keyboardType:TextInputType.url,
              validator:(v){final x=(v??'').trim();return x.isNotEmpty&&(Uri.tryParse(x)?.scheme!='https')?'Gunakan tautan yang aman (diawali https://)':null;}),
          SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Tampilkan kepada warga'),value:active,onChanged:(v)=>change(()=>active=v)),
        ]))),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Batal')),
          FilledButton(onPressed:(){if(form.currentState!.validate())Navigator.pop(ctx,{
            'id':'${old?['id']??DateTime.now().microsecondsSinceEpoch}',
            'title':title.text.trim(),'description':desc.text.trim(),
            'logo_url':logo.text.trim(),'url':link.text.trim(),'active':active,
          });},child:const Text('Simpan')),
        ],
      )));
      if(updated==null)return;
      final next=entries.map((e)=>Map<String,dynamic>.from(e)).toList();
      final index=next.indexWhere((e)=>e['id']==updated['id']);
      if(index<0){next.add(updated);}else{next[index]=updated;}
      await save(next);
    }finally{title.dispose();desc.dispose();logo.dispose();link.dispose();}
  }
  Future<void> remove(Map<String,dynamic> entry)async{
    final confirm=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Hapus layanan?'),content:Text('Layanan ${entry['title']} akan dihapus dari katalog, bukan dari situs tujuan.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Batal')),
        FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Hapus'))]));
    if(confirm==true)await save(entries.where((e)=>e['id']!=entry['id']).toList());
  }
  Widget logoFor(Map<String,dynamic> entry){
    final url='${entry['logo_url']??''}';
    final uri=Uri.tryParse(url);
    if(uri?.scheme=='https'&&uri?.host.isNotEmpty==true){
      return Image.network(url,width:42,height:42,fit:BoxFit.contain,errorBuilder:(_,__,___)=>const Icon(Icons.account_balance_outlined,color:_accent));
    }
    return const Icon(Icons.account_balance_outlined,color:_accent,size:25);
  }
  @override
  Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    final visible=(widget.admin?entries:
        entries.where((entry)=>entry['active']!=false))
      .where((entry){
        final text=search.trim().toLowerCase();
        return text.isEmpty||
          '${entry['title']??''}'.toLowerCase().contains(text)||
          '${entry['description']??''}'.toLowerCase().contains(text);
      }).toList();
    return RefreshIndicator(
      onRefresh:load,
      child:ListView(
        padding:const EdgeInsets.fromLTRB(14,12,14,28),
        children:[
          CikokoPremiumHeader(
            title:widget.admin?'Kelola Layanan Terpadu':'Layanan Masyarakat Terpadu',
            subtitle:widget.admin
              ?'Kelola layanan, logo resmi dan tautan tujuan untuk warga.'
              :'Temukan layanan administrasi dan informasi publik.',
            icon:widget.admin?Icons.tune_rounded:Icons.widgets_outlined,
          ),
          const SizedBox(height:14),
          if(notice!=null)
            CikokoPremiumSurface(child:Row(children:[
              Icon(Icons.info_outline_rounded,color:scheme.primary),
              const SizedBox(width:10),
              Expanded(child:Text(notice!,
                style:TextStyle(color:scheme.onSurface,fontSize:11.5))),
            ])),
          if(widget.admin)...[
            const SizedBox(height:12),
            FilledButton.icon(
              onPressed:saving?null:()=>edit(),
              icon:const Icon(Icons.add_circle_outline_rounded),
              label:const Text('Tambah Layanan Resmi')),
          ],
          const SizedBox(height:13),
          TextField(
            key:const Key('integrated_services_search'),
            onChanged:(value)=>setState(()=>search=value),
            decoration:const InputDecoration(
              hintText:'Cari nama atau keterangan layanan...',
              prefixIcon:Icon(Icons.search_rounded)),
          ),
          const SizedBox(height:12),
          CikokoPremiumSection(
            title:'Direktori Layanan',
            subtitle:'${visible.length} layanan ditampilkan',
          ),
          if(loading)
            const Padding(padding:EdgeInsets.symmetric(vertical:12),
              child:LinearProgressIndicator()),
          if(visible.isEmpty&&!loading)
            const CikokoEmptyState(
              icon:Icons.search_off_rounded,
              title:'Layanan tidak ditemukan',
              subtitle:'Coba kata kunci lain atau muat ulang daftar.'),
          for(final entry in visible)
            Padding(
              padding:const EdgeInsets.only(bottom:9),
              child:Material(
                color:scheme.surface,
                borderRadius:BorderRadius.circular(17),
                child:InkWell(
                  onTap:widget.admin?null:
                    ()=>openLink('${entry['url']??''}'),
                  borderRadius:BorderRadius.circular(17),
                  child:Container(
                    padding:const EdgeInsets.all(12),
                    decoration:BoxDecoration(
                      borderRadius:BorderRadius.circular(17),
                      border:Border.all(color:scheme.outlineVariant),
                    ),
                    child:Row(children:[
                      Container(
                        width:51,height:51,alignment:Alignment.center,
                        padding:const EdgeInsets.all(6),
                        decoration:BoxDecoration(
                          color:scheme.primaryContainer,
                          borderRadius:BorderRadius.circular(13),
                        ),
                        child:logoFor(entry),
                      ),
                      const SizedBox(width:11),
                      Expanded(child:Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children:[
                          Text('${entry['title']??''}',maxLines:2,
                            overflow:TextOverflow.ellipsis,
                            style:TextStyle(color:scheme.onSurface,
                              fontSize:13.4,fontWeight:FontWeight.w800)),
                          const SizedBox(height:4),
                          Text('${entry['description']??''}',maxLines:2,
                            overflow:TextOverflow.ellipsis,
                            style:TextStyle(color:scheme.onSurfaceVariant,
                              height:1.35,fontSize:11)),
                          if(widget.admin)...[
                            const SizedBox(height:5),
                            Text(entry['active']==false?'Disembunyikan':'Aktif',
                              style:TextStyle(fontSize:10.5,fontWeight:FontWeight.w700,
                                color:entry['active']==false
                                  ?scheme.onSurfaceVariant:const Color(0xFF079E74))),
                          ],
                        ],
                      )),
                      if(widget.admin)
                        PopupMenuButton<String>(
                          enabled:!saving,
                          onSelected:(value)=>value=='edit'
                            ?edit(entry):remove(entry),
                          itemBuilder:(_)=>const [
                            PopupMenuItem(value:'edit',child:Text('Edit Layanan')),
                            PopupMenuItem(value:'remove',child:Text('Hapus Layanan')),
                          ],
                        )
                      else Icon(Icons.arrow_circle_right_outlined,
                        size:24,color:scheme.primary),
                    ]),
                  ),
                ),
              ),
            ),
          const CikokoPageSignature(),
        ],
      ),
    );
  }}
