import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'premium_ui.dart';

/// Only confirmed numbers may enter a public statistics card.
/// The RT distribution below is historical (2019), not asserted current.
/// Resident and household figures are intentionally absent until a verified
/// Kelurahan source/API supplies a per-RW breakdown.
class CikokoRwRecord {
  final int rw;
  final int? residents;
  final int? rt;
  final int? households;
  final String? rtSourceNote;
  const CikokoRwRecord({
    required this.rw,
    this.residents,
    this.rt,
    this.households,
    this.rtSourceNote,
  });
  String get label => 'RW ${rw.toString().padLeft(2, '0')}';
}

const cikokoRwArchive = <CikokoRwRecord>[
  CikokoRwRecord(rw:1, rt:3, rtSourceNote:'Arsip Kelurahan Cikoko (2019)'),
  CikokoRwRecord(rw:2, rt:12, rtSourceNote:'Arsip Kelurahan Cikoko (2019)'),
  CikokoRwRecord(rw:3, rt:9, rtSourceNote:'Arsip Kelurahan Cikoko (2019)'),
  CikokoRwRecord(rw:4, rt:10, rtSourceNote:'Arsip Kelurahan Cikoko (2019)'),
  CikokoRwRecord(rw:5, rt:8, rtSourceNote:'Arsip Kelurahan Cikoko (2019)'),
];

const cikokoOfficialProfileUrl =
  'https://selatan.jakarta.go.id/modul/kelurahan/cikoko/pemerintahan/profil';
const cikokoRtArchiveUrl = 'https://kelurahancikoko.wordpress.com/rw/';

/// This is a schematic layout for navigation, not cadastral/geographic data.
abstract final class CikokoRwGeometry {
  static const regions = <int,List<Offset>>{
    3: [Offset(.055,.14),Offset(.39,.14),Offset(.42,.50),Offset(.055,.49)],
    4: [Offset(.055,.49),Offset(.42,.50),Offset(.39,.88),Offset(.055,.88)],
    5: [Offset(.39,.14),Offset(.66,.14),Offset(.66,.45),
        Offset(.63,.72),Offset(.42,.72),Offset(.42,.50)],
    1: [Offset(.66,.14),Offset(.948,.14),Offset(.948,.45),Offset(.66,.45)],
    2: [Offset(.66,.45),Offset(.948,.45),Offset(.948,.88),
        Offset(.39,.88),Offset(.42,.72),Offset(.63,.72)],
  };

  static Path pathFor(int rw,Size size) {
    final points = regions[rw];
    final path=Path();
    if(points==null||points.isEmpty)return path;
    path.moveTo(points.first.dx*size.width,points.first.dy*size.height);
    for(final point in points.skip(1)) {
      path.lineTo(point.dx*size.width,point.dy*size.height);
    }
    return path..close();
  }

  static int? rwAt(Offset localPosition,Size size) {
    if(size.width<=0||size.height<=0)return null;
    for(final rw in regions.keys) {
      if(pathFor(rw,size).contains(localPosition))return rw;
    }
    return null;
  }
}

class CikokoRwMap extends StatelessWidget {
  final ValueChanged<int> onSelect;
  final int? selected;
  const CikokoRwMap({super.key,required this.onSelect,this.selected});

  @override
  Widget build(BuildContext context) {
    final dark=Theme.of(context).brightness==Brightness.dark;
    return LayoutBuilder(builder:(context,constraints) {
      return AspectRatio(
        aspectRatio:1.67,
        child:GestureDetector(
          key:const Key('cikoko_rw_map'),
          behavior:HitTestBehavior.opaque,
          onTapUp:(details){
            final size=Size(constraints.maxWidth,constraints.maxWidth/1.67);
            final rw=CikokoRwGeometry.rwAt(details.localPosition,size);
            if(rw!=null)onSelect(rw);
          },
          child:CustomPaint(
            painter:_CikokoRwPainter(selected:selected,dark:dark),
            child:const SizedBox.expand(),
          ),
        ),
      );
    });
  }
}

class _CikokoRwPainter extends CustomPainter {
  final int? selected;
  final bool dark;
  const _CikokoRwPainter({required this.selected,required this.dark});

  @override
  void paint(Canvas canvas,Size size) {
    final bg=Paint()..color=dark
      ?const Color(0xFF12263E):const Color(0xFFEFF6FC);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero&size,
      const Radius.circular(18)),bg);

    // Simple streets/terrain hint; no satellite imagery or false precision.
    final road=Paint()
      ..color=dark?const Color(0xFF385574):const Color(0xFFDEE9F1)
      ..strokeWidth=1.4;
    for(var i=1;i<6;i++) {
      final y=size.height*(.12+i*.14);
      canvas.drawLine(Offset(0,y),Offset(size.width,y),road);
    }

    const colors={
      1:Color(0xFF75B8E5),2:Color(0xFF83AFCF),
      3:Color(0xFF90C8E7),4:Color(0xFF78B5CA),
      5:Color(0xFF5F9DC9),
    };
    for(final rw in const [3,4,5,1,2]) {
      final base=selected==rw ?const Color(0xFF0F66CB):colors[rw]!;
      final fill=Paint()..color=base;
      canvas.drawPath(CikokoRwGeometry.pathFor(rw,size),fill);
      final border=Paint()
        ..color=Colors.white.withValues(alpha:.90)
        ..style=PaintingStyle.stroke
        ..strokeWidth=2.8;
      canvas.drawPath(CikokoRwGeometry.pathFor(rw,size),border);
    }

    // One stylized north road and east-side river.
    final street=Paint()
      ..style=PaintingStyle.stroke
      ..color=Colors.white.withValues(alpha:.30)
      ..strokeWidth=1.3;
    canvas.drawLine(Offset(size.width*.13,size.height*.22),
      Offset(size.width*.84,size.height*.20),street);
    canvas.drawLine(Offset(size.width*.19,size.height*.62),
      Offset(size.width*.79,size.height*.75),street);
    final river=Path()
      ..moveTo(size.width*.97,size.height*.10)
      ..cubicTo(size.width*.91,size.height*.35,size.width*1.04,size.height*.65,
        size.width*.965,size.height*.92);
    canvas.drawPath(river,Paint()..color=const Color(0xFF2094D7)
      ..strokeWidth=5..style=PaintingStyle.stroke
      ..strokeCap=StrokeCap.round);

    final labelPositions=<int,Offset>{
      3:const Offset(.23,.32),4:const Offset(.22,.70),
      5:const Offset(.52,.43),1:const Offset(.80,.29),
      2:const Offset(.77,.67),
    };
    for(final entry in labelPositions.entries) {
      final rw=entry.key;
      final text=TextPainter(
        text:TextSpan(text:'RW ${rw.toString().padLeft(2,'0')}',
          style:const TextStyle(
            color:Colors.white,fontSize:15,fontWeight:FontWeight.w800,
            shadows:[Shadow(blurRadius:3,color:Color(0x55000000))])),
        textDirection:TextDirection.ltr,
      )..layout();
      final at=Offset(entry.value.dx*size.width-text.width/2,
        entry.value.dy*size.height-text.height/2);
      text.paint(canvas,at);
    }
    final north=TextPainter(
      text:const TextSpan(text:'U ↑',style:TextStyle(
        color:Color(0xFF8FBCE4),fontSize:11,fontWeight:FontWeight.w800)),
      textDirection:TextDirection.ltr,
    )..layout();
    north.paint(canvas,Offset(8,7));
  }

  @override
  bool shouldRepaint(covariant _CikokoRwPainter old) =>
    old.dark!=dark||old.selected!=selected;
}

class CikokoAboutPage extends StatefulWidget {
  /// Can be supplied from future verified statistics without rebuilding map.
  final Map<int,CikokoRwRecord>? verified;
  const CikokoAboutPage({super.key,this.verified});
  @override
  State<CikokoAboutPage> createState()=>_CikokoAboutPageState();
}

class _CikokoAboutPageState extends State<CikokoAboutPage> {
  int? selectedRw;

  CikokoRwRecord record(int rw)=>
    widget.verified?[rw]??cikokoRwArchive.firstWhere((r)=>r.rw==rw);

  String value(int? count)=>count==null?'Belum tersedia':'$count';

  Future<void> showRw(int rw) async {
    setState(()=>selectedRw=rw);
    final row=record(rw);
    final scheme=Theme.of(context).colorScheme;
    await showDialog<void>(
      context:context,
      builder:(dialog)=>Dialog(
        shape:RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(22)),
        child:ConstrainedBox(
          constraints:const BoxConstraints(maxWidth:460),
          child:SingleChildScrollView(
            child:Padding(
              padding:const EdgeInsets.all(17),
              child:Column(mainAxisSize:MainAxisSize.min,children:[
                Row(children:[
                  CircleAvatar(
                    backgroundColor:scheme.primaryContainer,
                    child:Icon(Icons.location_city_outlined,
                      color:scheme.primary),
                  ),
                  const SizedBox(width:10),
                  Expanded(child:Text('Detail ${row.label}',
                    style:Theme.of(context).textTheme.titleLarge)),
                  IconButton(
                    tooltip:'Tutup',
                    onPressed:()=>Navigator.pop(dialog),
                    icon:const Icon(Icons.close_rounded)),
                ]),
                const SizedBox(height:8),
                _rwMetric(context,'Jumlah penduduk',
                  value(row.residents),Icons.groups_rounded),
                _rwMetric(context,'Jumlah RT',
                  value(row.rt),Icons.grid_view_rounded),
                _rwMetric(context,'Jumlah KK',
                  value(row.households),Icons.family_restroom_rounded),
                const SizedBox(height:10),
                Text(
                  row.rtSourceNote!=null
                    ?'Jumlah RT merupakan data arsip 2019, bukan klaim '
                      'angka terbaru. Penduduk dan KK akan tampil setelah '
                      'tersedia data resmi per RW.'
                    :'Angka ditampilkan sesuai data RW yang telah diverifikasi.',
                  style:Theme.of(context).textTheme.bodySmall,
                  textAlign:TextAlign.center),
                const SizedBox(height:12),
                SizedBox(width:double.infinity,
                  child:FilledButton(
                    onPressed:()=>Navigator.pop(dialog),
                    child:const Text('Tutup Detail'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rwMetric(BuildContext context,String label,String count,
      IconData icon) {
    final scheme=Theme.of(context).colorScheme;
    return Container(
      margin:const EdgeInsets.only(top:8),
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:12),
      decoration:BoxDecoration(
        color:scheme.surfaceContainerLow,
        border:Border.all(color:scheme.outlineVariant),
        borderRadius:BorderRadius.circular(13)),
      child:Row(children:[
        Icon(icon,size:22,color:scheme.primary),
        const SizedBox(width:10),
        Expanded(child:Text(label,
          style:TextStyle(color:scheme.onSurface,fontSize:12.5))),
        const SizedBox(width:8),
        Flexible(child:Text(count,textAlign:TextAlign.right,
          style:TextStyle(color:scheme.onSurface,
            fontWeight:FontWeight.w800,fontSize:13))),
      ]),
    );
  }

  Future<void> openOfficial(String link)async {
    final uri=Uri.parse(link);
    if(!await launchUrl(uri,mode:LaunchMode.externalApplication)
        && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:Text('Tautan sumber belum dapat dibuka.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme=Theme.of(context).colorScheme;
    return ListView(
      padding:const EdgeInsets.fromLTRB(14,12,14,28),
      children:[
        const CikokoPremiumHeader(
          title:'Tentang Kelurahan Cikoko',
          subtitle:'Peta RW dan informasi wilayah Kecamatan Pancoran.',
          icon:Icons.location_city_rounded),
        const SizedBox(height:13),
        Row(children:[
          for(final stat in const [
            ('5','RW'),('42','RT'),('71,69','Hektare'),
          ])...[
            if(stat.$2!='RW')const SizedBox(width:8),
            Expanded(child:Container(
              padding:const EdgeInsets.symmetric(vertical:12,horizontal:7),
              decoration:BoxDecoration(
                color:scheme.surface,
                borderRadius:BorderRadius.circular(14),
                border:Border.all(color:scheme.outlineVariant)),
              child:Column(children:[
                Text(stat.$1,style:TextStyle(
                  fontSize:18,fontWeight:FontWeight.w900,color:scheme.primary)),
                const SizedBox(height:2),
                Text(stat.$2,style:TextStyle(
                  color:scheme.onSurfaceVariant,fontSize:11)),
              ]),
            )),
          ],
        ]),
        const SizedBox(height:18),
        Text('Peta Interaktif RW',
          style:Theme.of(context).textTheme.titleLarge),
        const SizedBox(height:4),
        Text('Ketuk area atau pilih nomor RW untuk melihat rinciannya.',
          style:Theme.of(context).textTheme.bodySmall),
        const SizedBox(height:10),
        CikokoPremiumSurface(
          padding:const EdgeInsets.all(9),
          child:Column(children:[
            CikokoRwMap(selected:selectedRw,onSelect:showRw),
            const SizedBox(height:8),
            Text('Peta skematis untuk navigasi, bukan batas administrasi resmi.',
              textAlign:TextAlign.center,
              style:Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        const SizedBox(height:12),
        Wrap(spacing:8,runSpacing:8,children:[
          for(final r in cikokoRwArchive)
            ActionChip(
              key:Key('open_rw_${r.rw}'),
              avatar:Icon(Icons.place_outlined,
                size:16,color:scheme.primary),
              label:Text(r.label),
              onPressed:()=>showRw(r.rw),
            ),
        ]),
        const SizedBox(height:17),
        Text('Informasi Wilayah',
          style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:7),
        CikokoPremiumSurface(
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Kelurahan Cikoko · Kecamatan Pancoran',
              style:Theme.of(context).textTheme.titleMedium),
            const SizedBox(height:7),
            Text('Jakarta Selatan, DKI Jakarta. '
              'Wilayah administratif meliputi 5 RW dan 42 RT.',
              style:Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height:8),
            Text('Sumber: Pemerintah Kota Administrasi Jakarta Selatan. '
              'Rincian jumlah RT per RW berasal dari arsip Kelurahan Cikoko '
              'yang perlu diperbarui bila ada data terbaru.',
              style:Theme.of(context).textTheme.bodySmall),
            const SizedBox(height:8),
            TextButton.icon(
              onPressed:()=>openOfficial(cikokoOfficialProfileUrl),
              icon:const Icon(Icons.open_in_new_rounded,size:16),
              label:const Text('Profil Resmi Kelurahan')),
            TextButton.icon(
              onPressed:()=>openOfficial(cikokoRtArchiveUrl),
              icon:const Icon(Icons.history_rounded,size:16),
              label:const Text('Referensi Arsip RT per RW')),
          ]),
        ),
        const CikokoPageSignature(),
      ],
    );
  }
}
