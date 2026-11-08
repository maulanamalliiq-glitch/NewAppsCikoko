import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/api.dart';
import '../lib/role_catalog.dart';
import '../lib/officer_review.dart';

class ReviewApi extends CikokoApi {
  bool canVerify=true;
  final List<Map<String,String>> queries=[];
  final List<String> actions=[];
  @override Future<Map<String,dynamic>> callWithParams(String action,Map<String,String> params) async {
    actions.add(action);queries.add(Map.of(params));
    if(action=='officer_reports')return {'items':[
      {'id':1,'source':'ppsu','category':'ppsu','name':'Petugas Uji','created_at':'2026-11-08','status':'masuk','rt':'01','rw':'02'},
    ],'total':1,'next_offset':null,'can_verify':canVerify};
    return {'detail':{'id':1,'source':'ppsu','category':'ppsu','name':'Petugas Uji','status':'masuk','work_date':'2026-11-08','activity':'Kegiatan uji','address':'Cikoko','team':'Taman','photo_count':0},'history':[],'can_verify':canVerify};
  }
  @override Future<Map<String,dynamic>> call(String action,{Map<String,dynamic>? body,bool authorized=false}) async {
    actions.add(action);
    if(action=='territory_monitoring')return {'total':2,'statuses':{'masuk':1,'selesai':1},'categories':{'ppsu':1,'waris':1},'areas':[
      {'rt':'01','rw':'02','total':1,'pending':1,'completed':0},
      {'rt':'','rw':'','total':1,'pending':0,'completed':1},
    ],'area_basis':'Wilayah mengikuti profil pelapor.'};
    return {'ok':true};
  }
}
void main(){
  final grants={for(final key in ['reports:view','reports:verify','waris:view','waris:verify','monitoring:view'])key:true};
  test('ASN and admin both expose the three requested officer modules',(){
    for(final role in ['asn','admin']){
      final routes=modulesForRole(role,grants).map((f)=>f.route);
      expect(routes,containsAll(['Verifikasi Laporan','Verifikasi Ahli Waris','Monitoring Wilayah']));
    }
    expect(modulesForRole('asn',grants).any((f)=>f.route=='Kelola Akun Petugas'),isFalse);
    expect(roleMenus['admin'],contains('accounts_manage'));
  });
  test('Revoked grants hide the related ASN modules',(){
    final routes=modulesForRole('asn',{}).map((f)=>f.route);
    expect(routes, isNot(contains('Verifikasi Laporan')));
    expect(routes, isNot(contains('Verifikasi Ahli Waris')));
    expect(routes, isNot(contains('Monitoring Wilayah')));
  });
  testWidgets('Report review opens the matching source and preserves read-only access',(tester) async {
    final api=ReviewApi()..canVerify=false;
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:OfficerReportsPage(api:api))));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    expect(api.queries.last['source'],'ppsu');
    expect(api.queries.last['id'],'1');
    expect(find.text('Simpan Hasil Verifikasi'),findsNothing);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Monitoring labels missing territory separately',(tester)async{
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:TerritoryMonitoringPage(api:ReviewApi()))));
    await tester.pumpAndSettle();
    expect(find.text('Total Laporan dan Pengajuan: 2'),findsOneWidget);
    await tester.scrollUntilVisible(find.text('Wilayah belum tercatat'),250);
    expect(find.text('Wilayah belum tercatat'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
