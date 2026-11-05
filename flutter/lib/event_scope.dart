/// Restrict the private notification inbox to the authenticated account.
///
/// Server events must carry both audience and recipient. If an older API
/// omits these security fields, private notifications fail closed rather
/// than exposing another resident's submissions.
List<Map<String, dynamic>> cikokoEventsForAccount(
  Iterable<dynamic> events,
  Object? accountId,
) {
  final viewer = (accountId ?? '').toString().trim();
  if (viewer.isEmpty) return const <Map<String, dynamic>>[];
  final visible = <Map<String, dynamic>>[];
  for (final item in events) {
    if (item is! Map) continue;
    final event = Map<String, dynamic>.from(item);
    if (event['audience'] != 'personal') continue;
    if ((event['recipient'] ?? '').toString().trim() != viewer) continue;
    visible.add(event);
  }
  return visible;
}

/// FCM can arrive after an account switch. Never display stale push content.
bool cikokoPushBelongsToAccount(Map<String, dynamic> data, Object? accountId) {
  final viewer = (accountId ?? '').toString().trim();
  if (viewer.isEmpty) return false;
  return (data['account_id'] ?? '').toString().trim() == viewer;
}
