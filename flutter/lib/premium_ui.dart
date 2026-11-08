import 'app_settings.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared Cikoko SmartAPP visual language. No account permissions or APIs.
abstract final class CikokoPalette {
  static const navy = Color(0xFF10346C);
  static const blue = Color(0xFF1675E5);
  static const sky = Color(0xFFEAF4FF);
  static const border = Color(0xFFE1EAF5);
  static const muted = Color(0xFF61748F);
  static const gold = Color(0xFFFFC34A);
  static const green = Color(0xFF15A783);
  static const purple = Color(0xFF8157D8);
  static const orange = Color(0xFFF29B2C);
  static const rose = Color(0xFFD9538A);
}

/// Always shows the full app name. On compact Android phones it stacks
/// "Cikoko" and "SmartAPP" instead of silently truncating the brand.
class CikokoAppBarIdentity extends StatelessWidget {
  final String roleName;
  const CikokoAppBarIdentity({super.key,required this.roleName});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:(context,constraints) {
      final compact=constraints.maxWidth<178;
      const titleStyle=TextStyle(
        fontSize:15,fontWeight:FontWeight.w800,
        color:Colors.white,height:1.04);
      return Row(mainAxisSize:MainAxisSize.min,children:[
        Image.asset('assets/logo.png',width:30,height:30,fit:BoxFit.contain),
        const SizedBox(width:8),
        Expanded(child:Column(
          mainAxisSize:MainAxisSize.min,
          crossAxisAlignment:CrossAxisAlignment.start,
          children:[
            if(compact)...[
              const Text('Cikoko',maxLines:1,style:titleStyle),
              const Text('SmartAPP',maxLines:1,style:titleStyle),
            ] else
              const Text('Cikoko SmartAPP',maxLines:1,
                overflow:TextOverflow.ellipsis,style:titleStyle),
            const SizedBox(height:2),
            Text(roleName,maxLines:1,overflow:TextOverflow.ellipsis,
              style:const TextStyle(
                fontSize:9.4,color:Color(0xFFE1EDFF),height:1.1)),
          ],
        )),
      ]);
    },
  );
}

/// The approved Kelurahan Cikoko logo. Never substitute a generated C icon.
class CikokoBrandMark extends StatelessWidget {
  final double size;
  const CikokoBrandMark({super.key,this.size=54});
  @override
  Widget build(BuildContext context)=>ClipOval(
    child:Image.asset('assets/logo.png',width:size,height:size,
      fit:BoxFit.contain),
  );
}

/// Full-bleed photo banner. The in-app illustration remains available offline.
class CikokoMonasBackdrop extends StatelessWidget {
 const CikokoMonasBackdrop({super.key});
 @override Widget build(BuildContext context)=>Stack(fit:StackFit.expand,children:[
   const CikokoCityBackdrop(),
   Image.network(
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Jakarta_Panorama.jpg/1280px-Jakarta_Panorama.jpg',
    fit:BoxFit.cover,alignment:const Alignment(.65,0),
    errorBuilder:(_,__,___)=>const SizedBox.shrink(),
   ),
 ]);
}

/// Visual language shared by every screen, including staff-only screens.
/// Decorative waves are painted locally; there are no extra network calls.
class CikokoPremiumHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color start, end;
  final Widget? trailing;
  const CikokoPremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.dashboard_customize_outlined,
    this.start = CikokoPalette.navy,
    this.end = CikokoPalette.blue,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(23),
      boxShadow: [
        BoxShadow(color: end.withValues(alpha: .16),
          blurRadius: 23, offset: const Offset(0, 8)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: Stack(children: [
        Positioned.fill(child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [start, end],
            ),
          ),
        )),
        const Positioned.fill(child: CustomPaint(
          painter: _CikokoHeaderWavePainter(),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 17, 15, 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              width: 49, height: 49,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: .24)),
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white,
                    fontSize: 17, height: 1.2,
                    fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(subtitle, maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE6F3FF),
                    fontSize: 11.5, height: 1.35)),
              ],
            )),
            if (trailing != null) ...[
              const SizedBox(width: 6), trailing!,
            ],
          ]),
        ),
      ]),
    ),
  );
}

class _CikokoHeaderWavePainter extends CustomPainter {
  const _CikokoHeaderWavePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * .95, -h * .16), h * .86, glow);
    final wave = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(w * .38, h)
      ..quadraticBezierTo(w * .74, h * .26, w, h * .65)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, wave);
    final shine = Paint()
      ..color = const Color(0xFFFFD471).withValues(alpha: .50);
    canvas.drawCircle(Offset(w * .89, h * .15), 2.3, shine);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CikokoPremiumSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const CikokoPremiumSurface({
    super.key, required this.child,
    this.padding = const EdgeInsets.all(15),
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: .10)
              : const Color(0xFF1C5DAB).withValues(alpha: .035),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class CikokoSearchLauncher extends StatelessWidget {
  final VoidCallback onTap;
  const CikokoSearchLauncher({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const Key('cikoko_home_search'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0B66D8)
                .withValues(alpha: .07),
                blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(children: [
            Icon(Icons.search_rounded, color: scheme.primary, size: 22),
            const SizedBox(width: 11),
            Expanded(child: Text(
              CikokoSettings.tr('Cari layanan dan informasi...',
                'Find services and information...'),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12,
                color: scheme.onSurfaceVariant),
            )),
            Icon(Icons.tune_rounded,
              size: 19, color: scheme.primary),
          ]),
        ),
      ),
    );
  }
}

/// Primary center destination requested by the Kelurahan: Beranda.
class CikokoHomeOrb extends StatelessWidget {
  final bool selected;
  const CikokoHomeOrb({super.key,this.selected=false});
  @override
  Widget build(BuildContext context)=>Container(
    key:const Key('cikoko_center_beranda'),
    width:45,height:45,
    decoration:BoxDecoration(
      shape:BoxShape.circle,
      gradient:const LinearGradient(
        begin:Alignment.topLeft,
        end:Alignment.bottomRight,
        colors:[Color(0xFF2689F6),Color(0xFF0453BA),Color(0xFF06316F)]),
      border:Border.all(
        color:Colors.white.withValues(alpha:.9),width:2),
      boxShadow:const [
        BoxShadow(color:Color(0x3A1159BC),blurRadius:12,
          offset:Offset(0,3)),
      ]),
    child:const Icon(Icons.home_rounded,color:Colors.white,size:24),
  );
}

class CikokoMenuOrb extends StatelessWidget {
  final bool selected;
  const CikokoMenuOrb({super.key, this.selected = false});
  @override
  Widget build(BuildContext context) => Container(
    width: 43, height: 43,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2689F6), Color(0xFF0453BA), Color(0xFF06316F)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: .90), width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0x3A1159BC),
          blurRadius: 12, offset: Offset(0, 3)),
      ],
    ),
    child: Icon(
      selected ? Icons.dashboard_customize_rounded : Icons.grid_view_rounded,
      color: Colors.white, size: 23,
    ),
  );
}

class CikokoPremiumSection extends StatelessWidget {
 final String title;
 final String? subtitle;
 final Widget? action;
 const CikokoPremiumSection({super.key,required this.title,this.subtitle,this.action});
 @override Widget build(BuildContext context)=>Padding(
  padding:const EdgeInsets.symmetric(vertical:9),
  child:Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
   Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(CikokoSettings.label(title),style:TextStyle(color:Theme.of(context).colorScheme.onSurface,
      fontSize:16,fontWeight:FontWeight.w800)),
    if(subtitle!=null)Padding(padding:const EdgeInsets.only(top:3),
      child:Text(subtitle!,style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant,fontSize:11.5))),
   ])),
   if(action!=null)action!,
  ]));
}

class CikokoPremiumTile extends StatelessWidget {
 final IconData icon;
 final String title,subtitle;
 final Color accent;
 final VoidCallback? onTap;
 const CikokoPremiumTile({super.key,required this.icon,required this.title,
   required this.subtitle,required this.accent,this.onTap});
 @override Widget build(BuildContext context)=>Material(
  color:Theme.of(context).colorScheme.surface,borderRadius:BorderRadius.circular(15),
  child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(15),
    child:Container(
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
      decoration:BoxDecoration(border:Border.all(color:Theme.of(context).colorScheme.outlineVariant),
        borderRadius:BorderRadius.circular(15)),
      child:Row(children:[
        Container(width:39,height:39,
         decoration:BoxDecoration(color:accent.withValues(alpha:.12),
          borderRadius:BorderRadius.circular(11)),
         child:Icon(icon,color:accent,size:21)),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(CikokoSettings.label(title),maxLines:2,overflow:TextOverflow.ellipsis,
            style:TextStyle(color:Theme.of(context).colorScheme.onSurface,
              fontSize:12,fontWeight:FontWeight.w600)),
          const SizedBox(height:3),
          Text(subtitle,maxLines:2,overflow:TextOverflow.ellipsis,
            style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant,fontSize:10.5)),
        ])),
        Icon(Icons.chevron_right_rounded,color:Theme.of(context).colorScheme.onSurfaceVariant,size:18),
      ]),
    )));
}


abstract final class CikokoMenuAccent {
  static Color forRoute(String route) {
    final value = route.toLowerCase();
    if (value.contains('surat') || value.contains('waris') ||
        value.contains('arsip')) return CikokoPalette.blue;
    if (value.contains('laporan') || value.contains('verifikasi') ||
        value.contains('lpj')) return CikokoPalette.purple;
    if (value.contains('akun') || value.contains('role') ||
        value.contains('wilayah')) return CikokoPalette.green;
    if (value.contains('berita') || value.contains('galeri') ||
        value.contains('pengumuman')) return CikokoPalette.orange;
    return CikokoPalette.blue;
  }
}

/// One tappable grid tile for the complete role-filtered Menu screen.
class CikokoMenuGridCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const CikokoMenuGridCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant, width: .9),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 41, width: 41,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accent, size: 23),
            ),
            const SizedBox(height: 8),
            Flexible(child: Text(
              CikokoSettings.label(title),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 11.4,
                height: 1.17,
                fontWeight: FontWeight.w700,
              ),
            )),
          ]),
        ),
      ),
    );
  }
}

class CikokoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const CikokoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 29),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface, fontSize: 14,
              fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant,
                fontSize: 11.5, height: 1.4)),
          ],
          if (action != null) ...[
            const SizedBox(height: 14),
            action!,
          ],
        ]),
      ),
    );
  }
}

class CikokoStageIndicator extends StatelessWidget {
 final int current;
 final List<String> labels;
 const CikokoStageIndicator({super.key,required this.current,required this.labels});
 @override Widget build(BuildContext context)=>Row(children:[
  for(var i=0;i<labels.length;i++)...[
    if(i>0)Expanded(child:Container(height:2,color:i<=current?
      CikokoPalette.blue:Theme.of(context).colorScheme.outlineVariant)),
    Column(children:[
      CircleAvatar(radius:13,backgroundColor:i<=current?
       CikokoPalette.blue:Theme.of(context).colorScheme.surfaceContainerHigh,
       child:Text('${i+1}',style:TextStyle(fontSize:11,
         color:i<=current?Colors.white:Theme.of(context).colorScheme.onSurfaceVariant,
         fontWeight:FontWeight.w600))),
      const SizedBox(height:4),
      Text(labels[i],style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant,fontSize:10)),
    ]),
  ],
 ]);
}

 
/// Lightweight in-app Jakarta skyline artwork for the public and sign-in headers.
/// Drawn natively so no network image or new backend endpoint is needed.
class CikokoCityBackdrop extends StatelessWidget {
 const CikokoCityBackdrop({super.key});
 @override Widget build(BuildContext context)=>const CustomPaint(
  painter:_CikokoCityPainter(),child:SizedBox.expand());
}
class _CikokoCityPainter extends CustomPainter {
 const _CikokoCityPainter();
 @override void paint(Canvas canvas,Size size) {
  final w=size.width,h=size.height;
  canvas.drawRect(Offset.zero & size,Paint()..shader=
   const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,
    colors:[Color(0xFF1F85ED),Color(0xFF7FC5FB),Color(0xFFBCE8FB)])
    .createShader(Offset.zero & size));
  // Soft clouds
  final cloud=Paint()..color=Colors.white.withValues(alpha:.49);
  for(final c in <(double,double,double)>[(.12,.19,.19),(.75,.14,.23),(.85,.37,.17)]){
   final x=w*c.$1,y=h*c.$2,r=h*c.$3*.31;
   canvas.drawOval(Rect.fromCenter(center:Offset(x,y),width:r*3.3,height:r),cloud);
   canvas.drawCircle(Offset(x-r*.35,y-r*.3),r*.7,cloud);
   canvas.drawCircle(Offset(x+r*.5,y-r*.2),r*.58,cloud);
  }
  // High-rise skyline in layered blues
  final far=Paint()..color=const Color(0xFF98C5E6).withValues(alpha:.90);
  final near=Paint()..color=const Color(0xFF4B98CC);
  final buildings=<(double,double,double,double)>[
   (.02,.53,.075,.43),(.11,.46,.10,.49),(.24,.58,.085,.39),
   (.33,.39,.105,.59),(.61,.47,.085,.50),(.71,.35,.095,.63),
   (.82,.56,.090,.43),(.92,.45,.090,.50)];
  for(var i=0;i<buildings.length;i++){
   final b=buildings[i];
   canvas.drawRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w*b.$1,h*b.$2,w*b.$3,h*b.$4),const Radius.circular(2)),
    i.isEven?far:near);
  }
  final windows=Paint()..color=const Color(0xFFE4F4FF).withValues(alpha:.58);
  for(final b in buildings){
   final x=w*b.$1,y=h*b.$2,bw=w*b.$3,bh=h*b.$4;
   for(var r=0;r<6;r++)for(var col=0;col<3;col++){
    final yy=y+7+r*bh/8,xx=x+5+col*bw/4;
    if(yy<h*.95&&xx<x+bw-3)
     canvas.drawRect(Rect.fromLTWH(xx,yy,math.max(1.2,bw*.10),2),windows);
   }
  }
  // Monument-inspired central landmark and golden flame
  final cx=w*.51,base=h*.88;
  final monument=Paint()..color=const Color(0xFFF6FBFF);
  final shadow=Paint()..color=const Color(0xFFD3E6F5);
  final shaft=Path()..moveTo(cx-w*.017,base)
    ..lineTo(cx-w*.008,h*.25)..lineTo(cx+w*.008,h*.25)
    ..lineTo(cx+w*.018,base)..close();
  canvas.drawPath(shaft,monument);
  canvas.drawPath(Path()..moveTo(cx-w*.018,base)
    ..lineTo(cx-w*.007,h*.29)..lineTo(cx,h*.31)
    ..lineTo(cx,base)..close(),shadow);
  canvas.drawRect(Rect.fromLTWH(cx-w*.08,base-h*.02,w*.16,h*.04),
   Paint()..color=const Color(0xFFF8FCFF));
  canvas.drawRect(Rect.fromLTWH(cx-w*.048,h*.225,w*.096,h*.025),monument);
  final flame=Path()..moveTo(cx,h*.09)
    ..quadraticBezierTo(cx+w*.03,h*.15,cx+w*.012,h*.21)
    ..quadraticBezierTo(cx,h*.24,cx-w*.018,h*.20)
    ..quadraticBezierTo(cx-w*.017,h*.16,cx,h*.09)
    ..close();
  canvas.drawPath(flame,Paint()..color=const Color(0xFFFFC33E));
  canvas.drawCircle(Offset(cx-w*.005,h*.18),w*.006,
   Paint()..color=const Color(0xFFFFE991));
  // Park shrubs and walkway bring the illustration toward the viewer
  canvas.drawRect(Rect.fromLTWH(0,h*.88,w,h*.12),
   Paint()..color=const Color(0xFF89C8A7));
  final trees=Paint()..color=const Color(0xFF32987D);
  for(final x in [.04,.15,.26,.78,.89,.97]){
   final xx=w*x;
   canvas.drawRect(Rect.fromLTWH(xx-2,h*.81,4,h*.12),
    Paint()..color=const Color(0xFF887C60));
   canvas.drawCircle(Offset(xx,h*.79),h*.065,trees);
   canvas.drawCircle(Offset(xx-h*.038,h*.80),h*.046,
    Paint()..color=const Color(0xFF51B48D));
  }
  final road=Path()..moveTo(w*.38,h)..lineTo(w*.46,h*.87)
   ..lineTo(w*.56,h*.87)..lineTo(w*.64,h)..close();
  canvas.drawPath(road,Paint()..color=const Color(0xFFF2F5E8));
 }
 @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}

class CikokoPremiumCanvas extends StatelessWidget {
 final Widget child;
 const CikokoPremiumCanvas({super.key,required this.child});
 @override Widget build(BuildContext context)=>DecoratedBox(
  decoration:BoxDecoration(gradient:LinearGradient(
   begin:Alignment.topCenter,end:Alignment.bottomCenter,
   colors:Theme.of(context).brightness==Brightness.dark
    ?const [Color(0xFF0A1628),Color(0xFF101C2E),Color(0xFF0C1627)]
    :const [Color(0xFFEFF6FF),Color(0xFFF6F9FF),Color(0xFFF7FAFD)],
   stops:const [0,.33,1])),
  child:Center(child:ConstrainedBox(
   constraints:const BoxConstraints(maxWidth:820),child:child)));
}

class CikokoPageSignature extends StatelessWidget {
 const CikokoPageSignature({super.key});
 @override Widget build(BuildContext context)=>Padding(
  padding:const EdgeInsets.fromLTRB(10,20,10,24),
  child:Text('Copyright © Cikoko Smart',textAlign:TextAlign.center,
   style:TextStyle(fontSize:10.5,
    color:Theme.of(context).colorScheme.onSurfaceVariant,
    fontWeight:FontWeight.w400)));
}

class CikokoStatusBadge extends StatelessWidget {
  final String status;
  const CikokoStatusBadge({super.key, required this.status});

  static bool isReturned(String raw) {
    final status = raw.toLowerCase();
    return status.contains('return') || status.contains('kembali');
  }

  static bool isRejected(String raw) {
    final status = raw.toLowerCase();
    return status.contains('tolak') || status.contains('reject');
  }

  static bool isComplete(String raw) {
    final status = raw.toLowerCase();
    return status.contains('selesai') ||
        status.contains('approved') ||
        status.contains('disetujui') ||
        status.contains('complete') ||
        status.contains('terverifikasi');
  }

  static Color accentFor(String status) {
    if (isRejected(status)) return const Color(0xFFDC3558);
    if (isReturned(status)) return const Color(0xFFB67A00);
    if (isComplete(status)) return const Color(0xFF15985B);
    return const Color(0xFFB67A00);
  }

  @override
  Widget build(BuildContext context) {
    final rejected = isRejected(status);
    final returned = isReturned(status);
    final completed = isComplete(status);
    final accent = accentFor(status);
    final label = rejected ? 'Ditolak'
        : returned ? 'Perlu Perbaikan'
        : completed ? 'Selesai' : 'Dalam Proses';
    final fill = rejected ? const Color(0xFFFFE4EA)
        : completed ? const Color(0xFFDCF9E9)
        : const Color(0xFFFFF1BC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(rejected ? Icons.cancel_rounded
          : returned ? Icons.edit_note_rounded
          : completed ? Icons.check_circle_rounded : Icons.schedule_rounded,
          color: accent, size: 16),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          color: accent, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
