// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/main.dart';

void main() {
  testWidgets('Home screen displays welcome message and navigation bar', (
    WidgetTester tester,
  ) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const PantryReadyApp());

    // Verify the welcome message is shown on the Home screen.
    expect(find.text('Welcome to PantryReady!'), findsOneWidget);

    // Verify the bottom navigation bar is present with expected items.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Inventory screen displays items grouped by category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PantryReadyApp());

    // Tap the Inventory tab
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    // Check for the first visible category and items (sorted alphabetically)
    expect(find.text('Beverages'), findsWidgets);
    expect(find.text('Bottled Water'), findsOneWidget);

    // Scroll down to see more categories
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Canned Goods'), findsWidgets);
    expect(find.text('Canned Beans'), findsOneWidget);

    // Scroll further to see Grains category
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Grains'), findsWidgets);
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Pinto Beans'), findsOneWidget);

    // Scroll to see Condiments
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Condiments'), findsWidgets);
    expect(find.text('Peanut Butter'), findsOneWidget);
  });
}
