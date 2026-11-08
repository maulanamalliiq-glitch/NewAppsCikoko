import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cikoko/api.dart';
import 'package:cikoko/support_chat.dart';
import 'package:cikoko/chat_receipt_indicator.dart';

void main(){
  test('Only server-confirmed read receipts render green and labels are explicit',(){
    expect(cikokoChatDelivery('sent'),CikokoChatDelivery.sent);
    expect(cikokoChatDelivery('delivered'),CikokoChatDelivery.delivered);
    expect(cikokoChatDelivery('read'),CikokoChatDelivery.read);
    expect(cikokoChatDelivery('read_legacy'),CikokoChatDelivery.legacyRead);
    expect(cikokoChatDelivery(null),CikokoChatDelivery.sent);
  });
  for(final item in [
    ('sent',1,'Terkirim ke server'),
    ('delivered',2,'Tersampaikan ke aplikasi penerima'),
    ('read',2,'Dibaca penerima'),
    ('read_legacy',1,'Dibaca (konfirmasi lama)'),
  ]){
    testWidgets('${item.$1} shows the expected dot count and status tooltip',(tester)async{
      await tester.pumpWidget(MaterialApp(home:Scaffold(
        body:CikokoChatReceiptIndicator(status:item.$1))));
      final dots=find.descendant(of:find.byType(CikokoChatReceiptIndicator),
        matching:find.byType(Container));
      expect(dots,findsNWidgets(item.$2));
      expect(find.byTooltip(item.$3),findsOneWidget);
    });
  }
  testWidgets('Old backend and stale GET cannot erase new message with identical text',(tester)async{
    final firstHistory=Completer<http.Response>();
    var getCount=0;
    final api=CikokoApi()..token='valid-session';
    final oldHistory=http.Response(
      '{"ok":true,"messages":[{"id":3,"sender":"warga","message":"admin","created_at":"2026-11-05 08:12:04"}],"has_more":false}',
      200,headers:{'content-type':'application/json'});
    await http.runWithClient(()async{
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:SupportChatPage(api:api))));
      await tester.pump();
      expect(find.byIcon(Icons.send_rounded),findsOneWidget);
      await tester.enterText(find.byType(TextField),'admin');
      await tester.tap(find.byTooltip('Kirim Pesan'));
      await tester.pump();
      expect(find.text('admin'),findsOneWidget);
      // Legacy backend sends {ok:true} with no message ID.
      await tester.pump(const Duration(milliseconds:20));
      firstHistory.complete(oldHistory);
      await tester.pump(const Duration(milliseconds:100));
      await tester.pump(const Duration(milliseconds:100));
      // The stale history remains, but the new outgoing bubble must survive.
      expect(find.text('admin'),findsNWidgets(2));
      expect(getCount,greaterThanOrEqualTo(2),
        reason:'Send must trigger a fresh GET even when the first GET is in flight');
      await tester.pump(const Duration(seconds:1));
    },()=>MockClient((request){
      if(request.method=='POST')return Future.value(
        http.Response('{"ok":true}',200,headers:{'content-type':'application/json'}));
      getCount++;
      return getCount==1?firstHistory.future:Future.value(oldHistory);
    }));
  });
  testWidgets('Outgoing message is visible even while initial history request is pending',(tester)async{
    final pendingGet=Completer<http.Response>();
    final pendingPost=Completer<http.Response>();
    final api=CikokoApi()..token='valid-session';
    await http.runWithClient(()async{
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:SupportChatPage(api:api))));
      await tester.pump();
      await tester.enterText(find.byType(TextField),'Pesan saat jaringan lambat');
      await tester.tap(find.byTooltip('Kirim Pesan'));
      await tester.pump();
      expect(find.text('Pesan saat jaringan lambat'),findsOneWidget);
      expect(find.byTooltip('Sedang mengirim'),findsOneWidget);
      pendingGet.complete(http.Response('{"ok":true,"messages":[],"receipt_updates":{}}',200));
      pendingPost.complete(http.Response('{"ok":true,"id":11,"sender":"warga"}',200));
      await tester.pump();
      await tester.pump(const Duration(seconds:1));
    },()=>MockClient((request)=>request.method=='POST'?pendingPost.future:pendingGet.future));
  });
  testWidgets('New outgoing chat is immediately visible during network delay',(tester)async{
    final pending=Completer<http.Response>();
    final api=CikokoApi()..token='valid-session';
    await http.runWithClient(()async{
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:SupportChatPage(api:api))));
      await tester.pump(const Duration(milliseconds:200));
      await tester.enterText(find.byType(TextField),'Pesan status uji warga');
      await tester.tap(find.byTooltip('Kirim Pesan'));
      await tester.pump();
      expect(find.text('Pesan status uji warga'),findsOneWidget);
      expect(find.byTooltip('Sedang mengirim'),findsOneWidget);
      pending.complete(http.Response('{"ok":true,"id":7,"sender":"warga","created_at":"2026-11-08 13:00:00"}',200,
        headers:{'content-type':'application/json'}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds:100));
      expect(find.text('Pesan status uji warga'),findsOneWidget);
      // Flush the API progress indicator's 900ms hide timer.
      await tester.pump(const Duration(seconds:1));
    },()=>MockClient((request){
      if(request.method=='POST')return pending.future;
      return Future.value(http.Response('{"ok":true,"messages":[],"receipt_updates":{},"has_more":false}',200,
        headers:{'content-type':'application/json'}));
    }));
  });
}
