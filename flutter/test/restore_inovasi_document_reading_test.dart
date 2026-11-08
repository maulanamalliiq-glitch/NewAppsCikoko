import 'package:cikoko/api.dart';
import 'package:cikoko/bottom_navigation_catalog.dart';
import 'package:cikoko/document_reading.dart';
import 'package:cikoko/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingApi extends CikokoApi {
  final List<String> actions = [];
  Map<String,String>? requestedDetail;
  Map<String,dynamic> listResult = {};
  bool listFails = false;

  _RecordingApi(String role) {
    profile = {'role':role,'id':'account-1'};
  }

  @override
  Future<Map<String,dynamic>> call(String action,
      {Map<String,dynamic>? body,bool authorized=false}) async {
    actions.add(action);
    if(listFails)throw ApiError('Daftar tidak tersedia.',statusCode:503);
    return listResult;
  }

  @override
  Future<Map<String,dynamic>> callWithParams(
    String action,Map<String,String> params) async {
    actions.add(action);
    requestedDetail = Map<String,String>.from(params);
    return {'ok':true, 'detail':{'id':params['id']??'0'},
      'timeline':[],'documents':[],'corrections':[]};
  }
}

void main() {
  test('Tab fourth is Innovation, not Notifications', () {
    expect(cikokoBottomRoute(3),'Inovasi');
    expect(cikokoBottomRoutes, ['Tentang Kami', 'Menu Cikoko',
      'Dashboard', 'Inovasi', 'Profil']);
    expect(cikokoBottomRoute(0),'Tentang Kami');
    expect(cikokoBottomRoute(2),'Dashboard');
    expect(cikokoBottomIndexForRoute('Dashboard',0),2);
    expect(cikokoBottomIndexForRoute('Inovasi',0),3);
    expect(cikokoBottomIndexForRoute('Notifikasi',3),3);
    expect(cikokoBottomRoute(4),'Profil');
  });

  test('Document with a valid numeric ID opens that exact ID', () async {
    final api=_RecordingApi('admin');
    await cikokoReadDocumentDetail(api,id:53,kind:'waris',
      reference:'AW-ABCDEF12');
    expect(api.actions,['document_detail']);
    expect(api.requestedDetail?['id'],'53');
    expect(api.requestedDetail?['reference'],'AW-ABCDEF12');
  });

  test('Old reference-only data resolves exact numeric ID from history', () async {
    final api=_RecordingApi('warga')
      ..listResult={'items':[
        {'id':19,'kind':'waris','reference':'AW-OTHER123'},
        {'id':51,'kind':'waris','reference':'AW-ABCDEF12'},
      ]};
    await cikokoReadDocumentDetail(api,id:0,kind:'waris',
      reference:'AW-ABCDEF12');
    expect(api.actions,['history','document_detail']);
    expect(api.requestedDetail?['id'],'51');
    expect(api.requestedDetail?['kind'],'waris');
  });

  test('Missing list ID falls back to server reference, never guessed ID', () async {
    final api=_RecordingApi('admin')..listFails=true;
    await cikokoReadDocumentDetail(api,id:0,kind:'waris',
      reference:'AW-ABCDEF12');
    expect(api.actions,['admin_reports','document_detail']);
    expect(api.requestedDetail?.containsKey('id'),isFalse);
    expect(api.requestedDetail?['reference'],'AW-ABCDEF12');
  });

  test('Missing report ID never masquerades as an inheritance ID', () async {
    final api=_RecordingApi('admin');
    await cikokoReadDocumentDetail(api,id:0,kind:'report');
    expect(api.requestedDetail?.containsKey('id'),isFalse);
    expect(api.requestedDetail?['kind'],'report');
  });

  test('Document errors are actionable without revealing backend internals', () {
    expect(cikokoDocumentFailure(ApiError('Forbidden',statusCode:403)),
      contains('izin'));
    expect(cikokoDocumentFailure(ApiError('Not found',statusCode:404)),
      contains('tidak ditemukan'));
    expect(cikokoDocumentFailure(ApiError(
      'SQLSTATE[HY000] invalid column',statusCode:503)),contains('HTTP 503'));
    expect(cikokoDocumentFailure(ApiError(
      'SQLSTATE[HY000] invalid column',statusCode:503)),
      isNot(contains('SQLSTATE')));
  });

  testWidgets('Failed notification sync is never reported as no notifications',
      (tester) async {
    var retries=0;
    await tester.pumpWidget(MaterialApp(
      home:Scaffold(body:CikokoNotificationsPage(
        events:const [],
        loadError:'Notifikasi belum dapat disinkronkan dari server.',
        onRetry:()=>retries++,
        onOpen:(_){},
      )),
    ));
    expect(find.textContaining('belum dapat disinkronkan'),findsOneWidget);
    expect(find.text('Belum ada notifikasi untuk akun ini.'),findsNothing);
    await tester.tap(find.byKey(const Key('notification_retry')));
    expect(retries,1);
    expect(tester.takeException(),isNull);
  });
}
