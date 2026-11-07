import 'package:flutter/material.dart';
import 'premium_ui.dart';
import 'api.dart';

/// User-facing labels for the exact capability keys returned by the API.
const cikokoPermissionNames = <String, String>{
  'report:jumantik': 'Kirim Laporan Jumantik',
  'report:kegiatan': 'Kirim Laporan Kegiatan',
  'report:fkdm': 'Kirim Laporan FKDM',
  'report:lmk': 'Kirim Laporan LMK',
  'report:posyandu': 'Kirim Laporan Posyandu',
  'report:pkk': 'Kirim Laporan Dasawisma / PKK',
  'report:kerja_bakti': 'Kirim Laporan Kerja Bakti',
  'report:ppsu': 'Kirim Laporan PPSU',
  'reports:view': 'Lihat Daftar Laporan',
  'reports:verify': 'Verifikasi Laporan',
  'waris:create': 'Ajukan Surat Ahli Waris',
  'waris:view': 'Lihat Permohonan Ahli Waris',
  'waris:verify': 'Verifikasi Ahli Waris',
  'content:create': 'Publikasi Berita dan Pengumuman',
  'archive:create': 'Tambah Arsip Ahli Waris',
  'archive:view': 'Lihat Arsip Ahli Waris',
  'chat:reply': 'Balas Pesan Warga',
  'role:manage': 'Kelola Hak Akses',
};

String cikokoPermissionLabel(String key) =>
    cikokoPermissionNames[key] ?? key.replaceAll(':', ' / ').replaceAll('_', ' ');

String cikokoPermissionGroup(String key) {
  if (key.startsWith('report:')) return 'Pelaporan Wilayah';
  if (key.startsWith('reports:')) return 'Pemantauan & Verifikasi';
  if (key.startsWith('waris:')) return 'Pelayanan Ahli Waris';
  if (key.startsWith('content:') || key.startsWith('archive:')) {
    return 'Publikasi & Arsip';
  }
  if (key.startsWith('chat:')) return 'Komunikasi';
  return 'Layanan Lainnya';
}

class RolePermissionPage extends StatefulWidget {final CikokoApi api;const RolePermissionPage({super.key,required this.api});@override State<RolePermissionPage> createState()=>_RolePermissionPageState();}
class _RolePermissionPageState extends State<RolePermissionPage> {
 Map<String,dynamic>? data;
 String role='asn';
 bool busy=false;
 String? error;
 @override void initState(){super.initState();load();}
 Future<void> load() async {try{final result=await widget.api.call('role_permissions');if(mounted)setState((){data=result;error=null;});}catch(e){if(mounted)setState(()=>error='$e');}}
 bool allowed(String key) {
  final overrides=(data?['overrides'] as List<dynamic>? ?? []);
  for(final o in overrides){if(o['role']==role && o['capability']==key) return o['allowed']==true || o['allowed']==1 || o['allowed']=='1';}
  final defaults=Map<String,dynamic>.from(data?['defaults'] as Map? ??{});
  return (defaults[role] as List<dynamic>? ??[]).contains(key);
 }
 Future<void> change(String key,bool enable)async {
  if(busy)return;setState(()=>busy=true);
  try{await widget.api.call('role_permissions',body:{'role':role,'capability':key,'allowed':enable});await load();}
  catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Gagal menyimpan hak akses: $e')));}
  finally{if(mounted)setState(()=>busy=false);}
 }
 @override Widget build(BuildContext c){if(error!=null)return Center(child:Text('Gagal memuat hak akses: $error'));if(data==null)return const Center(child:CircularProgressIndicator());
  final roles=Map<String,dynamic>.from(data!['roles'] as Map);
  final keys=(data!['keys'] as List<dynamic>).cast<String>().where((e)=>e!='role:manage').toList();
  return ListView(padding:const EdgeInsets.all(14),children:[
   const CikokoPremiumHeader(title:'Hak Akses Petugas',
    subtitle:'Kelola izin setiap peran dengan aman. Admin Utama memiliki akses penuh.',
    icon:Icons.admin_panel_settings_outlined,
    start:Color(0xFF42378A),end:Color(0xFF1769D2)),
   const SizedBox(height:13),
   DropdownButtonFormField<String>(initialValue:role,decoration:const InputDecoration(labelText:'Pilih role'),items:[for(final e in roles.entries)if(e.key!='admin')DropdownMenuItem(value:e.key,child:Text('${e.value}'))],onChanged:busy?null:(r){if(r!=null)setState(()=>role=r);}),
   const SizedBox(height:13),
   for (final category in const [
     'Pelaporan Wilayah', 'Pemantauan & Verifikasi',
     'Pelayanan Ahli Waris', 'Publikasi & Arsip',
     'Komunikasi', 'Layanan Lainnya',
   ]) if (keys.any((key) => cikokoPermissionGroup(key) == category)) ...[
     CikokoPremiumSection(title: category),
     for (final key in keys.where(
         (key) => cikokoPermissionGroup(key) == category))
       Card(child: SwitchListTile(
         dense: true,
         contentPadding: const EdgeInsets.symmetric(
           horizontal: 14, vertical: 3),
         secondary: Icon(Icons.admin_panel_settings_outlined,
           color: Theme.of(context).colorScheme.primary, size: 21),
         title: Text(cikokoPermissionLabel(key),
           style: TextStyle(color: Theme.of(context).colorScheme.onSurface,
             fontSize: 12.5, fontWeight: FontWeight.w700)),
         value: allowed(key),
         onChanged: busy ? null : (value) => change(key, value),
       )),
   ],
   const SizedBox(height:18),const CikokoPageSignature(),
  ]);
 }
}
