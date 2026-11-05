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
  const CikokoResidentHero({super.key,required this.name,required this.onService,
    required this.onStatus,required this.onAgenda,required this.onAspirations});

  @override Widget build(BuildContext context)=>Column(children:[
    Container(
      width:double.infinity,
      clipBehavior:Clip.antiAlias,
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(24),
        gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
          colors:[Color(0xFF064C9D),Color(0xFF1596E8)])),
      child:Stack(children:[
        Positioned(right:-35,bottom:-55,child:Container(width:210,height:210,
          decoration:BoxDecoration(shape:BoxShape.circle,
            border:Border.all(color:Colors.white.withValues(alpha:.15),width:38)))),
        Padding(padding:const EdgeInsets.all(20),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('SELAMAT DATANG DI CIKOKO SMART',style:TextStyle(
              color:Color(0xFFDCEEFF),fontSize:10.5,letterSpacing:1.1,fontWeight:FontWeight.w700)),
            const SizedBox(height:10),
            Text('Halo, ${name.trim().isEmpty?'Warga Cikoko':name} 👋',
              maxLines:2,overflow:TextOverflow.ellipsis,
              style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w800)),
            const SizedBox(height:6),
            const Text('Layanan digital warga Kelurahan Cikoko',
              style:TextStyle(color:Color(0xFFE7F3FF),fontSize:12.5)),
            const SizedBox(height:20),
            Container(padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(color:Colors.white,
                borderRadius:BorderRadius.circular(16)),
              child:Row(children:[
                Image.asset('assets/logo.png',width:40,height:40),
                const SizedBox(width:10),
                const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
                  children:[
                    Text('Kelurahan Cikoko',style:TextStyle(color:homeNavy,
                      fontSize:13,fontWeight:FontWeight.w800)),
                    Text('Kecamatan Pancoran · Jakarta Selatan',
                      style:TextStyle(color:homeMuted,fontSize:10.5)),
                  ])),
                const Icon(Icons.verified_rounded,color:Color(0xFF1875D4),size:22),
              ])),
          ])),
      ]),
    ),
    const SizedBox(height:14),
    GridView.count(
      crossAxisCount:2,mainAxisSpacing:12,crossAxisSpacing:12,
      childAspectRatio:1.65,shrinkWrap:true,
      physics:const NeverScrollableScrollPhysics(),
      children:[
        _PremiumQuickAction(icon:Icons.description_outlined,title:'Ajukan Surat',onTap:onService),
        _PremiumQuickAction(icon:Icons.manage_search_rounded,title:'Cek Status Pengajuan',onTap:onStatus),
        _PremiumQuickAction(icon:Icons.calendar_month_outlined,title:'Agenda Kegiatan',onTap:onAgenda),
        _PremiumQuickAction(icon:Icons.campaign_outlined,title:'Aspirasi & Pengaduan',onTap:onAspirations),
      ]),
  ]);
}
class _PremiumQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _PremiumQuickAction({required this.icon,required this.title,required this.onTap});
  @override Widget build(BuildContext context)=>Material(
    color:Colors.white,
    borderRadius:BorderRadius.circular(18),
    child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),
      child:Container(
        padding:const EdgeInsets.all(12),
        decoration:BoxDecoration(border:Border.all(color:homeBorder),
          borderRadius:BorderRadius.circular(18)),
        child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Icon(icon,color:homeBlue,size:28),
          const SizedBox(height:8),
          Text(title,maxLines:2,overflow:TextOverflow.ellipsis,
            textAlign:TextAlign.center,style:const TextStyle(
              color:homeNavy,fontSize:12,fontWeight:FontWeight.w800)),
        ]),
      )),
  );
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
