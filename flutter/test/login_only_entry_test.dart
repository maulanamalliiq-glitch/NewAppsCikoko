import 'package:cikoko/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Logged-out entry shows only login, never the public dashboard',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    await tester.pumpWidget(MaterialApp(
      home: CikokoAuthGate(
        authenticated: false,
        onAuthenticated: () {},
        onLogout: () {},
      ),
    ));
    expect(find.byKey(const ValueKey('standalone_login')), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Masuk ke Cikoko SmartAPP'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
    expect(find.byTooltip('Kembali'), findsNothing);
    expect(tester.takeException(), isNull);

    // Scrolling the login page must never reveal guest home content.
    await tester.drag(find.byType(SingleChildScrollView).first,
      const Offset(0, -350));
    await tester.pump();
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Registration stays inside login, without a guest home route',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 820));
    await tester.pumpWidget(MaterialApp(
      home: CikokoAuthGate(
        authenticated: false,
        onAuthenticated: () {},
        onLogout: () {},
      ),
    ));
    await tester.tap(find.text('Daftar Akun Baru'));
    await tester.pump();
    expect(find.text('Daftar Akun Warga'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.binding.setSurfaceSize(null);
  });
}
