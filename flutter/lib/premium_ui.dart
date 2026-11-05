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


class CikokoGuestHero extends StatelessWidget {
 final VoidCallback onLogin,onRegister,onServices,onNews,onInnovations,onAbout;
 const CikokoGuestHero({super.key,required this.onLogin,required this.onRegister,
  required this.onServices,required this.onNews,required this.onInnovations,
  required this.onAbout});
 @override Widget build(BuildContext context)=>Column(children:[
   Container(height:232,width:double.infinity,clipBehavior:Clip.antiAlias,
    decoration:BoxDecoration(borderRadius:BorderRadius.circular(21)),
    child:Stack(fit:StackFit.expand,children:[
      Image.asset('assets/kantor-cikoko.jpg',fit:BoxFit.cover),
      const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
        begin:Alignment.topCenter,end:Alignment.bottomCenter,
        colors:[Color(0x4C0F6DBD),Color(0xE50B448F)]))),
      Positioned(top:22,left:15,child:Container(
       padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
       decoration:BoxDecoration(color:Colors.white.withValues(alpha:.85),
        borderRadius:BorderRadius.circular(8)),
       child:const Text('KELURAHAN CIKOKO · PANCORAN',
        style:TextStyle(fontSize:9,color:CikokoPalette.navy,fontWeight:FontWeight.w600)))),
      Positioned(left:16,right:16,bottom:22,child:Row(children:[
       Container(width:64,height:64,decoration:BoxDecoration(
         color:Colors.white,borderRadius:BorderRadius.circular(18)),
        child:const Center(child:CikokoBrandMark(size:50))),
       const SizedBox(width:12),
       const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Cikoko\nSmartAPP',style:TextStyle(
          color:Colors.white,fontSize:26,fontWeight:FontWeight.w700,
          height:1.02)),
        SizedBox(height:5),
        Text('Layanan Digital Kelurahan Cikoko',
         style:TextStyle(color:Color(0xFFEAF3FF),fontSize:11)),
       ])),
      ])),
    ])),
   const SizedBox(height:12),
   Container(padding:const EdgeInsets.all(13),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),
     border:Border.all(color:CikokoPalette.border)),
    child:GridView.count(crossAxisCount:2,mainAxisSpacing:10,crossAxisSpacing:10,
     childAspectRatio:2.35,shrinkWrap:true,
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
   const SizedBox(height:12),
   SizedBox(height:45,width:double.infinity,child:FilledButton(
    onPressed:onLogin,child:const Text('Masuk ke Akun'))),
   const SizedBox(height:8),
   SizedBox(height:43,width:double.infinity,child:OutlinedButton(
    onPressed:onRegister,child:const Text('Daftar Akun Warga'))),
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
