import 'package:cikoko/api.dart';
import 'package:cikoko/bottom_navigation_catalog.dart';
import 'package:cikoko/design_system.dart';
import 'package:cikoko/document_reading.dart';
import 'package:cikoko/premium_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Approved bottom navigation remains unchanged', () {
    expect(cikokoBottomRoutes, <String>[
      'Dashboard','Layanan Online','Menu Cikoko','Inovasi','Profil',
    ]);
  });

  for (final width in [320.0, 360.0, 420.0]) {
    testWidgets('Full brand fits a compact phone at $width pixels',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      await tester.pumpWidget(MaterialApp(
        theme:CikokoDesign.light,
        home:Scaffold(appBar:AppBar(
          title:const CikokoAppBarIdentity(roleName:'Admin Utama'),
          actions:const [
            IconButton(
              onPressed:null,
              icon:Icon(Icons.notifications_none),
            ),
            IconButton(
              onPressed:null,
              icon:Icon(Icons.more_vert),
            ),
          ],
        )),
      ));
      final titleParts=find.text('Cikoko');
      final full=find.text('Cikoko SmartAPP');
      final second=find.text('SmartAPP');
      expect(full.evaluate().isNotEmpty ||
        (titleParts.evaluate().isNotEmpty && second.evaluate().isNotEmpty),
        isTrue);
      expect(find.text('Admin Utama'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });
  }

  test('Correct document payload stays intact', () {
    final payload=<String,dynamic>{
      'detail':{'id':52,'status':'masuk','children':[]},
      'timeline':[{'new_status':'masuk'}],
      'documents':[],
      'corrections':[],
    };
    expect(identical(cikokoValidateDocumentPayload(payload),payload),isTrue);
  });

  test('Incomplete 200 response cannot crash the detail widget', () {
    expect(() => cikokoValidateDocumentPayload(<String,dynamic>{
      'ok':true, 'detail':null,
    }),throwsA(isA<ApiError>()));
    expect(() => cikokoValidateDocumentPayload(<String,dynamic>{
      'detail':{'id':44},'timeline':'unknown',
    }),throwsA(isA<ApiError>()));
    expect(() => cikokoValidateDocumentPayload(<String,dynamic>{
      'detail':{'id':44,'children':['unparseable']},
    }),throwsA(isA<ApiError>()));
  });

  test('Malformed backend data gets only a safe public error message', () {
    try {
      cikokoValidateDocumentPayload(<String,dynamic>{
        'detail':{'id':44},'documents':'SQLSTATE server internal',
      });
      fail('An incomplete response must fail closed');
    }on ApiError catch (error) {
      expect(error.statusCode,502);
      expect(cikokoDocumentFailure(error),contains('HTTP 502'));
      expect(cikokoDocumentFailure(error),isNot(contains('SQLSTATE')));
    }
  });
}
