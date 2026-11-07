import 'package:cikoko/design_system.dart';
import 'package:cikoko/event_scope.dart';
import 'package:cikoko/home_widgets.dart';
import 'package:cikoko/main.dart';
import 'package:cikoko/premium_ui.dart';
import 'package:cikoko/profile_status.dart';
import 'package:cikoko/role_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Read-only identity preview masks NIK without altering a raw value', () {
    const nik = '3174001234567890';
    expect(cikokoMaskedNik(nik), isNot(contains(nik)));
    expect(cikokoMaskedNik(nik).startsWith('3174'), isTrue);
    expect(cikokoMaskedNik(nik).endsWith('7890'), isTrue);
    expect(cikokoMaskedNik(''), 'Belum diisi');
    expect(nik, '3174001234567890');
  });

  test('Private notifications fail closed for other accounts and scopes', () {
    final items = [
      {'audience': 'personal', 'recipient': '11', 'title': 'Milik Saya'},
      {'audience': 'personal', 'recipient': '22', 'title': 'Akun Lain'},
      {'audience': 'role', 'recipient': '11', 'title': 'Broadcast'},
      {'recipient': '11', 'title': 'Tidak Ada Audience'},
    ];
    final visible = cikokoEventsForAccount(items, 11);
    expect(visible.length, 1);
    expect(visible.first['title'], 'Milik Saya');
    expect(cikokoEventsForAccount(items, null), isEmpty);
    expect(cikokoPushBelongsToAccount(
      {'account_id': '22'}, '11'), isFalse);
  });

  test('Citizen role never obtains administrative feature routes', () {
    final citizen = modulesForRole('warga',
      {'waris:create': true, 'report:jumantik': true});
    expect(citizen.any((f) => f.route == 'Kelola Akun Petugas'), isFalse);
    expect(citizen.any((f) => f.route == 'Hak Akses Role'), isFalse);
    expect(citizen.any((f) => f.route == 'Verifikasi Laporan'), isFalse);
  });

  for (final dark in [false, true]) {
    testWidgets('Super premium sections and Menu orb fit a narrow Android width: dark=$dark',
      (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      var searched = false;
      await tester.pumpWidget(MaterialApp(
        theme: dark ? CikokoDesign.dark : CikokoDesign.light,
        home: Scaffold(
          body: SafeArea(child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const CikokoPremiumHeader(
                  title: 'Permohonan Surat',
                  subtitle: 'Layanan administrasi sesuai akun'),
                const SizedBox(height: 12),
                CikokoSearchLauncher(onTap: () => searched = true),
                const SizedBox(height: 12),
                const CikokoPremiumSurface(child: Column(children: [
                  Text('Ringkasan Layanan'),
                  CikokoMenuOrb(selected: true),
                ])),
              ]),
            ),
          )),
        ),
      ));
      expect(find.text('Permohonan Surat'), findsOneWidget);
      expect(find.byType(CikokoMenuOrb), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('cikoko_home_search')));
      expect(searched, isTrue);
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('Dashboard aggregates show missing numbers as unavailable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 760));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(
        child: CikokoLetterCounters(counts: null, onStatusTap: _noOp),
      )),
    ));
    expect(find.text('—'), findsNWidgets(3));
    await tester.binding.setSurfaceSize(null);
  });
}

void _noOp(String _) {}
