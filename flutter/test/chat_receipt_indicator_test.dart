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
    },()=>MockClient((request){
      if(request.method=='POST')return pending.future;
      return Future.value(http.Response('{"ok":true,"messages":[],"receipt_updates":{},"has_more":false}',200,
        headers:{'content-type':'application/json'}));
    }));
  });
}
