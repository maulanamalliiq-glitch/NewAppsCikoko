import 'package:cikoko/about_cikoko_page.dart';
import 'package:cikoko/bottom_navigation_catalog.dart';
import 'package:cikoko/cikoko_startup_splash.dart';
import 'package:cikoko/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Beranda is centered; About replaces bottom Services only', () {
    expect(cikokoBottomRoutes,[
      'Tentang Kami','Menu Cikoko','Dashboard','Inovasi','Profil',
    ]);
    expect(cikokoBottomRoute(2),'Dashboard');
    expect(cikokoBottomIndexForRoute('Dashboard',0),2);
    expect(cikokoBottomRoute(0),'Tentang Kami');
    expect(cikokoBottomRoute(3),'Inovasi');
    expect(cikokoBottomIndexForRoute('Layanan Online',2),2);
  });

  test('Archive RT count is sourced but demographic data is not fabricated', () {
    expect(cikokoRwArchive.length,5);
    expect(cikokoRwArchive.map((rw)=>rw.rt??0).reduce((a,b)=>a+b),42);
    expect(cikokoRwArchive.every((rw)=>
      rw.residents==null && rw.households==null),isTrue);
  });

  test('Schematic map resolves each of the five areas separately', () {
    const size=Size(300,200);
    const center=<int,Offset>{
      3:Offset(.23,.32),
      4:Offset(.22,.70),
      5:Offset(.52,.43),
      1:Offset(.80,.29),
      2:Offset(.77,.67),
    };
    for(final point in center.entries) {
      final tap=Offset(point.value.dx*size.width,
        point.value.dy*size.height);
      expect(CikokoRwGeometry.rwAt(tap,size),point.key);
    }
    expect(CikokoRwGeometry.rwAt(Offset.zero,size),isNull);
  });

  for(final isDark in [false,true]){
    testWidgets('RW detail lightbox opens on compact device, dark=$isDark',
      (tester)async{
        await tester.binding.setSurfaceSize(const Size(360,780));
        await tester.pumpWidget(MaterialApp(
          theme:isDark?CikokoDesign.dark:CikokoDesign.light,
          home:const Scaffold(body:CikokoAboutPage()),
        ));
        expect(find.text('Peta Interaktif RW'),findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('open_rw_1')));
        await tester.tap(find.byKey(const Key('open_rw_1')));
        await tester.pumpAndSettle();
        expect(find.text('Detail RW 01'),findsOneWidget);
        expect(find.text('Jumlah penduduk'),findsOneWidget);
        expect(find.text('Jumlah RT'),findsOneWidget);
        expect(find.text('Jumlah KK'),findsOneWidget);
        expect(find.text('Belum tersedia'),findsWidgets);
        expect(tester.takeException(),isNull);
        await tester.binding.setSurfaceSize(null);
      },
    );
  }

  testWidgets('Splash uses only the Kelurahan Cikoko logo', (tester)async{
    await tester.pumpWidget(const MaterialApp(
      home:CikokoStartupSplash(),
    ));
    expect(find.byKey(const Key('kelurahan_cikoko_splash_logo')),
      findsOneWidget);
    expect(find.text('CIKOKO SMARTAPP'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
