import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskarro/main.dart';

void main() {
  group('Taskarro Widget Tests', () {
    testWidgets('Welcome screen displays Taskarro correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskarroApp());

      // App name
      expect(find.text('Taskarro'), findsOneWidget);

      // Welcome message
      expect(find.text('Ready for your next adventure?'), findsOneWidget);

      // User selection question
      expect(find.text("Who's using Taskarro?"), findsOneWidget);

      // Parent button
      expect(find.text('Enter Parent Mode'), findsOneWidget);

      // Child button
      expect(find.text('Enter Child Mode'), findsOneWidget);

      // Taskarro star icon
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('Parent Mode button opens Parent Login screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskarroApp());

      // Press Parent Mode
      await tester.tap(find.text('Enter Parent Mode'));

      await tester.pumpAndSettle();

      // Parent login should appear
      expect(find.text('Parent Login'), findsOneWidget);

      expect(find.text('Welcome, Parent!'), findsOneWidget);

      expect(find.text('Email'), findsOneWidget);

      expect(find.text('Password'), findsOneWidget);

      expect(find.text('Log In'), findsOneWidget);

      expect(find.text('Create a parent account'), findsOneWidget);
    });

    testWidgets('Parent login shows validation errors for empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskarroApp());

      // Open Parent Login
      await tester.tap(find.text('Enter Parent Mode'));

      await tester.pumpAndSettle();

      // Press login without entering anything
      await tester.tap(find.text('Log In'));

      await tester.pump();

      // Validation messages
      expect(find.text('Please enter your email'), findsOneWidget);

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Create parent account button opens sign up screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskarroApp());

      // Open Parent Login
      await tester.tap(find.text('Enter Parent Mode'));

      await tester.pumpAndSettle();

      // Open Sign Up
      await tester.tap(find.text('Create a parent account'));

      await tester.pumpAndSettle();

      // Verify Sign Up screen opened
      expect(find.byType(Form), findsWidgets);
    });
  });
}
