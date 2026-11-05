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

class CikokoBrandMark extends StatelessWidget {
  final double size;
  const CikokoBrandMark({super.key,this.size=54});
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension:size,child:CustomPaint(painter:const _CikokoMarkPainter()));
}
class _CikokoMarkPainter extends CustomPainter {
  const _CikokoMarkPainter();
  @override
  void paint(Canvas canvas,Size size) {
    final rect=Rect.fromLTWH(size.width*.18,size.height*.16,size.width*.65,size.height*.68);
    final paint=Paint()..style=PaintingStyle.stroke..strokeWidth=size.width*.19
      ..strokeCap=StrokeCap.round
      ..shader=const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[Color(0xFF07469C),Color(0xFF1B7CEC),Color(0xFF06468F)])
        .createShader(Offset.zero & size);
    canvas.drawArc(rect,math.pi*.25,math.pi*1.50,false,paint);
    final accent=Paint()..style=PaintingStyle.stroke..strokeWidth=size.width*.125
      ..strokeCap=StrokeCap.round..color=CikokoPalette.gold;
    canvas.drawArc(rect.deflate(size.width*.04),math.pi*.95,math.pi*.53,false,accent);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
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

class CikokoGuestHero extends StatelessWidget {
 final VoidCallback onLogin,onRegister,onServices,onNews,onInnovations,onAbout;
 const CikokoGuestHero({super.key,required this.onLogin,required this.onRegister,
  required this.onServices,required this.onNews,required this.onInnovations,
  required this.onAbout});
 @override Widget build(BuildContext context)=>Column(children:[
   SizedBox(height:252,width:double.infinity,child:Stack(fit:StackFit.expand,children:[
    const CikokoMonasBackdrop(),
    const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
      begin:Alignment.topCenter,end:Alignment.bottomCenter,
      colors:[Color(0x0810479B),Color(0x0010479B),Color(0x442063AC)]))),
    Positioned(top:14,left:18,child:Container(
      padding:const EdgeInsets.symmetric(horizontal:13,vertical:7),
      decoration:BoxDecoration(color:Colors.white.withValues(alpha:.94),
       borderRadius:BorderRadius.circular(24)),
      child:const Text('KELURAHAN CIKOKO  ·  PANCORAN',
        style:TextStyle(fontSize:10,color:CikokoPalette.navy,fontWeight:FontWeight.w800)))),
    Positioned(bottom:5,right:7,child:Text('Monas • G. Kartapranata / CC BY-SA 3.0',
      style:TextStyle(fontSize:7.5,color:Colors.white,
        shadows:[Shadow(color:Colors.black,blurRadius:3)]))),
   ])),
   Container(width:double.infinity,
    padding:const EdgeInsets.fromLTRB(19,14,19,0),
    decoration:const BoxDecoration(color:Color(0xFFF6F9FF)),
    child:Column(children:[
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
       Container(width:67,height:67,
        decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),
         boxShadow:[BoxShadow(color:Color(0x1C2076CC),blurRadius:13)]),
        child:const Center(child:CikokoBrandMark(size:53))),
       const SizedBox(width:12),
       const Flexible(child:Text('Cikoko\nSmartAPP',
        style:TextStyle(color:CikokoPalette.navy,fontSize:29,
         fontWeight:FontWeight.w900,height:.98))),
      ]),
      const SizedBox(height:10),
      Container(padding:const EdgeInsets.symmetric(horizontal:16,vertical:7),
       decoration:BoxDecoration(gradient:const LinearGradient(
        colors:[CikokoPalette.navy,CikokoPalette.blue]),
        borderRadius:BorderRadius.circular(24)),
       child:const Text('Layanan Digital Kelurahan Cikoko',
        style:TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w700))),
      const SizedBox(height:18),
      Container(padding:const EdgeInsets.all(12),
       decoration:BoxDecoration(color:Colors.white,
        borderRadius:BorderRadius.circular(19),
        border:Border.all(color:CikokoPalette.border)),
       child:GridView.count(crossAxisCount:2,mainAxisSpacing:9,crossAxisSpacing:9,
        childAspectRatio:2.15,shrinkWrap:true,
        physics:const NeverScrollableScrollPhysics(),children:[
         _GuestFeature(title:'Profil Kelurahan',subtitle:'Tentang Cikoko',
          icon:Icons.account_balance_outlined,color:CikokoPalette.green,onTap:onAbout),
         _GuestFeature(title:'Layanan Publik',subtitle:'Lihat layanan',
          icon:Icons.widgets_outlined,color:CikokoPalette.orange,onTap:onServices),
         _GuestFeature(title:'Berita & Informasi',subtitle:'Kegiatan terbaru',
          icon:Icons.newspaper_outlined,color:CikokoPalette.blue,onTap:onNews),
         _GuestFeature(title:'Inovasi Cikoko',subtitle:'Program unggulan',
          icon:Icons.lightbulb_outline,color:const Color(0xFF28A45B),
          onTap:onInnovations),
        ])),
      const SizedBox(height:13),
      SizedBox(height:49,width:double.infinity,child:FilledButton(
       onPressed:onLogin,child:const Text('Masuk ke Akun',
        style:TextStyle(fontSize:15,fontWeight:FontWeight.w800)))),
      const SizedBox(height:9),
      SizedBox(height:47,width:double.infinity,child:OutlinedButton(
       onPressed:onRegister,child:const Text('Daftar Akun Warga'))),
      const SizedBox(height:16),
    ])),
   ),
 ]);
}
class _GuestFeature extends StatelessWidget {
 final String title,subtitle;
 final IconData icon;
 final Color color;
 final VoidCallback onTap;
 const _GuestFeature({required this.title,required this.subtitle,
  required this.icon,required this.color,required this.onTap});
 @override Widget build(BuildContext context)=>Material(
  color:const Color(0xFFF8FAFD),borderRadius:BorderRadius.circular(12),
  child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),
   child:Padding(padding:const EdgeInsets.all(8),child:Row(children:[
    Container(width:32,height:34,decoration:BoxDecoration(
      color:color.withValues(alpha:.13),borderRadius:BorderRadius.circular(10)),
     child:Icon(icon,color:color,size:19)),
    const SizedBox(width:7),
    Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,
     crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,maxLines:1,overflow:TextOverflow.ellipsis,
       style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w600,
        color:CikokoPalette.navy)),
      Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,
       style:const TextStyle(fontSize:9.5,color:CikokoPalette.muted)),
    ])),
   ]))));
}

class CikokoPremiumHeader extends StatelessWidget {
  final String title,subtitle;
  final IconData icon;
  final Color start,end;
  final Widget? trailing;
  const CikokoPremiumHeader({super.key,required this.title,required this.subtitle,
    this.icon=Icons.dashboard_customize_outlined,
    this.start=CikokoPalette.navy,this.end=CikokoPalette.blue,this.trailing});
  @override
  Widget build(BuildContext context)=>Container(
    width:double.infinity,
    padding:const EdgeInsets.all(15),
    decoration:BoxDecoration(
      gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[start,end]),
      borderRadius:BorderRadius.circular(18),
      boxShadow:[BoxShadow(color:end.withValues(alpha:.14),
        blurRadius:14,offset:const Offset(0,5))]),
    child:Row(children:[
      Container(width:46,height:46,
        decoration:BoxDecoration(color:Colors.white.withValues(alpha:.18),
          borderRadius:BorderRadius.circular(14)),
        child:Icon(icon,size:25,color:Colors.white)),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,maxLines:2,overflow:TextOverflow.ellipsis,
          style:const TextStyle(color:Colors.white,fontSize:16,
            fontWeight:FontWeight.w600,height:1.2)),
        const SizedBox(height:5),
        Text(subtitle,maxLines:3,overflow:TextOverflow.ellipsis,
          style:const TextStyle(color:Color(0xFFE4F1FF),fontSize:11.5,height:1.3)),
      ])),
      if(trailing!=null)...[const SizedBox(width:7),trailing!],
    ]),
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
    Text(title,style:const TextStyle(color:CikokoPalette.navy,
      fontSize:16,fontWeight:FontWeight.w600)),
    if(subtitle!=null)Padding(padding:const EdgeInsets.only(top:3),
      child:Text(subtitle!,style:const TextStyle(color:CikokoPalette.muted,fontSize:11.5))),
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
  color:Colors.white,borderRadius:BorderRadius.circular(15),
  child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(15),
    child:Container(
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
      decoration:BoxDecoration(border:Border.all(color:CikokoPalette.border),
        borderRadius:BorderRadius.circular(15)),
      child:Row(children:[
        Container(width:39,height:39,
         decoration:BoxDecoration(color:accent.withValues(alpha:.12),
          borderRadius:BorderRadius.circular(11)),
         child:Icon(icon,color:accent,size:21)),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(title,maxLines:2,overflow:TextOverflow.ellipsis,
            style:const TextStyle(color:CikokoPalette.navy,
              fontSize:12,fontWeight:FontWeight.w600)),
          const SizedBox(height:3),
          Text(subtitle,maxLines:2,overflow:TextOverflow.ellipsis,
            style:const TextStyle(color:CikokoPalette.muted,fontSize:10.5)),
        ])),
        const Icon(Icons.chevron_right_rounded,color:CikokoPalette.muted,size:18),
      ]),
    )));
}

class CikokoStageIndicator extends StatelessWidget {
 final int current;
 final List<String> labels;
 const CikokoStageIndicator({super.key,required this.current,required this.labels});
 @override Widget build(BuildContext context)=>Row(children:[
  for(var i=0;i<labels.length;i++)...[
    if(i>0)Expanded(child:Container(height:2,color:i<=current?
      CikokoPalette.blue:CikokoPalette.border)),
    Column(children:[
      CircleAvatar(radius:13,backgroundColor:i<=current?
       CikokoPalette.blue:const Color(0xFFE8EEF6),
       child:Text('${i+1}',style:TextStyle(fontSize:11,
         color:i<=current?Colors.white:CikokoPalette.muted,
         fontWeight:FontWeight.w600))),
      const SizedBox(height:4),
      Text(labels[i],style:const TextStyle(color:CikokoPalette.muted,fontSize:10)),
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
  decoration:const BoxDecoration(gradient:LinearGradient(
   begin:Alignment.topCenter,end:Alignment.bottomCenter,
   colors:[Color(0xFFEFF6FF),Color(0xFFF6F9FF),Color(0xFFF7FAFD)],
   stops:[0,.33,1])),
  child:Center(child:ConstrainedBox(
   constraints:const BoxConstraints(maxWidth:820),child:child)));
}

class CikokoPageSignature extends StatelessWidget {
 const CikokoPageSignature({super.key});
 @override Widget build(BuildContext context)=>const Padding(
  padding:EdgeInsets.fromLTRB(10,20,10,24),
  child:Text('Copyright © Cikoko Smart',textAlign:TextAlign.center,
   style:TextStyle(fontSize:10.5,color:CikokoPalette.muted,
    fontWeight:FontWeight.w400)));
}

class CikokoStatusBadge extends StatelessWidget {
  final String status;
  const CikokoStatusBadge({super.key, required this.status});
  @override Widget build(BuildContext context) {
    final value=status.toLowerCase().replaceAll('_',' ').trim();
    final rejected=value.contains('tolak') || value.contains('reject') || value.contains('return');
    final completed=value.contains('selesai') || value.contains('approved') || value.contains('disetujui') || value.contains('complete');
    final accent=rejected?const Color(0xFFDC3558):completed?const Color(0xFF15985B):const Color(0xFFB67A00);
    final fill=rejected?const Color(0xFFFFE4EA):completed?const Color(0xFFDCF9E9):const Color(0xFFFFF1BC);
    final label=rejected?'Ditolak':completed?'Selesai':'Dalam Proses';
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:11,vertical:6),
      decoration:BoxDecoration(color:fill,borderRadius:BorderRadius.circular(24)),
      child:Row(mainAxisSize:MainAxisSize.min,children:[
        Icon(rejected?Icons.cancel_rounded:completed?Icons.check_circle_rounded:Icons.schedule_rounded,
          color:accent,size:16),
        const SizedBox(width:5),
        Text(label,style:TextStyle(color:accent,fontSize:11,fontWeight:FontWeight.w800)),
      ]),
    );
  }
}
