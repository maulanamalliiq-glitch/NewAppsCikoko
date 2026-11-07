import 'package:cikoko/design_system.dart';
import 'package:cikoko/premium_flow_ui.dart';
import 'package:cikoko/rt_rw_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RT/RW area labels display canonical zero-padded values', () {
    expect(cikokoAreaLabel('1'), '01');
    expect(cikokoAreaLabel('03'), '03');
    expect(cikokoAreaLabel(null), '-');
  });

  for (final dark in [false, true]) {
    testWidgets('Surat progress and form sections fit a compact phone, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      await tester.pumpWidget(MaterialApp(
        theme: dark ? CikokoDesign.dark : CikokoDesign.light,
        home: const Scaffold(
          body: SafeArea(child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(children: [
                CikokoFlowSteps(
                  current: 1,
                  labels: ['Isi Data', 'Konfirmasi', 'Terkirim'],
                ),
                SizedBox(height: 12),
                CikokoFlowSection(
                  title: 'Identitas Pemohon',
                  subtitle: 'Lengkapi data sesuai dokumen asli',
                  icon: Icons.person_outline,
                  child: TextField(decoration: InputDecoration(
                    labelText: 'Nama')),
                ),
              ]),
            ),
          )),
        ),
      ));
      expect(find.text('Isi Data'), findsOneWidget);
      expect(find.text('Konfirmasi'), findsOneWidget);
      expect(find.text('Terkirim'), findsOneWidget);
      expect(find.text('Identitas Pemohon'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('LPJ document card opens the supplied detail action',
      (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      theme: CikokoDesign.light,
      home: Scaffold(body: CikokoRecordCard(
        title: 'Periode 2026-11',
        subtitle: 'Pembuat: Bendahara RW 003',
        status: 'menunggu_ketua',
        statusLabel: 'Menunggu Ketua RW',
        onTap: () => opened = true,
      )),
    ));
    expect(find.text('Periode 2026-11'), findsOneWidget);
    expect(find.text('Menunggu Ketua RW'), findsOneWidget);
    await tester.tap(find.text('Periode 2026-11'));
    expect(opened, isTrue);
  });
}
