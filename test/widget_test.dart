import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safemom/features/auth/presentation/pages/welcome_page.dart';

void main() {
  testWidgets('WelcomePage shows greeting and CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));

    expect(find.text('Karibu, Mama'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Kiswahili'), findsOneWidget);
  });
}