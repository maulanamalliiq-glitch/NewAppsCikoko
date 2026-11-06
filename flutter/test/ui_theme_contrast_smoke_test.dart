import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/app_settings.dart';
import 'package:cikoko/design_system.dart';
import 'package:cikoko/premium_ui.dart';

double contrastRatio(Color first, Color second) {
  final a = first.computeLuminance() + .05;
  final b = second.computeLuminance() + .05;
  return a > b ? a / b : b / a;
}

void main() {
  for (final mode in [Brightness.light, Brightness.dark]) {
    testWidgets('Premium components render legibly in $mode on a phone',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 740));
      CikokoSettings.language.value = 'id';
      final theme =
          mode == Brightness.dark ? CikokoDesign.dark : CikokoDesign.light;
      final scheme = theme.colorScheme;

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CikokoPremiumHeader(
                    title: 'Detail & Progres Pengajuan',
                    subtitle: 'Pantau status dan kelengkapan dokumen.',
                  ),
                  CikokoPremiumSection(
                    title: 'Layanan Warga',
                    subtitle: 'Menu setiap akun',
                  ),
                  CikokoPremiumTile(
                    icon: Icons.description_outlined,
                    title: 'Surat Pengantar RT/RW',
                    subtitle: 'Kelola pengajuan surat',
                    accent: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  CikokoStageIndicator(
                    current: 1,
                    labels: ['Masuk', 'Diproses', 'Selesai'],
                  ),
                  Spacer(),
                  CikokoCopyrightFooter(),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Layanan Warga'), findsOneWidget);
      expect(find.text('Surat Pengantar RT/RW'), findsOneWidget);
      expect(find.text('Copyright © Cikoko Smart'), findsOneWidget);

      final heading =
          tester.widget<Text>(find.text('Layanan Warga')).style!.color!;
      final tileTitle =
          tester.widget<Text>(find.text('Surat Pengantar RT/RW')).style!.color!;
      final tileSubtitle =
          tester.widget<Text>(find.text('Kelola pengajuan surat')).style!.color!;
      final stage =
          tester.widget<Text>(find.text('Diproses')).style!.color!;
      final footer =
          tester.widget<Text>(find.text('Copyright © Cikoko Smart')).style!.color!;

      expect(heading, scheme.onSurface);
      expect(tileTitle, scheme.onSurface);
      expect(tileSubtitle, scheme.onSurfaceVariant);
      expect(stage, scheme.onSurfaceVariant);
      expect(footer, scheme.onSurfaceVariant);

      expect(contrastRatio(tileTitle, scheme.surface), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(tileSubtitle, scheme.surface), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(footer, scheme.surface), greaterThanOrEqualTo(4.5));
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('Old English preference cannot change visible labels',
      (tester) async {
    CikokoSettings.language.value = 'en';
    await tester.pumpWidget(MaterialApp(
      theme: CikokoDesign.dark,
      home: const Scaffold(body: CikokoPremiumSection(title: 'Beranda')),
    ));
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    CikokoSettings.language.value = 'id';
  });
}
