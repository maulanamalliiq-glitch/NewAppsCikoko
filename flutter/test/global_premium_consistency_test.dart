import 'package:cikoko/design_system.dart';
import 'package:cikoko/premium_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance() + .05;
  final b = background.computeLuminance() + .05;
  return a > b ? a / b : b / a;
}

void main() {
  test('Role menu accents remain stable by feature, not screen position', () {
    expect(CikokoMenuAccent.forRoute('Surat Pengantar RT/RW'),
      CikokoPalette.blue);
    expect(CikokoMenuAccent.forRoute('Laporan LPJ RW'),
      CikokoPalette.purple);
    expect(CikokoMenuAccent.forRoute('Kelola Akun Petugas'),
      CikokoPalette.green);
  });

  for (final dark in [false, true]) {
    testWidgets('Global components fit a compact phone in dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      var opened = false;
      final theme = dark ? CikokoDesign.dark : CikokoDesign.light;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SafeArea(child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const CikokoPremiumHeader(
                  title: 'Menu Layanan',
                  subtitle: 'Sesuai hak akses akun',
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(hintText: 'Cari layanan'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 115,
                  width: 150,
                  child: CikokoMenuGridCard(
                    title: 'Laporan LPJ RT',
                    icon: Icons.description_outlined,
                    accent: CikokoMenuAccent.forRoute('Laporan LPJ RT'),
                    onTap: () => opened = true,
                  ),
                ),
                const SizedBox(height: 12),
                const CikokoEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Belum ada konten',
                  subtitle: 'Konten kategori ini belum tersedia.',
                ),
                const CikokoPageSignature(),
              ]),
            ),
          )),
        ),
      ));
      expect(find.text('Menu Layanan'), findsOneWidget);
      expect(find.text('Laporan LPJ RT'), findsOneWidget);
      expect(find.text('Belum ada konten'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Laporan LPJ RT'));
      expect(opened, isTrue);
      expect(contrast(theme.colorScheme.onSurfaceVariant,
        theme.colorScheme.surface), greaterThanOrEqualTo(4.5));
      await tester.binding.setSurfaceSize(null);
    });
  }
}
