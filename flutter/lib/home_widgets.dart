import 'premium_ui.dart';
import 'app_settings.dart';
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



class CikokoWelcomeHero extends StatelessWidget {
  final String name, roleName, subtitle;
  const CikokoWelcomeHero({
    super.key,
    required this.name,
    required this.roleName,
    required this.subtitle,
  });

  String get initials {
    final pieces = name.trim().split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty).take(2).toList();
    return pieces.isEmpty
        ? 'C'
        : pieces.map((part) => part.substring(0, 1).toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Pengguna Cikoko' : name.trim();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07346E), Color(0xFF1262C6), Color(0xFF348DE8)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x25114B9A), blurRadius: 19, offset: Offset(0, 7)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(children: [
          const Positioned.fill(child: CikokoCityBackdrop()),
          const Positioned.fill(child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xF109336E), Color(0xD30C438E), Color(0xB11465C0)],
            )),
          )),
          Positioned(
            right: -26,
            top: -51,
            child: Container(
              width: 162,
              height: 162,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33FFFFFF), width: 24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Image.asset('assets/logo.png', width: 34, height: 34, fit: BoxFit.contain),
                const SizedBox(width: 9),
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cikoko SmartAPP', maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 15.5,
                        fontWeight: FontWeight.w800)),
                    Text('Kelurahan Cikoko · Pancoran',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFFE2EEFF), fontSize: 9.5)),
                  ],
                )),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC341),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text('Premium', style: TextStyle(
                    color: Color(0xFF07346E), fontSize: 10,
                    fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 21),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .95),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Color(0x20000000), blurRadius: 9),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFD7EAFF),
                    child: Text(initials, style: const TextStyle(
                      color: Color(0xFF104A9B), fontSize: 21,
                      fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CikokoSettings.tr('Hai, ', 'Hi, ') + displayName,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white,
                        fontSize: 19, fontWeight: FontWeight.w800, height: 1.15)),
                    const SizedBox(height: 4),
                    Text(roleName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFFFD778),
                        fontSize: 11.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFE5F1FF),
                        fontSize: 10.5, height: 1.3)),
                  ],
                )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
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
    CikokoWelcomeHero(name:name,roleName:CikokoSettings.tr('Warga','Resident'),
      subtitle:CikokoSettings.tr('Selamat datang di Cikoko SmartAPP','Welcome to Cikoko SmartAPP')),
    const SizedBox(height:12),
    const CikokoLiveWeather(),
    const SizedBox(height:17),
    GridView.count(crossAxisCount:4,shrinkWrap:true,
     physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:10,
     crossAxisSpacing:7,childAspectRatio:.9,children:[
      _PremiumQuickAction(icon:Icons.description_outlined,title:CikokoSettings.label('Layanan'),onTap:onService,accent:const Color(0xFF8B51D7)),
      _PremiumQuickAction(icon:Icons.send_outlined,title:CikokoSettings.label('Kirim Laporan'),onTap:onAspirations,accent:const Color(0xFFFF9B22)),
      _PremiumQuickAction(icon:Icons.newspaper_outlined,title:CikokoSettings.label('Info & Berita'),onTap:onAgenda,accent:const Color(0xFFB54BD9)),
      _PremiumQuickAction(icon:Icons.auto_awesome_outlined,title:CikokoSettings.label('Inovasi'),onTap:onInnovations,accent:const Color(0xFF35AD5B)),
      _PremiumQuickAction(icon:Icons.calendar_month_outlined,title:CikokoSettings.label('Agenda'),onTap:onAgenda,accent:const Color(0xFFF49A23)),
      _PremiumQuickAction(icon:Icons.manage_search_rounded,title:CikokoSettings.label('Cek Status'),onTap:onStatus,accent:const Color(0xFF2376D5)),
      _PremiumQuickAction(icon:Icons.map_outlined,title:CikokoSettings.label('Wilayah'),onTap:onService,accent:const Color(0xFF14A99D)),
      _PremiumQuickAction(icon:Icons.support_agent_outlined,title:CikokoSettings.label('Bantuan'),onTap:onAspirations,accent:const Color(0xFF9255D4)),
     ]),
    const SizedBox(height:13),
    Material(color:Theme.of(context).colorScheme.primaryContainer,borderRadius:BorderRadius.circular(15),
     child:InkWell(onTap:onService,borderRadius:BorderRadius.circular(15),
      child:Padding(padding:const EdgeInsets.all(14),
       child:Row(children:[
        Container(width:43,height:43,decoration:BoxDecoration(
         color:homeBlue,borderRadius:BorderRadius.circular(12)),
         child:const Icon(Icons.verified_user_outlined,color:Colors.white,size:25)),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
         Text(CikokoSettings.label('Layanan Cepat'),style:TextStyle(color:homeNavy,fontSize:14,fontWeight:FontWeight.w600)),
         SizedBox(height:3),
         Text(CikokoSettings.tr('Urus administrasi lebih mudah dan cepat','Simpler and faster public services'),
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
  if(code==0)return CikokoSettings.tr('Cerah','Clear');
  if(code<=3)return CikokoSettings.tr('Cerah Berawan','Partly Cloudy');
  if(code<=48)return CikokoSettings.tr('Berkabut','Foggy');
  if(code<=67)return CikokoSettings.tr('Hujan','Rainy');
  if(code<=77)return CikokoSettings.tr('Berawan','Cloudy');
  if(code<=82)return CikokoSettings.tr('Hujan','Rainy');
  if(code<=86)return CikokoSettings.tr('Hujan','Rainy');
  if(code>=95)return CikokoSettings.tr('Badai Petir','Thunderstorm');
  return CikokoSettings.tr('Berawan','Cloudy');
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
   return Container(
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),
      decoration:BoxDecoration(color:Theme.of(context).colorScheme.surface,
        borderRadius:BorderRadius.circular(14),
        border:Border.all(color:Theme.of(context).colorScheme.outlineVariant)),
      child:Row(children:[
        Icon(loaded?symbol(code):Icons.cloud_outlined,size:29,
          color:Theme.of(context).colorScheme.primary),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(CikokoSettings.tr('CUACA CIKOKO · PANCORAN','CIKOKO · PANCORAN WEATHER'),style:TextStyle(
            color:Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize:9,fontWeight:FontWeight.w700)),
          const SizedBox(height:3),
          Text(loaded?(temp as num).toStringAsFixed(0)+'°C · '+description(code):
            s.hasError?CikokoSettings.tr('Cuaca belum tersedia','Weather unavailable'):CikokoSettings.tr('Memuat cuaca...','Loading weather...'),
            maxLines:1,overflow:TextOverflow.ellipsis,
            style:TextStyle(fontSize:13,fontWeight:FontWeight.w700,
              color:Theme.of(context).colorScheme.onSurface)),
        ])),
        IconButton(tooltip:CikokoSettings.tr('Muat ulang cuaca','Refresh weather'),
          icon:const Icon(Icons.refresh_rounded,size:19),
          onPressed:()=>setState(()=>pending=fetch())),
      ]),
    );
  });
}


class _PremiumQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color accent;
  const _PremiumQuickAction({
    required this.icon, required this.title, required this.onTap,
    this.accent = homeBlue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(height: 6),
            Flexible(child: Text(
              CikokoSettings.label(title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurface,
                fontSize: 9.6, fontWeight: FontWeight.w700, height: 1.1),
            )),
          ]),
        ),
      ),
    );
  }
}

/// Konsisten untuk semua akun petugas tanpa mengubah izin atau endpoint.
class CikokoStaffHero extends StatelessWidget {
  final String roleName;
  final String accountName;
  final VoidCallback onManagement;
  final VoidCallback onServices;
  const CikokoStaffHero({super.key, required this.roleName,
    required this.onManagement, required this.onServices,
    this.accountName='Petugas Cikoko'});

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
      CikokoWelcomeHero(name:accountName,roleName:roleName,
        subtitle:admin?CikokoSettings.tr('Kelola sistem Cikoko SmartAPP','Manage Cikoko SmartAPP'):CikokoSettings.tr('Status tugas dan pelayanan hari ini','Today’s services and tasks')),
      const SizedBox(height:12),
      const CikokoLiveWeather(),
      const SizedBox(height:16),

      Row(children: [
        for (final card in cards)
          Expanded(child: Container(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 31, height: 31,
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  admin ? Icons.dashboard_customize_outlined : Icons.assignment_outlined,
                  color: card.color, size: 18,
                ),
              ),
              const SizedBox(height: 7),
              Text(CikokoSettings.label(card.title),
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(card.value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14, fontWeight: FontWeight.w800)),
            ]),
          )),
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
      Material(color:Theme.of(context).colorScheme.primaryContainer,borderRadius:BorderRadius.circular(15),
       child:InkWell(onTap:onManagement,borderRadius:BorderRadius.circular(15),
        child:Padding(padding:const EdgeInsets.all(13),child:Row(children:[
         const Icon(Icons.shield_outlined,color:Color(0xFF1769D2),size:26),
         const SizedBox(width:10),
         Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(CikokoSettings.label(admin?'Pusat Pengelolaan Cikoko':'Penanganan Laporan'),
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
          style: TextStyle(fontSize:11,color:Theme.of(context).colorScheme.onSurface)),
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
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      key: Key('service_$title'), onTap: onTap, borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13),
          border: Border.all(color:Theme.of(context).colorScheme.outlineVariant)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 33, height: 37,
            decoration: BoxDecoration(color: accent.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: accent)),
          const SizedBox(width: 8),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(CikokoSettings.label(title), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11.3,
                fontWeight: FontWeight.w800, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(description, style: TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9.6,
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


class CikokoPortalBanner extends StatelessWidget {
  final VoidCallback onOpen;
  const CikokoPortalBanner({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CikokoPalette.navy,
      borderRadius: BorderRadius.circular(19),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('cikoko_portal_banner'),
        onTap: onOpen,
        child: SizedBox(
          height: 117,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/kantor-cikoko.jpg', fit: BoxFit.cover,
              alignment: Alignment.centerRight),
            const DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF082B5D), Color(0xF20B438B),
                  Color(0x302671BC)],
                stops: [0, .62, 1],
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Portal Layanan', style: TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w800)),
                  const Text('Kecamatan Pancoran', style: TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(CikokoSettings.tr(
                    'Layanan administrasi dan informasi dalam satu aplikasi.',
                    'Public services and information in one app.'),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFE2EFFF),
                      fontSize: 10.5, height: 1.3)),
                ],
              ),
            ),
            const Positioned(
              bottom: 10, right: 10,
              child: Icon(Icons.arrow_circle_right_outlined,
                color: Colors.white, size: 23)),
          ]),
        ),
      ),
    );
  }
}

/// Angka rekap dari API publik: tidak membocorkan identitas dan lampiran.
class CikokoLetterCounters extends StatelessWidget {
  final Map<String,int>? counts;
  final void Function(String) onStatusTap;
  const CikokoLetterCounters({super.key,required this.counts,required this.onStatusTap});
  @override
  Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[
      Expanded(child:Text('Status Pelayanan Surat',
        style:TextStyle(fontWeight:FontWeight.w800,
          color:Theme.of(context).colorScheme.onSurface,fontSize:13.5))),
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
            decoration:BoxDecoration(
              color:Theme.of(context).colorScheme.surface,
              border:Border.all(color:Theme.of(context).colorScheme.outlineVariant),
              borderRadius:BorderRadius.circular(13)),
            child:Row(children:[
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(counts==null?'—':'${counts![pair.$1]??0}',
                  style:TextStyle(color:pair.$3,fontSize:19,fontWeight:FontWeight.w900)),
                const SizedBox(height:2),
                Text(pair.$2,maxLines:1,overflow:TextOverflow.ellipsis,
                  style:TextStyle(fontSize:9.6,
                    color:Theme.of(context).colorScheme.onSurface,
                    fontWeight:FontWeight.w600)),
              ])),
              Icon(Icons.chevron_right_rounded,size:16,color:pair.$3),
            ]),
          ))),
        if(pair.$1!='selesai')const SizedBox(width:6),
      ],
    ]),
  ]);
}
