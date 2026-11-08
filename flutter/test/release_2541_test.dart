import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/adaptive_poll.dart';

void main(){
 testWidgets('Quiet polling backs off, never overlaps and cancels on disposal',(tester)async{
  var calls=0,active=0,maxActive=0;
  final poller=AdaptivePoller(()async{calls++;active++;if(active>maxActive)maxActive=active;await Future<void>.delayed(const Duration(seconds:2));active--;return false;});
  addTearDown(poller.cancel);poller.start();await tester.pump(const Duration(milliseconds:1));expect(calls,1);
  await tester.pump(const Duration(seconds:2));expect(poller.delay,const Duration(seconds:6));
  await tester.pump(const Duration(seconds:6));expect(calls,2);
  await tester.pump(const Duration(seconds:2));expect(maxActive,1);
  poller.cancel();await tester.pump(const Duration(minutes:1));expect(calls,2);
 });
 testWidgets('Changed polling returns to the minimum interval',(tester)async{
  var changed=false;
  final poller=AdaptivePoller(()async=>changed);
  addTearDown(poller.cancel);poller.start();await tester.pump(const Duration(milliseconds:1));expect(poller.delay,const Duration(seconds:6));
  changed=true;await tester.pump(const Duration(seconds:6));expect(poller.delay,const Duration(seconds:3));poller.cancel();
 });
}
