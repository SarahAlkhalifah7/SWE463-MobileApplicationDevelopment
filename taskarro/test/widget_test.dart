import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskarro/main.dart';

void main() {
  testWidgets('Taskarro welcome screen displays correctly', (
    WidgetTester tester,
  ) async {
    // Build the Taskarro app
    await tester.pumpWidget(const TaskarroApp());

    // Verify app title
    expect(find.text('Taskarro'), findsOneWidget);

    // Verify welcome message
    expect(find.text('Ready for your next adventure?'), findsOneWidget);

    // Verify mode selection
    expect(find.text("Who's using Taskarro?"), findsOneWidget);

    // Verify Parent Mode button
    expect(find.text('Enter Parent Mode'), findsOneWidget);

    // Verify Child Mode button
    expect(find.text('Enter Child Mode'), findsOneWidget);

    // Verify star icon
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
  });
}
