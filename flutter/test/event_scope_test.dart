import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/event_scope.dart';

void main() {
  group('Private account notifications', () {
    final examples = <Map<String, dynamic>>[
      {'id': 11, 'audience': 'personal', 'recipient': 'warga-a',
       'title': 'Laporan warga A'},
      {'id': 12, 'audience': 'personal', 'recipient': 'warga-b',
       'title': 'Laporan warga B'},
      {'id': 13, 'audience': 'admin', 'recipient': null,
       'title': 'Semua pengajuan'},
      {'id': 14, 'audience': 'public', 'recipient': null,
       'title': 'Berita publik'},
      {'id': 15, 'title': 'Tanpa data penerima'},
    ];

    test('warga A cannot read warga B or broadcast alerts', () {
      final visible = cikokoEventsForAccount(examples, 'warga-a');
      expect(visible.map((event) => event['id']), [11]);
    });

    test('warga B only reads own submission', () {
      final visible = cikokoEventsForAccount(examples, 'warga-b');
      expect(visible.map((event) => event['id']), [12]);
    });

    test('no authentication or no audience metadata fails closed', () {
      expect(cikokoEventsForAccount(examples, null), isEmpty);
      expect(cikokoEventsForAccount([{'id': 77}], 'warga-a'), isEmpty);
    });

    test('admin does not see unrelated private or broadcast events', () {
      expect(cikokoEventsForAccount(examples, 'admin'), isEmpty);
    });
  });

  group('Stale push notification guard', () {
    test('matches the intended active account', () {
      expect(cikokoPushBelongsToAccount(
        {'account_id': 'warga-a', 'event_id': '1'}, 'warga-a'), isTrue);
      expect(cikokoPushBelongsToAccount(
        {'account_id': 'warga-a', 'event_id': '1'}, 'warga-b'), isFalse);
    });

    test('rejects unscoped push and anonymous access', () {
      expect(cikokoPushBelongsToAccount({'event_id': '1'}, 'warga-a'), isFalse);
      expect(cikokoPushBelongsToAccount(
        {'account_id': 'warga-a'}, null), isFalse);
    });
  });
}
