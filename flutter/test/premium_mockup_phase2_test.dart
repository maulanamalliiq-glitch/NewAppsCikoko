import 'package:cikoko/design_system.dart';
import 'package:cikoko/notifications_page.dart';
import 'package:cikoko/staff_account_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final accounts = <Map<String, dynamic>>[
    {'id': 1, 'name': 'Budi', 'username': 'budi', 'role': 'rt',
      'rt': '001', 'rw': '003', 'active': true},
    {'id': 2, 'name': 'Siti', 'username': 'siti', 'role': 'bendahara_rw',
      'rt': '', 'rw': '003', 'active': true},
    {'id': 3, 'name': 'Amin', 'username': 'amin', 'role': 'ppsu',
      'rt': '', 'rw': '', 'active': false},
  ];

  test('Staff filters show existing data without modifying roles', () {
    expect(accounts.where((a) => cikokoAccountMatches(a, '', 'all')).length, 3);
    expect(accounts.where((a) => cikokoAccountMatches(a, '', 'ketua')).length, 1);
    expect(accounts.where((a) => cikokoAccountMatches(a, '', 'bendahara')).length, 1);
    expect(accounts.where((a) => cikokoAccountMatches(a, 'siti', 'bendahara')).length, 1);
    expect(accounts.where((a) => cikokoAccountMatches(a, 'siti', 'rt')).length, 0);
    expect(accounts[1]['role'], 'bendahara_rw');
  });

  testWidgets('Staff account cards fit a compact phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    var deleted = false;
    await tester.pumpWidget(MaterialApp(
      theme: CikokoDesign.light,
      home: Scaffold(body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            CikokoAccountSummary(accounts: accounts),
            CikokoOfficerAccountCard(
              account: accounts[1], roleLabel: 'Bendahara RW',
              onDelete: () => deleted = true,
            ),
          ]),
        ),
      ))),
    ));
    expect(find.text('Bendahara RW'), findsOneWidget);
    expect(find.text('RW 003'), findsOneWidget);
    expect(find.text('Aktif'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Opsi akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus akun'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
    await tester.binding.setSurfaceSize(null);
  });

  test('Notifications are grouped by actual event category', () {
    expect(cikokoNotificationIsRequest(
      {'category': 'rt_rw_surat'}), isTrue);
    expect(cikokoNotificationIsRequest(
      {'category': 'system'}), isFalse);
    expect(cikokoNotificationIsRead({'is_read': '1'}), isTrue);
    expect(cikokoNotificationIsRead({'is_read': false}), isFalse);
  });

  testWidgets('Notification tabs filter and open the right event', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    Map<String, dynamic>? opened;
    final events = <Map<String, dynamic>>[
      {'id': '11', 'title': 'Surat Baru',
        'message': 'Permohonan diajukan', 'is_read': false,
        'category': 'rt_rw_surat', 'created_at': '2026-11-07'},
      {'id': '12', 'title': 'Info Sistem',
        'message': 'Pemeliharaan', 'is_read': true,
        'category': 'system', 'created_at': '2026-11-07'},
    ];
    await tester.pumpWidget(MaterialApp(
      theme: CikokoDesign.dark,
      home: Scaffold(body: CikokoNotificationsPage(
        events: events, onOpen: (event) => opened = event,
      )),
    ));
    expect(find.text('Surat Baru'), findsOneWidget);
    expect(find.text('Info Sistem'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification_request')));
    await tester.pumpAndSettle();
    expect(find.text('Surat Baru'), findsOneWidget);
    expect(find.text('Info Sistem'), findsNothing);
    await tester.tap(find.text('Surat Baru'));
    expect(opened?['id'], '11');
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
