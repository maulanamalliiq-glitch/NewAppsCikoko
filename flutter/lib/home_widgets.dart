import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

const Color homeNavy = Color(0xff10375f);
const Color homeBlue = Color(0xff226fda);
const Color homeMuted = Color(0xff657b91);
const Color homeBorder = Color(0xffe0e8f1);

/// Beranda native: visual konsisten dengan halaman depan website Kelurahan Cikoko.
class CikokoOfficeHero extends StatelessWidget {
  final VoidCallback onService;
  final VoidCallback onProfile;
  const CikokoOfficeHero({super.key, required this.onService, required this.onProfile});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      height: 204,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/kantor-cikoko.jpg', fit: BoxFit.cover,
          alignment: const Alignment(.18, 0)),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [Color(0xee0b2b4b), Color(0xcb102e4c), Color(0x5b0c2748)],
          stops: [0, .68, 1],
        ))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x443ca8f5), borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0x668bc1ee))),
              child: const Text('LAYANAN DIGITAL KELURAHAN',
                style: TextStyle(fontSize: 9.5, letterSpacing: .65, fontWeight: FontWeight.w700, color: Color(0xffe2f1ff)))),
            const SizedBox(height: 10),
            const Text('Kelurahan Cikoko',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white, height: 1.12)),
            const SizedBox(height: 3),
            const Text('Kecamatan Pancoran · Jakarta Selatan',
              style: TextStyle(fontSize: 10.6, fontWeight: FontWeight.w600, color: Color(0xffe4eef8))),
            const SizedBox(height: 9),
            const Text('Melayani dengan hati, membangun bersama untuk Cikoko yang lebih maju, bersih dan sejahtera.',
              style: TextStyle(fontSize: 11.2, height: 1.4, color: Color(0xffe3edf8)), maxLines: 2,
              overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(children: [
              Flexible(child: SizedBox(height: 33, child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: homeBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  padding: const EdgeInsets.symmetric(horizontal: 10)),
                onPressed: onService,
                icon: const Icon(Icons.widgets_outlined, size: 14),
                label: const Text('Layanan Online', maxLines: 1, style: TextStyle(fontSize: 10.3, fontWeight: FontWeight.w700)),
              ))),
              const SizedBox(width: 7),
              Flexible(child: SizedBox(height: 33, child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x99e7f0fb)),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
                onPressed: onProfile,
                child: const Text('Profil Kelurahan', maxLines: 1, style: TextStyle(fontSize: 10.2, fontWeight: FontWeight.w700)),
              ))),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

/// Beranda warga premium: identitas kelurahan, sapaan, dan empat akses utama.
class CikokoResidentHero extends StatelessWidget {
  final String name;
  final VoidCallback onService;
  final VoidCallback onStatus;
  final VoidCallback onAgenda;
  final VoidCallback onAspirations;
  final VoidCallback onInnovations;
  const CikokoResidentHero({super.key,required this.name,required this.onService,
    required this.onStatus,required this.onAgenda,required this.onAspirations,
    required this.onInnovations});

  @override
  Widget build(BuildContext context) => Column(
   crossAxisAlignment:CrossAxisAlignment.start,children:[
    Padding(padding:const EdgeInsets.fromLTRB(3,5,3,13),
     child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Hai, ${name.trim().isEmpty ? 'Warga Cikoko' : name}',
       maxLines:2,overflow:TextOverflow.ellipsis,
       style:const TextStyle(color:homeNavy,fontSize:23,fontWeight:FontWeight.w700)),
      const SizedBox(height:3),
      const Text('Selamat datang di Cikoko SmartAPP',
       style:TextStyle(color:homeMuted,fontSize:12)),
     ])),
    Container(height:143,width:double.infinity,
     decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),
      gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
       colors:[Color(0xFF0D48A5),Color(0xFF2288ED)]),
      boxShadow:[BoxShadow(color:homeBlue.withValues(alpha:.14),blurRadius:14,offset:const Offset(0,5))]),
     child:Stack(children:[
      Positioned(right:-15,bottom:-44,child:Icon(Icons.cloud_rounded,
       size:173,color:Colors.white.withValues(alpha:.10))),
      const Padding(padding:EdgeInsets.fromLTRB(16,12,16,12),
       child:CikokoLiveWeather()),
     ])),
    const SizedBox(height:17),
    GridView.count(crossAxisCount:4,shrinkWrap:true,
     physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:10,
     crossAxisSpacing:7,childAspectRatio:.9,children:[
      _PremiumQuickAction(icon:Icons.description_outlined,title:'Layanan',onTap:onService,accent:const Color(0xFF8B51D7)),
      _PremiumQuickAction(icon:Icons.send_outlined,title:'Kirim Laporan',onTap:onAspirations,accent:const Color(0xFFFF9B22)),
      _PremiumQuickAction(icon:Icons.newspaper_outlined,title:'Info & Berita',onTap:onAgenda,accent:const Color(0xFFB54BD9)),
      _PremiumQuickAction(icon:Icons.auto_awesome_outlined,title:'Inovasi',onTap:onInnovations,accent:const Color(0xFF35AD5B)),
      _PremiumQuickAction(icon:Icons.calendar_month_outlined,title:'Agenda',onTap:onAgenda,accent:const Color(0xFFF49A23)),
      _PremiumQuickAction(icon:Icons.manage_search_rounded,title:'Cek Status',onTap:onStatus,accent:const Color(0xFF2376D5)),
      _PremiumQuickAction(icon:Icons.map_outlined,title:'Wilayah',onTap:onService,accent:const Color(0xFF14A99D)),
      _PremiumQuickAction(icon:Icons.support_agent_outlined,title:'Bantuan',onTap:onAspirations,accent:const Color(0xFF9255D4)),
     ]),
    const SizedBox(height:13),
    Material(color:const Color(0xFFE4F1FF),borderRadius:BorderRadius.circular(15),
     child:InkWell(onTap:onService,borderRadius:BorderRadius.circular(15),
      child:Padding(padding:const EdgeInsets.all(14),
       child:Row(children:[
        Container(width:43,height:43,decoration:BoxDecoration(
         color:homeBlue,borderRadius:BorderRadius.circular(12)),
         child:const Icon(Icons.verified_user_outlined,color:Colors.white,size:25)),
        const SizedBox(width:12),
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
         Text('Layanan Cepat',style:TextStyle(color:homeNavy,fontSize:14,fontWeight:FontWeight.w600)),
         SizedBox(height:3),
         Text('Urus administrasi lebih mudah dan cepat',
          style:TextStyle(color:homeMuted,fontSize:10.5)),
        ])),
        const Icon(Icons.chevron_right_rounded,color:homeBlue),
       ])))),
   ]);

}

/// Weather is fetched at runtime; no demo temperature is shown as live data.
class CikokoLiveWeather extends StatefulWidget {
 const CikokoLiveWeather({super.key});
 @override State<CikokoLiveWeather> createState()=>_CikokoLiveWeatherState();
}
class _CikokoLiveWeatherState extends State<CikokoLiveWeather> {
 late Future<Map<String,dynamic>> pending;
 Timer? refreshTimer;
 @override void initState(){
  super.initState();
  pending=fetch();
  refreshTimer=Timer.periodic(const Duration(minutes:15),(_){
    if(mounted)setState(()=>pending=fetch());
  });
 }
 @override void dispose(){refreshTimer?.cancel();super.dispose();}
 Future<Map<String,dynamic>> fetch() async {
  final uri=Uri.parse('https://api.open-meteo.com/v1/forecast'
    '?latitude=-6.243&longitude=106.846'
    '&current=temperature_2m,weather_code,relative_humidity_2m'
    '&timezone=Asia%2FJakarta');
  final response=await http.get(uri).timeout(const Duration(seconds:12));
  if(response.statusCode!=200)throw const FormatException('Layanan cuaca tidak tersedia');
  final data=jsonDecode(utf8.decode(response.bodyBytes));
  if(data is! Map||data['current'] is! Map)throw const FormatException('Data cuaca tidak lengkap');
  final now=Map<String,dynamic>.from(data['current'] as Map);
  if(now['temperature_2m'] is! num)throw const FormatException('Suhu belum tersedia');
  return now;
 }
 String description(int code){
  if(code==0)return 'Cerah';
  if(code<=3)return 'Cerah Berawan';
  if(code<=48)return 'Berkabut';
  if(code<=67)return 'Hujan';
  if(code<=77)return 'Berawan';
  if(code<=82)return 'Hujan';
  if(code<=86)return 'Hujan';
  if(code>=95)return 'Badai Petir';
  return 'Berawan';
 }
 IconData symbol(int code){
  if(code==0)return Icons.wb_sunny_rounded;
  if(code<=3)return Icons.wb_cloudy_rounded;
  if(code>=95)return Icons.thunderstorm_rounded;
  if(code>=51&&code<=86)return Icons.water_drop_rounded;
  return Icons.cloud_rounded;
 }
 @override Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(
  future:pending,builder:(ctx,s){
   final loaded=s.hasData;
   final value=s.data;
   final temp=value?['temperature_2m'];
   final code=(value?['weather_code'] is num)
    ?(value!['weather_code'] as num).toInt():2;
   final time='${value?['time']??''}';
   return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Row(children:[
     Icon(Icons.place_outlined,size:15,color:Color(0xFFFFD56D)),
     SizedBox(width:5),
     Text('Cikoko, Pancoran',style:TextStyle(color:Colors.white,
      fontSize:11.5,fontWeight:FontWeight.w700)),
    ]),
    const Spacer(),
    Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
     Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      if(loaded)...[
       Text('${(temp as num).toStringAsFixed(0)}°C',
        style:const TextStyle(fontSize:33,color:Colors.white,
         height:1,fontWeight:FontWeight.w900)),
       const SizedBox(height:4),
       Text(description(code),style:const TextStyle(
        fontSize:11.5,color:Colors.white,fontWeight:FontWeight.w600)),
      ] else ...[
       Text(s.hasError?'Cuaca tidak tersedia':'Memuat cuaca...',
        style:const TextStyle(fontSize:15,color:Colors.white,
         fontWeight:FontWeight.w700)),
       const SizedBox(height:4),
       const Text('Data aktual, bukan suhu contoh',
        style:TextStyle(fontSize:10,color:Color(0xFFE2F3FF))),
      ],
     ])),
     Icon(loaded?symbol(code):Icons.cloud_outlined,size:52,
      color:const Color(0xFFFFE398)),
    ]),
    const SizedBox(height:7),
    Row(children:[
     Expanded(child:Text(loaded&&time.length>=16
      ?'Diperbarui ${time.substring(11,16)} WIB • Open-Meteo'
      :'Sumber: Open-Meteo',
      style:const TextStyle(fontSize:9,color:Color(0xFFD5ECFF)))),
     InkWell(onTap:()=>setState(()=>pending=fetch()),
      child:const Icon(Icons.refresh_rounded,color:Colors.white,size:19)),
    ]),
   ]);
  });
}

class _PremiumQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color accent;
  const _PremiumQuickAction({required this.icon,required this.title,
   required this.onTap,this.accent=homeBlue});
  @override
  Widget build(BuildContext context)=>Material(color:Colors.transparent,
   child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),
    child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
     Container(width:43,height:43,
      decoration:BoxDecoration(color:accent.withValues(alpha:.13),
       borderRadius:BorderRadius.circular(13)),
      child:Icon(icon,color:accent,size:24)),
     const SizedBox(height:7),
     Text(title,maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,
      style:const TextStyle(color:homeNavy,fontSize:10.3,fontWeight:FontWeight.w500,height:1.2)),
    ])));

}

/// Konsisten untuk semua akun petugas tanpa mengubah izin atau endpoint.
class CikokoStaffHero extends StatelessWidget {
  final String roleName;
  final VoidCallback onManagement;
  final VoidCallback onServices;
  const CikokoStaffHero({super.key, required this.roleName,
    required this.onManagement, required this.onServices});

  @override
  Widget build(BuildContext context) {
    final admin=roleName.toLowerCase().contains('admin');
    final cards=admin
      ? <({String title,String value,Color color})>[
          (title:'Pengguna',value:'Kelola',color:const Color(0xFF6653CC)),
          (title:'Laporan',value:'Pantau',color:const Color(0xFFD34D8B)),
          (title:'Layanan',value:'Atur',color:const Color(0xFF2585E8)),
        ]
      : <({String title,String value,Color color})>[
          (title:'Laporan Baru',value:'Periksa',color:const Color(0xFFE45D72)),
          (title:'Dalam Proses',value:'Tindak lanjut',color:const Color(0xFF168ED4)),
          (title:'Selesai',value:'Riwayat',color:const Color(0xFF0FAE94)),
        ];
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:const EdgeInsets.fromLTRB(3,7,3,14),
       child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(admin?'Hai, Administrator':'Hai, Petugas',
          style:const TextStyle(color:homeNavy,fontSize:23,fontWeight:FontWeight.w700)),
        const SizedBox(height:3),
        Text(admin?'Kelola sistem Cikoko SmartAPP':'Status tugas dan pelayanan hari ini',
          style:const TextStyle(color:homeMuted,fontSize:12)),
       ])),
      Row(children:[
        for(final card in cards)
         Expanded(child:Container(
          margin:const EdgeInsets.only(right:7),
          padding:const EdgeInsets.symmetric(horizontal:10,vertical:13),
          decoration:BoxDecoration(
           color:card.color,borderRadius:BorderRadius.circular(13),
           boxShadow:[BoxShadow(color:card.color.withValues(alpha:.16),
             blurRadius:9,offset:const Offset(0,4))]),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
           Text(card.title,maxLines:1,overflow:TextOverflow.ellipsis,
            style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w500)),
           const SizedBox(height:7),
           Text(card.value,maxLines:1,overflow:TextOverflow.ellipsis,
            style:const TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.w700)),
          ]))),
      ]),
      const SizedBox(height:15),
      Row(children:[
       Expanded(child:_StaffAction(icon:admin?Icons.manage_accounts_outlined:Icons.assignment_outlined,
        title:admin?'Manajemen Pengguna':'Daftar Laporan',
        subtitle:admin?'Warga, petugas & pegawai':'Kelola laporan masuk',
        color:const Color(0xFF3479D8),onTap:onManagement)),
       const SizedBox(width:9),
       Expanded(child:_StaffAction(icon:Icons.description_outlined,
        title:admin?'Manajemen Layanan':'Layanan Administrasi',
        subtitle:admin?'Tambah & kelola layanan':'Pelayanan warga',
        color:const Color(0xFF13A58B),onTap:onServices)),
      ]),
      const SizedBox(height:12),
      Material(color:const Color(0xFFE5F2FF),borderRadius:BorderRadius.circular(15),
       child:InkWell(onTap:onManagement,borderRadius:BorderRadius.circular(15),
        child:Padding(padding:const EdgeInsets.all(13),child:Row(children:[
         const Icon(Icons.shield_outlined,color:Color(0xFF1769D2),size:26),
         const SizedBox(width:10),
         Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(admin?'Pusat Pengelolaan Cikoko':'Penanganan Laporan',
           style:const TextStyle(color:homeNavy,fontSize:13,fontWeight:FontWeight.w600)),
          const SizedBox(height:2),
          const Text('Cepat, tepat, dan terpantau',
           style:TextStyle(color:homeMuted,fontSize:11)),
         ])),
         const Icon(Icons.chevron_right_rounded,color:homeBlue),
        ])))),
    ]);
  }
}
class _StaffAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _StaffAction({required this.icon, required this.title,
    required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        leading: Icon(icon, color: color, size: 22),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: homeNavy)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9.5, color: homeMuted)),
      ),
    );
  }
}

/// Kategori pelayanan pada website, diterjemahkan menjadi kartu Flutter.
class CikokoServiceTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  const CikokoServiceTile({super.key, required this.title, required this.description,
    required this.icon, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      key: Key('service_$title'), onTap: onTap, borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13),
          border: Border.all(color: homeBorder)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 33, height: 37,
            decoration: BoxDecoration(color: accent.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: accent)),
          const SizedBox(width: 8),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: homeNavy, fontSize: 11.3,
                fontWeight: FontWeight.w800, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(description, style: const TextStyle(color: homeMuted, fontSize: 9.6,
                height: 1.18), maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
          const SizedBox(width: 3),
          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: accent),
        ]),
      ),
    ),
  );
}

class CikokoQuickMenu extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const CikokoQuickMenu({super.key,required this.title, required this.icon,required this.onTap});
  @override
  Widget build(BuildContext context) => CikokoServiceTile(
    title: title, description: 'Buka layanan', icon: icon, accent: homeBlue,
    onTap: onTap,
  );
}

/// Angka rekap dari API publik: tidak membocorkan identitas dan lampiran.
class CikokoLetterCounters extends StatelessWidget {
  final Map<String,int>? counts;
  final void Function(String) onStatusTap;
  const CikokoLetterCounters({super.key,required this.counts,required this.onStatusTap});
  @override
  Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[
      const Expanded(child:Text('Status Pelayanan Surat',
        style:TextStyle(fontWeight:FontWeight.w800,color:homeNavy,fontSize:13.5))),
      TextButton(onPressed:()=>onStatusTap('all'),
        child:const Text('Lihat Status →',style:TextStyle(fontSize:11.2,fontWeight:FontWeight.w700))),
    ]),
    Row(children:[
      for(final pair in const [
        ('masuk','Surat Masuk',Color(0xff2467ba)),
        ('proses','Diproses',Color(0xffd58823)),
        ('selesai','Selesai',Color(0xff17875a)),
      ]) ...[
        Expanded(child:InkWell(onTap:()=>onStatusTap(pair.$1),
          borderRadius:BorderRadius.circular(11),
          child:Container(
            padding:const EdgeInsets.symmetric(horizontal:10,vertical:9),
            decoration:BoxDecoration(color:Colors.white,border:Border.all(color:homeBorder),
              borderRadius:BorderRadius.circular(11)),
            child:Row(children:[
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(counts==null?'—':'${counts![pair.$1]??0}',
                  style:TextStyle(color:pair.$3,fontSize:19,fontWeight:FontWeight.w900)),
                const SizedBox(height:2),
                Text(pair.$2,maxLines:1,overflow:TextOverflow.ellipsis,
                  style:const TextStyle(fontSize:9.6,color:homeNavy,fontWeight:FontWeight.w600)),
              ])),
              Icon(Icons.chevron_right_rounded,size:16,color:pair.$3),
            ]),
          ))),
        if(pair.$1!='selesai')const SizedBox(width:6),
      ],
    ]),
  ]);
}
