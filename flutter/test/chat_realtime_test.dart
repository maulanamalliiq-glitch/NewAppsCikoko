import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/chat_launcher.dart';
import '../lib/event_scope.dart';
import '../lib/push.dart';

void main(){
 test('First notification after an initially empty inbox is delivered once',(){
   final tracker=CikokoEventTracker();
   expect(tracker.takeNew([]),isEmpty);
   final incoming=[{'id':1,'category':'chat','is_read':0}];
   expect(tracker.takeNew(incoming).single['id'],1);
   expect(tracker.takeNew(incoming),isEmpty);
 });
 test('Historical, already read, and FCM-displayed events do not alert twice',(){
   final tracker=CikokoEventTracker();
   expect(tracker.takeNew([{'id':1,'is_read':0}]),isEmpty);
   tracker.markSeen('2');
   expect(tracker.takeNew([{'id':1,'is_read':0},{'id':2,'is_read':0},{'id':3,'is_read':1}]),isEmpty);
 });
 test('Staff without support permission opens their own administrator conversation',(){
   expect(destinationForPushCategory('chat',isStaff:true,canReply:false),'Hubungi Kami');
   expect(destinationForPushCategory('chat',isStaff:true,canReply:true),'Pesan Masuk');
 });
 testWidgets('Corner launcher displays unread badge and opens the correct action',(tester)async{
   var opened=0;
   await tester.pumpWidget(MaterialApp(home:Scaffold(floatingActionButton:CikokoChatLauncher(
     administrative:true,unreadCount:3,onPressed:()=>opened++))));
   expect(find.byTooltip('Chat Warga'),findsOneWidget);
   expect(find.text('3'),findsOneWidget);
   await tester.tap(find.byKey(const Key('floating_chat_launcher')));
   expect(opened,1);
   expect(tester.takeException(),isNull);
 });
}
