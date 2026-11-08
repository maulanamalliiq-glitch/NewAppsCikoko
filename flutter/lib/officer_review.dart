import 'package:flutter/material.dart';
import 'api.dart';
import 'premium_ui.dart';

const cikokoReviewStatusLabels = <String,String>{
  'masuk':'Diterima','proses':'Dalam Proses','revisi':'Perlu Perbaikan',
  'selesai':'Selesai','ditolak':'Ditolak',
};
String cikokoReportLabel(String value) => const <String,String>{
  'kegiatan':'Kegiatan','jumantik':'Jumantik','ppsu':'PPSU','fkdm':'FKDM',
  'lmk':'LMK','pkk':'PKK / Dasawisma','posyandu':'Posyandu',
  'kerja_bakti':'Kerja Bakti','waris':'Ahli Waris','lpj_rt':'LPJ RT','lpj_rw':'LPJ RW','lpj_lmk_a':'LPJ LMK A','lpj_lmk_b':'LPJ LMK B',
}[value] ?? value.replaceAll('_',' ');

class OfficerReportsPage extends StatefulWidget {
  final CikokoApi api;
  const OfficerReportsPage({super.key,required this.api});
  @override State<OfficerReportsPage> createState()=>_OfficerReportsState();
}
class _OfficerReportsState extends State<OfficerReportsPage> {
  final List<Map<String,dynamic>> items=[];
  bool loading=true,moreLoading=false,canVerify=false;
  String? error;
  bool partialSources=false;
  String category='',status='';
  int? next;
  int total=0,revision=0;
  @override void initState(){super.initState();load();}
  Future<void> load({bool more=false}) async {
    if(more && (next==null||moreLoading))return;
    final current=more?revision:++revision;
    setState((){error=null;if(more){moreLoading=true;}else{loading=true;items.clear();next=null;}});
    try {
      final result=await widget.api.callWithParams('officer_reports',{
        if(category.isNotEmpty)'category':category,
        if(status.isNotEmpty)'status':status,
        if(more)'offset':'$next',
      });
      if(!mounted||current!=revision)return;
      setState((){
        items.addAll((result['items'] as List? ?? const []).map((r)=>Map<String,dynamic>.from(r as Map)));
        total=(result['total'] as num?)?.toInt()??items.length;
        next=(result['next_offset'] as num?)?.toInt();
        canVerify=result['can_verify']==true;
        partialSources=result['sources'] is Map && (result['sources'] as Map).values.any((value)=>value==false);
      });
    }catch(e){if(mounted&&current==revision)setState(()=>error=cikokoFormalMessage(e));}
    finally{if(mounted&&current==revision)setState((){loading=false;moreLoading=false;});}
  }
  Future<void> open(Map<String,dynamic> row) async {
    final changed=await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder:(_)=>OfficerReportDetail(api:widget.api,row:row)));
    if(changed==true&&mounted)await load();
  }
  @override Widget build(BuildContext context)=>RefreshIndicator(
    onRefresh:()=>load(),
    child:ListView(padding:const EdgeInsets.all(14),children:[
      CikokoPremiumHeader(title:'Verifikasi Laporan',
        subtitle:canVerify?'Periksa laporan dan catat hasil verifikasi.':'Daftar laporan sesuai kewenangan akun.',
        icon:Icons.fact_check_outlined),
      const SizedBox(height:14),
      DropdownButtonFormField<String>(initialValue:category,
        decoration:const InputDecoration(labelText:'Jenis Laporan'),
        items:[const DropdownMenuItem(value:'',child:Text('Semua Jenis Laporan')),
          for(final key in const ['kegiatan','jumantik','ppsu','fkdm','lmk','pkk','posyandu','kerja_bakti','lpj_rt','lpj_rw','lpj_lmk_a','lpj_lmk_b'])
            DropdownMenuItem(value:key,child:Text(cikokoReportLabel(key)))],
        onChanged:(value){category=value??'';load();}),
      const SizedBox(height:10),
      DropdownButtonFormField<String>(initialValue:status,
        decoration:const InputDecoration(labelText:'Status Laporan'),
        items:[const DropdownMenuItem(value:'',child:Text('Semua Status')),
          for(final entry in cikokoReviewStatusLabels.entries)
            DropdownMenuItem(value:entry.key,child:Text(entry.value))],
        onChanged:(value){status=value??'';load();}),
      const SizedBox(height:16),
      if(loading)const Center(child:CircularProgressIndicator())
      else ...[
        Text('$total laporan',style:Theme.of(context).textTheme.titleMedium),
        if(partialSources)const Padding(padding:EdgeInsets.symmetric(vertical:8),child:Text('Sebagian jenis laporan belum tersedia. Daftar ini menampilkan laporan yang telah terhubung.')),
        if(error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:Column(children:[
          Text(error!,textAlign:TextAlign.center),
          TextButton(onPressed:()=>load(more:items.isNotEmpty),child:const Text('Coba Kembali')),
        ])),
        if(items.isEmpty&&error==null)const CikokoEmptyState(
          icon:Icons.assignment_outlined,title:'Belum ada laporan',
          subtitle:'Laporan sesuai pilihan Anda akan tampil di sini.'),
        for(final row in items)Card(child:ListTile(
          leading:const Icon(Icons.assignment_outlined),
          title:Text(cikokoReportLabel('${row['category']}')),
          subtitle:Text('${row['name']}\n${cikokoDateOnly(row['created_at'])} · ${cikokoReviewStatusLabels[row['status']]??row['status']}\n'
            '${row['rw']==''?'Wilayah belum tercatat':'RW ${row['rw']} · RT ${row['rt']==''?'—':row['rt']}'}'),
          trailing:const Icon(Icons.chevron_right),onTap:()=>open(row))),
        if(next!=null)TextButton(onPressed:moreLoading?null:()=>load(more:true),
          child:Text(moreLoading?'Memuat...':'Muat Laporan Berikutnya')),
      ],
    ]));
}

class OfficerReportDetail extends StatefulWidget {
  final CikokoApi api;
  final Map<String,dynamic> row;
  const OfficerReportDetail({super.key,required this.api,required this.row});
  @override State<OfficerReportDetail> createState()=>_OfficerReportDetailState();
}
class _OfficerReportDetailState extends State<OfficerReportDetail> {
  late Future<Map<String,dynamic>> request;
  final notes=TextEditingController();
  String selected='proses';
  bool saving=false;
  @override void initState(){super.initState();reload();}
  @override void dispose(){notes.dispose();super.dispose();}
  Map<String,String> get params=>{'source':'${widget.row['source']}','id':'${widget.row['id']}'};
  void reload(){request=widget.api.callWithParams('officer_report_detail',params);}
  Future<void> save()async{
    if(saving)return;
    if((selected=='revisi'||selected=='ditolak')&&notes.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Mohon isi catatan perbaikan atau alasan penolakan.')));return;
    }
    final yes=await showDialog<bool>(context:context,builder:(dialog)=>AlertDialog(
      title:const Text('Konfirmasi Verifikasi'),
      content:Text('Simpan hasil verifikasi dengan status ${cikokoReviewStatusLabels[selected]}?'),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialog,false),child:const Text('Batal')),
        FilledButton(onPressed:()=>Navigator.pop(dialog,true),child:const Text('Simpan'))]));
    if(yes!=true||!mounted)return;
    setState(()=>saving=true);
    try{
      await widget.api.call('officer_report_decide',body:{...params,'status':selected,'notes':notes.text.trim(),'revision':(await request)['detail']['revision']});
      if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Hasil verifikasi berhasil disimpan.')));Navigator.pop(context,true);}
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(cikokoFormalMessage(e))));}
    finally{if(mounted)setState(()=>saving=false);}
  }
  Widget field(String label,Object? value)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Column(
    crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:Theme.of(context).textTheme.labelMedium),
      SelectableText(value==null||'$value'.isEmpty?'—':'$value')]));
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Rincian Laporan')),
    body:FutureBuilder<Map<String,dynamic>>(future:request,builder:(context,snapshot){
      if(snapshot.hasError)return Center(child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(cikokoFormalMessage(snapshot.error),textAlign:TextAlign.center),TextButton(onPressed:()=>setState(reload),child:const Text('Coba Kembali'))])));
      if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());
      final result=snapshot.data!;final detail=Map<String,dynamic>.from(result['detail'] as Map);
      final count=(detail['photo_count'] as num?)?.toInt()??0;
      return ListView(padding:const EdgeInsets.all(16),children:[
        CikokoPremiumHeader(title:cikokoReportLabel('${detail['category']}'),subtitle:'Periksa informasi dan dokumentasi laporan.',icon:Icons.assignment_outlined),
        field('Pelapor',detail['name']),field('Status',cikokoReviewStatusLabels[detail['status']]??detail['status']),
        field('Tanggal',cikokoDateOnly(detail['work_date'])),field('Lokasi',detail['address']),
        if('${detail['team']}'.isNotEmpty)field('Tim',detail['team']),
        field('Keterangan',detail['activity']),
        if(detail['financial'] is Map)...[
          field('Periode LPJ',detail['period']),
          field('Status Persetujuan LPJ','${detail['workflow_status']}'.replaceAll('_',' ')),
          const Text('Verifikasi administratif tidak menggantikan persetujuan Ketua dan Bendahara.'),
          for(final entry in const {'opening':'Saldo Awal','income':'Penerimaan','total_expenses':'Total Pengeluaran','closing':'Saldo Akhir'}.entries)
            field(entry.value,'Rp ${detail['financial'][entry.key]??0}'),
          for(final entry in detail['financial']['entries'] as List? ?? const [])
            field('${entry['activity']}','Rp ${entry['amount']} · ${entry['notes']??''}'),
        ],
        for(var index=0;index<count;index++)Padding(padding:const EdgeInsets.symmetric(vertical:8),child:ClipRRect(
          borderRadius:BorderRadius.circular(12),child:Image.network(
            Uri.parse(CikokoApi.root).replace(queryParameters:{'action':'officer_report_photo',...params,'index':'$index'}).toString(),
            headers:widget.api.authHeaders(),fit:BoxFit.contain,
            errorBuilder:(_,e,trace)=>const Padding(padding:EdgeInsets.all(18),child:Text('Foto belum dapat dimuat.'))))),
        if(result['can_verify']==true)...[
          const SizedBox(height:16),
          DropdownButtonFormField<String>(initialValue:selected,decoration:const InputDecoration(labelText:'Hasil Verifikasi'),
            items:[for(final entry in cikokoReviewStatusLabels.entries)DropdownMenuItem(value:entry.key,child:Text(entry.value))],
            onChanged:saving?null:(value)=>setState(()=>selected=value??'proses')),
          const SizedBox(height:12),
          TextField(controller:notes,enabled:!saving,maxLines:3,maxLength:1500,
            decoration:const InputDecoration(labelText:'Catatan Verifikasi',helperText:'Wajib diisi untuk perbaikan atau penolakan.')),
          FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.verified_outlined),label:Text(saving?'Menyimpan...':'Simpan Hasil Verifikasi')),
        ],
        const SizedBox(height:18),Text('Riwayat Verifikasi',style:Theme.of(context).textTheme.titleMedium),
        for(final entry in result['history'] as List? ?? const [])ListTile(
          title:Text(cikokoReviewStatusLabels[entry['status']]??'${entry['status']}'),
          subtitle:Text('${entry['notes']}\n${cikokoDateOnly(entry['created_at'])}')),
      ]);
    }));
}

class TerritoryMonitoringPage extends StatefulWidget {
  final CikokoApi api;
  const TerritoryMonitoringPage({super.key,required this.api});
  @override State<TerritoryMonitoringPage> createState()=>_TerritoryMonitoringState();
}
class _TerritoryMonitoringState extends State<TerritoryMonitoringPage> {
  late Future<Map<String,dynamic>> request;
  @override void initState(){super.initState();request=widget.api.call('territory_monitoring');}
  Future<void> reload()async{setState(()=>request=widget.api.call('territory_monitoring'));try{await request;}catch(_){}}
  @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:reload,child:FutureBuilder<Map<String,dynamic>>(
    future:request,builder:(context,snapshot){
      return ListView(padding:const EdgeInsets.all(14),children:[
        const CikokoPremiumHeader(title:'Monitoring Wilayah',subtitle:'Rekap laporan, LPJ, dan pengajuan Ahli Waris menurut wilayah.',icon:Icons.map_outlined),
        const SizedBox(height:16),
        if(snapshot.hasError)...[
          Text(cikokoFormalMessage(snapshot.error),textAlign:TextAlign.center),
          TextButton(onPressed:reload,child:const Text('Coba Kembali')),
        ]else if(!snapshot.hasData)const Center(child:CircularProgressIndicator())
        else ...[
          CikokoPremiumSurface(child:Text('Total Laporan dan Pengajuan: ${snapshot.data!['total']}',style:Theme.of(context).textTheme.titleMedium)),
          if(snapshot.data!['sources'] is Map && (snapshot.data!['sources'] as Map).values.any((value)=>value==false))
            const Padding(padding:EdgeInsets.symmetric(vertical:8),child:Text('Sebagian jenis laporan belum tersedia. Rekap mencakup layanan yang telah terhubung.')),
          const SizedBox(height:12),
          Wrap(spacing:8,runSpacing:6,children:[
            for(final entry in Map<String,dynamic>.from(snapshot.data!['statuses'] as Map).entries)
              Chip(label:Text('${cikokoReviewStatusLabels[entry.key]??entry.key}: ${entry.value}')),
          ]),
          const SizedBox(height:14),Text('Rekap per Jenis',style:Theme.of(context).textTheme.titleMedium),
          for(final entry in Map<String,dynamic>.from(snapshot.data!['categories'] as Map).entries)
            ListTile(title:Text(cikokoReportLabel(entry.key)),trailing:Text('${entry.value}')),
          const SizedBox(height:12),Text('Rekap RT/RW',style:Theme.of(context).textTheme.titleMedium),
          Text('${snapshot.data!['area_basis']}',style:Theme.of(context).textTheme.bodySmall),
          for(final area in snapshot.data!['areas'] as List)Card(child:ListTile(
            title:Text(area['rw']==''?'Wilayah belum tercatat':'RW ${area['rw']} · RT ${area['rt']==''?'Belum tercatat':area['rt']}'),
            subtitle:Text('Perlu Tindak Lanjut: ${area['pending']} · Selesai: ${area['completed']}'),
            trailing:Text('${area['total']}'))),
          if(snapshot.data!['total']==0)const CikokoEmptyState(icon:Icons.map_outlined,title:'Belum ada data wilayah',subtitle:'Rekap akan tersedia setelah laporan dan pengajuan tercatat.'),
        ],
      ]);
    }));
}
