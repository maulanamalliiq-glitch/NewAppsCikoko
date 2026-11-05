import 'event_scope.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api.dart';

String destinationForPushCategory(String category,{required bool isStaff}) {
  if(category=='chat')return isStaff?'Pesan Masuk':'Hubungi Kami';
  if(category=='rt_rw_surat'||category=='rt_rw_status')return isStaff?'Surat Wilayah':'Surat Pengantar RT/RW';
  if(category=='surat'||category=='progres_surat'||category=='laporan_masuk')return isStaff?'Verifikasi Laporan':'Riwayat';
  return 'Notifikasi';
}

@pragma('vm:entry-point')
Future<void> backgroundMessage(RemoteMessage message) async {await Firebase.initializeApp();}
class PushService {
  final CikokoApi api;
  PushService(this.api);
  final local=FlutterLocalNotificationsPlugin();
  StreamSubscription<String>? refresh;
  StreamSubscription<RemoteMessage>? incoming;
  StreamSubscription<RemoteMessage>? opened;
  final Set<String> _seenEventIds={};
  bool _seeded=false;
  bool _initialized=false;
  Future<void> start(void Function() onRefresh,{void Function(RemoteMessage)? onOpen}) async {
    // Notifications while the app is open work even when FCM configuration
    // is temporarily unavailable. Android notification channels are immutable,
    // hence a new channel ID for a user-visible default sound.
    try {
      const channel=AndroidNotificationChannel('cikoko_updates_v2','Aktivitas dan Pelayanan Cikoko',
        description:'Berita, surat, laporan dan chat Cikoko',importance:Importance.high,
        playSound:true,enableVibration:true);
      await local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
      await local.initialize(const InitializationSettings(android:AndroidInitializationSettings('@drawable/ic_launcher')));
      await local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      _initialized=true;
    }catch(_){ /* In-app event inbox remains available. */ }
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(backgroundMessage);
      await FirebaseMessaging.instance.requestPermission(alert:true,badge:true,sound:true);
      final t=await FirebaseMessaging.instance.getToken();
      if(t!=null)await register(t);
      refresh=FirebaseMessaging.instance.onTokenRefresh.listen(register);
      incoming=FirebaseMessaging.onMessage.listen((m) async {
        if(api.token==null || !cikokoPushBelongsToAccount(m.data,api.profile?['id']))return;
        final id=m.data['event_id'];
        if(id is String && id.isNotEmpty){_seenEventIds.add(id);}
        final n=m.notification;
        if(n!=null&&_initialized) {
          await local.show(m.hashCode,n.title,n.body,
            const NotificationDetails(android:AndroidNotificationDetails('cikoko_updates_v2',
              'Aktivitas dan Pelayanan Cikoko',importance:Importance.max,priority:Priority.high,
              playSound:true,enableVibration:true)));
        }
        onRefresh();
      });
      opened=FirebaseMessaging.onMessageOpenedApp.listen((message){
        if(api.token!=null && cikokoPushBelongsToAccount(message.data,api.profile?['id'])){
          onOpen?.call(message);onRefresh();
        }
      });
      final initial=await FirebaseMessaging.instance.getInitialMessage();
      if(initial!=null && api.token!=null && cikokoPushBelongsToAccount(initial.data,api.profile?['id']))onOpen?.call(initial);
    }catch(_){ /* Server polling still works while application is open. */ }
  }
  // Cadangan saat aplikasi aktif: notifikasi baru dari polling API tetap tampil.
  // Push ketika aplikasi tertutup memerlukan konfigurasi FCM server + cron.
  Future<void> onEvents(List<dynamic> events) async {
    if(events.isEmpty)return;
    final nowIds=events.map((e)=>'${e['id']??''}').where((id)=>id.isNotEmpty).toSet();
    if(!_seeded){_seenEventIds.addAll(nowIds);_seeded=true;return;}
    final newer=events.where((e)=>!_seenEventIds.contains('${e['id']??''}') && '${e['is_read']??0}'!='1' && e['is_read']!=true).take(3).toList();
    _seenEventIds.addAll(nowIds);
    if(_seenEventIds.length>350){_seenEventIds.clear();_seenEventIds.addAll(nowIds);}
    if(!_initialized)return;
    for(final e in newer){
      try{await local.show(int.tryParse('${e['id']}')??DateTime.now().millisecondsSinceEpoch%1000000,
        '${e['title']??'Aktivitas Cikoko'}','${e['message']??''}',
        const NotificationDetails(android:AndroidNotificationDetails('cikoko_updates_v2','Kegiatan dan Pelayanan',importance:Importance.max,priority:Priority.high,playSound:true,enableVibration:true)));
      }catch(_){ }
    }
  }
  Future<void> register(String token) async {
    if(api.token!=null){try{await api.call('device',body:{'fcm_token':token});}catch(_){}}
  }

  /// Remove the account/device association before switching users. Deleting
  /// the Firebase token also invalidates delayed push delivery to old sessions.
  Future<void> unregisterDevice() async {
    try {
      final currentToken=await FirebaseMessaging.instance.getToken();
      if(currentToken!=null && api.token!=null){
        await api.call('device_unregister',body:{'fcm_token':currentToken});
      }
    } catch (_) {
      // Server upgrades and offline logout must remain possible.
    }
    try{await FirebaseMessaging.instance.deleteToken();}catch(_){}
    try{await local.cancelAll();}catch(_){}
  }
  void dispose(){refresh?.cancel();incoming?.cancel();opened?.cancel();}

}
