import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart' show api, notify, PhotoInput, Field;
import 'api.dart';
import 'premium_ui.dart';
import 'premium_flow_ui.dart';
import 'waris_draft.dart';
class WarisForm extends StatefulWidget{const WarisForm({super.key});@override State<WarisForm> createState()=>_WarisState();}
class _WarisState extends State<WarisForm>{final inputs=<String,TextEditingController>{};final files=<String,List<String>>{};int children=0;bool sending=false;double progress=0;bool agree=false;String? savedReference;bool completed=false;
 late final WarisDraftStore drafts;
 Timer? draftTimer;bool restoringDraft=true;String? draftMessage;Future<void> draftWork=Future.value();
 @override void initState(){super.initState();drafts=WarisDraftStore('${api.profile?['id']??''}');restoreDraft();}
 Future<void> restoreDraft()async{
   try{final data=await drafts.read();if(!mounted)return;
     if(data!=null){
       final values=Map<String,dynamic>.from(data['inputs'] as Map? ?? {});
       for(final e in values.entries){v(e.key).text='${e.value}';}
       children=(data['children'] as num? ?? 0).toInt().clamp(0,10);
       savedReference=data['reference'] as String?;
       final photos=Map<String,dynamic>.from(data['files'] as Map? ?? {});
       for(final e in photos.entries){files[e.key]=List<String>.from(e.value as List);}
       draftMessage='Draf sebelumnya telah dipulihkan. Periksa kembali seluruh isian dan foto.';
     }
   }catch(_){draftMessage='Draf belum dapat dibuka. Silakan coba kembali.';}
   finally{if(mounted)setState(()=>restoringDraft=false);}
 }
 void scheduleDraft(){if(restoringDraft||completed)return;draftTimer?.cancel();draftTimer=Timer(const Duration(seconds:1),()=>saveDraft());}
 Future<void> saveDraft({bool feedback=false})async{
   if(restoringDraft||completed)return;
   final data=<String,dynamic>{'inputs':{for(final e in inputs.entries)e.key:e.value.text},'children':children,'reference':savedReference};
   final photos={for(final e in files.entries)e.key:List<String>.from(e.value)};
   draftWork=draftWork.catchError((_){ }).then((_)=>drafts.save(data,photos));
   try{await draftWork;if(mounted)setState(()=>draftMessage=feedback?'Draf berhasil disimpan pada perangkat ini.':'Draf tersimpan pada perangkat ini.');}
   catch(_){if(mounted)setState(()=>draftMessage='Draf belum berhasil disimpan. Gunakan Simpan Draf untuk mencoba kembali.');}
 }
 Future<void> discardDraft()async{
   final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Hapus draf?'),content:const Text('Isian dan foto draf pada perangkat ini akan dihapus. Pengajuan yang sudah terkirim tetap tersedia di Riwayat.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Batal')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Hapus Draf'))]));
   if(yes!=true)return;draftTimer?.cancel();await draftWork.catchError((_){ });await drafts.clear();
   restoringDraft=true;for(final c in inputs.values){c.clear();}files.clear();children=0;savedReference=null;agree=false;
   if(mounted)setState((){restoringDraft=false;draftMessage='Draf telah dihapus.';});
 }
 Future<void> completeDraft()async{completed=true;draftTimer?.cancel();await draftWork.catchError((_){ });await drafts.clear();}
 TextEditingController v(String id)=>inputs.putIfAbsent(id,(){final c=TextEditingController();c.addListener(scheduleDraft);return c;});
 String? photoFor(String id)=>files[id]?.isNotEmpty==true?files[id]!.first:null;
 @override void dispose(){draftTimer?.cancel();if(!completed&&!restoringDraft)saveDraft();for(final x in inputs.values){x.dispose();}super.dispose();}
 static const names=<String,String>{'name':'Nama pemohon','nik':'NIK pemohon (16 digit)','phone':'Nomor HP','address':'Alamat lengkap','relation':'Hubungan dengan pewaris','deceased_name':'Nama almarhum / almarhumah','birthplace':'Tempat lahir pewaris','birthdate':'Tanggal lahir (YYYY-MM-DD)','marriage_date':'Tanggal menikah (YYYY-MM-DD)','deathdate':'Tanggal meninggal (YYYY-MM-DD)','marital_status':'Status perkawinan','heirs':'Daftar ahli waris'};
 static const requiredPhotos=<String,String>{'r1':'Surat pengantar RT/RW','r2':'Surat permohonan','r3':'Surat pernyataan keabsahan','r4_ktp':'KTP Ahli Waris','r4_kk':'KK Ahli Waris','r4_akta':'Akta Lahir Ahli Waris','r5':'Surat kematian','r6':'Surat nikah'};
 static const witnessPhotos=<String,String>{'saksi_1':'KTP Saksi Pertama','saksi_2':'KTP Saksi Kedua'};
 static const optionalPhotos=<String,String>{'r7':'Akta cerai (jika bercerai)','r8':'Surat kematian ahli waris (jika ada)'};
 static const childPhotos=<String,String>{'ktp':'KTP','kk':'KK','akta':'Akta Lahir'};
 Future<void> showIncomplete(List<String> problems)async{
   if(!mounted)return;
   await showDialog<void>(context:context,builder:(dialog)=>AlertDialog(
     title:const Text('Pengajuan Ahli Waris Belum Lengkap'),
     content:ConstrainedBox(constraints:const BoxConstraints(maxHeight:370),
       child:SingleChildScrollView(child:Column(
         mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,
         children:[
           const Text('Mohon lengkapi atau perbaiki bagian berikut sebelum mengirim:'),
           const SizedBox(height:12),
           for(var i=0;i<problems.length;i++)Padding(
             padding:const EdgeInsets.only(bottom:8),
             child:Text((i+1).toString()+'. '+problems[i],
               style:const TextStyle(fontSize:13))),
         ],
       ))),
     actions:[FilledButton(onPressed:()=>Navigator.pop(dialog),
       child:const Text('Perbaiki Isian'))],
   ));
 }
 bool validDate(String value){
   if(!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value))return false;
   final parts=value.split('-').map(int.tryParse).toList();
   if(parts.any((part)=>part==null))return false;
   final date=DateTime(parts[0]!,parts[1]!,parts[2]!);
   return date.year==parts[0]&&date.month==parts[1]&&date.day==parts[2] &&
     !date.isAfter(DateTime.now())&&date.year>=1850;
 }
 Future<void> uploadWitnessDocuments(String reference)async{
    final witnessFiles=<String,List<String>>{};
    for(final e in witnessPhotos.entries){
      final path=photoFor(e.key);
      if(path!=null)witnessFiles[e.key]=[path];
    }
    if(witnessFiles.length!=witnessPhotos.length)throw ApiError('Mohon lengkapi kedua foto KTP saksi.');
    await api.upload('waris_add_witnesses',{'reference':reference},witnessFiles,
      progress:(p){if(mounted)setState(()=>progress=p);});
  }
  Future<void> send()async{
    if(sending||completed)return;
    if(savedReference!=null){
      setState((){sending=true;progress=0;});
      try{
        await uploadWitnessDocuments(savedReference!);
        if(mounted){setState(()=>completed=true);await completeDraft();notify(context,'KTP kedua saksi berhasil melengkapi pengajuan '+savedReference!);}
      }catch(_){
        await showIncomplete(['Pengajuan '+savedReference!+' sudah tersimpan. KTP saksi belum dapat ditambahkan. Coba Kembali, atau lengkapi melalui Riwayat Pengajuan.']);
      }finally{if(mounted)setState(()=>sending=false);}
      return;
    }
   final missing=<String>[];
   for(final key in const ['name','nik','phone','address','relation',
       'deceased_name','heirs']){
     if(v(key).text.trim().isEmpty)missing.add('Isian '+(names[key]??key)+' masih kosong.');
   }
   final nik=v('nik').text.trim();
   if(nik.isNotEmpty&&!RegExp(r'^\d{16}$').hasMatch(nik)){
     missing.add('NIK pemohon harus tepat 16 digit angka.');
   }
   final phone=v('phone').text.trim();
   if(phone.isNotEmpty&&!RegExp(r'^\+?[0-9]{8,16}$').hasMatch(phone)){
     missing.add('Nomor HP harus 8–16 digit angka, boleh diawali tanda +.');
   }
   for(final key in const ['birthdate','marriage_date','deathdate']){
     final date=v(key).text.trim();
     if(date.isNotEmpty&&!validDate(date)){
       missing.add((names[key]??key)+' harus dipilih dari kalender dan tidak boleh melewati hari ini.');
     }
   }
   for(final entry in {...requiredPhotos,...witnessPhotos}.entries){
      final path=photoFor(entry.key);
     if(path==null)missing.add('Foto '+entry.value+' belum dipilih (Kamera atau Galeri).');
     else if(!await File(path).exists())missing.add('Foto '+entry.value+' tidak ditemukan; pilih ulang fotonya.');
   }
   for(var i=1;i<=children;i++){
     if(v('child_name_'+i.toString()).text.trim().isEmpty){
       missing.add('Nama anak ke-'+i.toString()+' belum diisi.');
     }
     for(final entry in childPhotos.entries){
       final key='child_'+i.toString()+'_'+entry.key;
       final path=photoFor(key);
       if(path==null)missing.add('Foto '+entry.value+' anak ke-'+i.toString()+' belum dipilih.');
       else if(!await File(path).exists())missing.add('Foto '+entry.value+' anak ke-'+i.toString()+' hilang; pilih ulang.');
     }
   }
   for(final entry in optionalPhotos.entries){
     final path=photoFor(entry.key);
     if(path!=null&&!await File(path).exists()){
       missing.add('Foto '+entry.value+' tidak ditemukan; pilih ulang atau kosongkan.');
     }
   }
   if(!agree)missing.add('Centang pernyataan kebenaran data dan foto dokumen.');
   if(missing.isNotEmpty){await showIncomplete(missing);return;}

   setState((){sending=true;progress=0;});
   try{
     // Reject an outdated cPanel before sending potentially sensitive documents.
     final capability=await api.call('waris_format');
     if(capability['upload_format']!='split_v1'){
        throw ApiError('Layanan Ahli Waris perlu diperbarui sebelum pengajuan dikirim.');
      }
      final witnessCapability=await api.call('waris_witness_capabilities');
      if(witnessCapability['supported']!=true)throw ApiError('Fitur dua KTP saksi belum tersedia. Hubungi pengelola layanan.');
     final count=requiredPhotos.length+children*childPhotos.length+
       optionalPhotos.keys.where((key)=>photoFor(key)!=null).length;
     final maxFiles=(capability['max_file_uploads'] as num?)?.toInt()??0;
     final staged=capability['staged_uploads']==true;
     final mainPhotos=<String,List<String>>{
        for(final e in files.entries)
          if(!witnessPhotos.containsKey(e.key))e.key:e.value,
      };
      final data=<String,String>{for(final e in inputs.entries)e.key:e.value.text.trim(),
       'declaration':'1','child_count':children.toString(),
       'document_format':'split_v1'};
     late final Map<String,dynamic> response;
     if(staged){
       // Shared hosting may limit each POST to 20 files. Send 8 per request.
       final random=Random.secure();
       final draftKey=List.generate(16,
         (_)=>random.nextInt(256).toRadixString(16).padLeft(2,'0')).join();
       final photos=<MapEntry<String,String>>[
         for(final entry in mainPhotos.entries)
            for(final path in entry.value)MapEntry(entry.key,path),
       ];
       const batchSize=8;
       final steps=(photos.length+batchSize-1)~/batchSize;
       for(var i=0;i<photos.length;i+=batchSize){
         final chunk=photos.skip(i).take(batchSize);
         final subset=<String,List<String>>{
           for(final photo in chunk)photo.key:[photo.value],
         };
         final batch=i~/batchSize;
         await api.upload('waris_stage',{'draft_key':draftKey},subset,
           progress:(value){
             if(mounted)setState(()=>progress=(batch+value)/steps*0.95);
           });
       }
       data['draft_key']=draftKey;
       response=await api.upload('waris',data,{},progress:(value){
         if(mounted)setState(()=>progress=0.95+0.05*value);
       });
     }else{
       if(maxFiles>0&&count>maxFiles){
         throw ApiError('Dokumen belum dapat dikirim. Foto yang telah dipilih tetap tersedia. Silakan coba kembali atau hubungi petugas kelurahan.');
       }
       response=await api.upload('waris',data,mainPhotos,
         progress:(value){if(mounted)setState(()=>progress=value);});
     }
           savedReference='${response['reference']??''}'.trim();
      await saveDraft();
      if(savedReference!.isEmpty)throw ApiError('Nomor pengajuan belum tersedia. Periksa Riwayat Pengajuan.');
      await uploadWitnessDocuments(savedReference!);
      if(mounted){setState(()=>completed=true);await completeDraft();notify(context,'Permohonan dan KTP saksi berhasil disimpan. Nomor: '+savedReference!);}
   }catch(e){
     final raw=e.toString();
     final text=raw.contains('Endpoint tidak tersedia')||
        raw.contains('Persyaratan foto belum lengkap: r4')
       ?'Pengajuan belum dapat dikirim. Silakan coba kembali atau hubungi petugas kelurahan. '
        'Foto yang telah dipilih tetap tersedia dalam formulir.'
       :raw;
     await showIncomplete([savedReference!=null
        ?'Pengajuan '+savedReference!+' sudah tersimpan. KTP saksi belum berhasil ditambahkan. Jangan mengirim pengajuan baru. Gunakan Coba Lengkapi KTP Saksi atau buka Riwayat.'
        :text]);
   }finally{if(mounted)setState(()=>sending=false);}
 }
 @override
 Widget build(BuildContext context) => restoringDraft?const Center(child:CircularProgressIndicator()):ListView(
  padding: const EdgeInsets.fromLTRB(13, 12, 13, 30),
  children: [
   const CikokoPremiumHeader(
    title: 'Pengajuan Ahli Waris',
    subtitle: 'Identitas, foto dokumen, saksi, dan konfirmasi dalam satu layanan.',
    icon: Icons.family_restroom_outlined),
   const SizedBox(height:12),
   Wrap(spacing:8,children:[OutlinedButton.icon(onPressed:sending?null:()=>saveDraft(feedback:true),icon:const Icon(Icons.save_outlined),label:const Text('Simpan Draf')),TextButton(onPressed:sending?null:discardDraft,child:const Text('Hapus Draf'))]),
   if(draftMessage!=null)Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(draftMessage!)),
   CikokoPremiumSurface(child:Row(children:[
    Icon(Icons.verified_user_outlined,
      color:Theme.of(context).colorScheme.primary,size:27),
    const SizedBox(width:12),
    Expanded(child:Text('Seluruh identitas dan foto dokumen akan diperiksa petugas. '
      'Pastikan setiap dokumen terbaca dan sesuai data sebenarnya.',
      style:Theme.of(context).textTheme.bodySmall)),
   ])),
   const SizedBox(height: 13),
   CikokoFlowSection(
    title: '01 · Identitas Pemohon dan Pewaris',
    subtitle: 'Isi data keluarga sesuai dokumen asli.',
    icon: Icons.badge_outlined,
    child: Column(children:[
     for (final e in names.entries)
      Field(e.value,v(e.key),
       lines:e.key=='heirs'||e.key=='address'?3:1,
       date:const ['birthdate','marriage_date','deathdate'].contains(e.key),
       keyboard:e.key=='nik'?TextInputType.number:
        e.key=='phone'?TextInputType.phone:TextInputType.text),
    ]),
   ),
   const CikokoPremiumSection(
     title:'02 · Foto Persyaratan Wajib',
     subtitle:'Setiap foto mempunyai area pratinjau dan tombol ganti.'),
   for (final e in requiredPhotos.entries)
    PhotoInput(key:ValueKey(e.key),label:e.value,
      currentPath:photoFor(e.key),
      onChanged:(file){setState(()=>files[e.key]=[file]);scheduleDraft();}),
   const SizedBox(height: 12),
   const CikokoPremiumSection(title:'03 · Dua Orang Saksi',
     subtitle:'Lengkapi identitas kedua saksi.'),
   for (final e in witnessPhotos.entries)
    PhotoInput(key:ValueKey(e.key),label:e.value,
      currentPath:photoFor(e.key),
      onChanged:(file){setState(()=>files[e.key]=[file]);scheduleDraft();}),
   const SizedBox(height: 12),
   const CikokoPremiumSection(title:'04 · Dokumen Kondisional',
     subtitle:'Lampirkan jika berlaku untuk permohonan Anda.'),
   for (final e in optionalPhotos.entries)
    PhotoInput(key:ValueKey(e.key),label:e.value,
      currentPath:photoFor(e.key),
      onChanged:(file){setState(()=>files[e.key]=[file]);scheduleDraft();}),
   const SizedBox(height: 12),
   CikokoPremiumSurface(child:Column(
    crossAxisAlignment:CrossAxisAlignment.stretch,children:[
     Row(children:[
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       Text('05 · Data Anak',style:Theme.of(context).textTheme.titleMedium),
       Text('Maksimal 10 anak jika diperlukan.',
        style:Theme.of(context).textTheme.bodySmall),
      ])),
      OutlinedButton.icon(
       onPressed:children>=10?null:(){setState(()=>children++);scheduleDraft();},
       icon:const Icon(Icons.add_rounded,size:17),
       label:const Text('Tambah')),
     ]),
     for(var i=1;i<=children;i++)...[
      const SizedBox(height: 12),
      Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[
       Field('Nama anak ke-$i',v('child_name_$i')),
       for (final e in childPhotos.entries)
        PhotoInput(key:ValueKey('child_${i}_${e.key}'),
          label:'${e.value} anak ke-$i',
          currentPath:photoFor('child_${i}_${e.key}'),
          onChanged:(file){setState(()=>files['child_${i}_${e.key}']=[file]);scheduleDraft();}),
      ]))),
     ],
    ])),
   const SizedBox(height: 13),
   CikokoPremiumSurface(child:Column(
    crossAxisAlignment:CrossAxisAlignment.stretch,children:[
     Text('06 · Pernyataan dan Pengiriman',
       style:Theme.of(context).textTheme.titleMedium),
     const SizedBox(height:8),
     CheckboxListTile(
      value:agree,contentPadding:EdgeInsets.zero,
      controlAffinity:ListTileControlAffinity.leading,
      onChanged:sending||completed?null:
       (value)=>setState(()=>agree=value??false),
      title:const Text('Saya menyatakan seluruh data dan foto dokumen '
        'sesuai keadaan sebenarnya.',style:TextStyle(fontSize:12,height:1.4)),
     ),
     if(sending)...[
      LinearProgressIndicator(value:progress>0?progress:null),
      const SizedBox(height:8),
      Text('Mengirim ${(progress*100).toStringAsFixed(0)}%',
        style:Theme.of(context).textTheme.bodySmall),
     ],
     const SizedBox(height: 12),
     FilledButton.icon(
      key:const Key('waris_premium_submit'),
      onPressed:sending||completed?null:send,
      icon:Icon(completed?Icons.check_circle_rounded:
        savedReference!=null?Icons.cloud_upload_outlined:Icons.send_outlined),
      label:Padding(padding:const EdgeInsets.symmetric(vertical:10),
       child:Text(completed?'Pengajuan dan KTP Saksi Tersimpan':
         savedReference!=null?'Coba Lengkapi KTP Saksi':
          'Kirim Permohonan Ahli Waris',
         textAlign:TextAlign.center)),
     ),
    ])),
   const CikokoPageSignature(),
  ],
 );
}
