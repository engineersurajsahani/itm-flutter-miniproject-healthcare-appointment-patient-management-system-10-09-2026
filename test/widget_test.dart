import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthcare_system/main.dart';
import 'package:healthcare_system/models/user_role.dart';

void main() {
  testWidgets('user signs in to the patient workspace', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HealthcareApp());

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'patient@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Find a specialist'), findsOneWidget);
    expect(find.text('Book appointment'), findsOneWidget);
  });

  testWidgets('administrator sees operations workspace', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HealthcareApp());

    await tester.tap(find.byType(DropdownButtonFormField<UserRole>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administrator').last);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Operations center'), findsOneWidget);
    expect(find.text('Patient directory'), findsOneWidget);
  });
}
