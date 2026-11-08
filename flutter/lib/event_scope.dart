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

/// Seed even an empty inbox so the first later event is treated as new.
class CikokoEventTracker {
  final Set<String> _seen={};
  bool _seeded=false;
  void markSeen(Object? id){final value='${id??''}';if(value.isNotEmpty)_seen.add(value);}
  List<Map<String,dynamic>> takeNew(Iterable<dynamic> input){
    final events=input.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();
    final ids=events.map((e)=>'${e['id']??''}').where((id)=>id.isNotEmpty).toSet();
    if(!_seeded){_seen.addAll(ids);_seeded=true;return [];}
    final fresh=events.where((e)=>'${e['id']??''}'.isNotEmpty&&!_seen.contains('${e['id']}')&&e['is_read']!=true&&'${e['is_read']??0}'!='1').take(3).toList();
    _seen.addAll(ids);
    if(_seen.length>350){_seen.clear();_seen.addAll(ids);}
    return fresh;
  }
}
