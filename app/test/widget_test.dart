// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('shows the auth landing screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TasteBookApp(initialRoute: '/auth'));
    await tester.pumpAndSettle();

    // 'Log In' may appear in multiple places (title + button), so ensure at least one exists.
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });
}
