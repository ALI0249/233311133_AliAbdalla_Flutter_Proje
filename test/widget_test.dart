import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muzem/features/splash/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Müzem'), findsOneWidget);
    expect(find.text('Müze Bilet Takip Sistemi'), findsOneWidget);
  });
}
