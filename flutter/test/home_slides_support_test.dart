import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/api.dart';
import '../lib/home_slides.dart';
import '../lib/role_catalog.dart';
import '../lib/support_chat.dart';
class HomeApi extends CikokoApi {
  final actions=<String>[];
  bool failChat=false;
  @override Future<Map<String,dynamic>> call(String action,{Map<String,dynamic>? body,bool authorized=false})async{
    actions.add(action);
    if(action=='home_slides')return {'slides':[{'name':'${'a'*40}.jpg'},{'name':'${'b'*40}.jpg'}]};
    if(failChat)throw ApiError('HTTP 503');
    return {'messages':[]};
  }
}
void main(){
  test('Residents have help and only main administrator has photo management',(){
    expect(modulesForRole('warga',{}).map((f)=>f.route),contains('Hubungi Kami'));
    expect(modulesForRole('admin',{'role:manage':true,'chat:reply':true}).map((f)=>f.route),containsAll(['Foto Beranda','Pesan Masuk']));
    expect(modulesForRole('asn',{'role:manage':true}).map((f)=>f.route),isNot(contains('Foto Beranda')));
  });
  testWidgets('Home photos advance automatically without greeting or avatar',(tester)async{
    final api=HomeApi();
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:CikokoHomeSlideshow(api:api))));
    await tester.pumpAndSettle();
    expect(find.byType(Text),findsNothing);
    expect(find.byType(CircleAvatar),findsNothing);
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page,0);
    await tester.pump(const Duration(seconds:5));
    await tester.pump(const Duration(milliseconds:700));
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page,1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(),isNull);
  });
  testWidgets('Help opens resident chat and failure is not reported as empty inbox',(tester)async{
    final api=HomeApi()..failChat=true;
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:SupportChatPage(api:api))));
    await tester.pumpAndSettle();
    expect(api.actions,contains('chat'));
    expect(find.text('Hubungi Admin'),findsOneWidget);
    expect(find.text('Belum ada pesan'),findsNothing);
    expect(find.textContaining('HTTP'),findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
