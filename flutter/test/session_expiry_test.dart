import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cikoko/api.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 setUp(()=>FlutterSecureStorage.setMockInitialValues({}));
 test('Expired session clears token even for an HTML 401 response',()async{
  final api=CikokoApi()..token='expired'..profile={'id':'one'};
  await http.runWithClient(()async{await expectLater(api.call('me'),throwsA(isA<ApiError>()));},()=>MockClient((_)async=>http.Response('<html>Unauthorized</html>',401)));
  expect(api.token,isNull);expect(api.profile,isNull);expect(api.sessionRevision.value,greaterThan(0));
 });
 test('Permission denial preserves the authenticated account',()async{
  final api=CikokoApi()..token='valid'..profile={'id':'one'};
  await http.runWithClient(()async{await expectLater(api.call('staff_only'),throwsA(isA<ApiError>()));},()=>MockClient((_)async=>http.Response('{"ok":false,"error":"Tidak memiliki hak akses"}',403)));
  expect(api.token,'valid');
 });
 test('Delayed 401 from an old token cannot log out a new session',()async{
  final api=CikokoApi()..token='old';final response=Completer<http.Response>();
  await http.runWithClient(()async{
   final pending=api.call('me');await Future<void>.delayed(Duration.zero);api.token='new';response.complete(http.Response('{"ok":false}',401));await expectLater(pending,throwsA(isA<ApiError>()));
  },()=>MockClient((_)=>response.future));
  expect(api.token,'new');
 });
}
