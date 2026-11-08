import 'package:flutter/material.dart';
import 'api.dart';
import 'waris_draft.dart';

class AccountSupportPage extends StatefulWidget {
 final CikokoApi api;final bool deletion;
 const AccountSupportPage({super.key,required this.api,this.deletion=false});
 @override State<AccountSupportPage> createState()=>_AccountSupportState();
}
class _AccountSupportState extends State<AccountSupportPage>{
 final username=TextEditingController(),contact=TextEditingController(),password=TextEditingController();bool busy=false;String? result;
 @override void dispose(){username.dispose();contact.dispose();password.dispose();super.dispose();}
 Future<void> send()async{if(busy)return;setState(()=>busy=true);
  try{final r=await widget.api.call(widget.deletion?'account_request':'account_help',body:widget.deletion?{'password':password.text}:{'username':username.text.trim(),'contact':contact.text.trim()});if(widget.deletion)await WarisDraftStore('${widget.api.profile?['id']??''}').clear();if(mounted)setState(()=>result='${r['message']}');password.clear();}
  catch(e){if(mounted)setState(()=>result=cikokoFormalMessage(e));}finally{if(mounted)setState(()=>busy=false);}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.deletion?'Penghapusan Akun':'Pemulihan Akun')),body:ListView(padding:const EdgeInsets.all(20),children:[
  Text(widget.deletion?'Ajukan penghapusan akun warga dan data komunikasi Anda. Petugas akan memverifikasi permintaan. Arsip surat, laporan, dan dokumen pelayanan resmi akan ditinjau menurut ketentuan retensi pengelola; mintalah penjelasan melalui chat admin.':'Isi nama pengguna dan kontak yang dapat dihubungi. Pemulihan dilakukan petugas setelah mencocokkan identitas melalui kontak terdaftar. Jangan menyampaikan kata sandi atau PIN.',style:Theme.of(context).textTheme.bodyLarge),
  const SizedBox(height:20),
  if(widget.deletion)TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Konfirmasi Kata Sandi'))
  else ...[TextField(controller:username,decoration:const InputDecoration(labelText:'Nama Pengguna')),const SizedBox(height:12),TextField(controller:contact,decoration:const InputDecoration(labelText:'Nomor Telepon / Email'))],
  const SizedBox(height:20),FilledButton(onPressed:busy?null:send,child:Text(busy?'Mengirim...':'Kirim Permintaan')),
  if(result!=null)Padding(padding:const EdgeInsets.only(top:16),child:SelectableText(result!)),
 ]));
}

class AccountRequestsPage extends StatefulWidget{
 final CikokoApi api;const AccountRequestsPage({super.key,required this.api});
 @override State<AccountRequestsPage> createState()=>_AccountRequestsState();
}
class _AccountRequestsState extends State<AccountRequestsPage>{
 List<dynamic> rows=[];bool loading=true,more=false;String? error;
 @override void initState(){super.initState();load();}
 Future<void> load({bool older=false})async{try{final d=await widget.api.callWithParams('account_requests',{if(older&&rows.isNotEmpty)'before_id':'${rows.last['id']}'});if(mounted)setState((){rows=older?[...rows,...List<dynamic>.from(d['items'])]:List<dynamic>.from(d['items']);more=d['has_more']==true;error=null;});}catch(e){if(mounted)setState(()=>error=cikokoFormalMessage(e));}finally{if(mounted)setState(()=>loading=false);}}
 Future<void> resolve(Map<String,dynamic> row)async{
  final pw=TextEditingController(),next=TextEditingController();bool verified=false;
  final approve=await showDialog<bool>(context:context,builder:(c)=>StatefulBuilder(builder:(c,set)=>AlertDialog(title:Text(row['kind']=='deletion'?'Proses Penghapusan Akun':'Pulihkan Akun Warga'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
   const Text('Cocokkan identitas melalui kontak yang sudah terdaftar pada akun, bukan hanya kontak dalam permintaan. Untuk penghapusan, jelaskan terlebih dahulu penanganan arsip pelayanan resmi. Tindakan ini mencabut seluruh sesi akun.'),
   CheckboxListTile(value:verified,onChanged:(v)=>set(()=>verified=v==true),title:const Text('Identitas dan kontak terdaftar telah diverifikasi')),
   if(row['kind']=='recovery')TextField(controller:next,obscureText:true,decoration:const InputDecoration(labelText:'Kata Sandi Baru (10+ karakter, huruf dan angka)')),
   TextField(controller:pw,obscureText:true,decoration:const InputDecoration(labelText:'Kata Sandi Admin Utama')),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Batal')),FilledButton(onPressed:verified?()=>Navigator.pop(c,true):null,child:const Text('Proses Permintaan'))])));
  final adminPassword=pw.text,newPassword=next.text;pw.dispose();next.dispose();if(approve!=true)return;
  try{await widget.api.call('account_request_resolve',body:{'id':row['id'],'verified':true,'admin_password':adminPassword,'new_password':newPassword});await load();}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(cikokoFormalMessage(e))));}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Bantuan Akun Warga')),body:RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(16),children:[
  if(loading)const LinearProgressIndicator(),if(error!=null)Text(error!),if(!loading&&rows.isEmpty)const Text('Belum ada permintaan bantuan akun.'),
  for(final r in rows)Card(child:ListTile(title:Text(r['kind']=='deletion'?'Penghapusan Akun':'Pemulihan Akun'),subtitle:Text('Akun: ${r['username']} (${r['user_id']})\nKontak terdaftar: ${r['registered_contact']}\nKontak permintaan: ${r['contact']}\n${r['created_at']}'),trailing:const Icon(Icons.chevron_right),onTap:()=>resolve(Map<String,dynamic>.from(r)))),
  if(more)TextButton(onPressed:()=>load(older:true),child:const Text('Muat Permintaan Sebelumnya')),
 ])));
}
