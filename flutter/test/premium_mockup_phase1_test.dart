import 'package:cikoko/design_system.dart';
import 'package:cikoko/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Premium welcome hero renders correctly on compact Android',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    await tester.pumpWidget(MaterialApp(
      theme: CikokoDesign.light,
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CikokoWelcomeHero(
                name: 'Andi Pratama',
                roleName: 'Admin Utama',
                subtitle: 'Kelola layanan dan petugas',
              ),
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Cikoko SmartAPP'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('AP'), findsOneWidget);
    expect(find.text('Hai, Andi Pratama'), findsOneWidget);
    expect(find.text('Admin Utama'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Premium portal banner navigates to real service entry',
      (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      theme: CikokoDesign.light,
      home: Scaffold(
        body: CikokoPortalBanner(onOpen: () => opened = true),
      ),
    ));
    expect(find.text('Portal Layanan'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cikoko_portal_banner')));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });
}
