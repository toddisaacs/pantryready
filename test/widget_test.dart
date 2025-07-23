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

  testWidgets('Delete item functionality works correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PantryReadyApp());

    // Navigate to inventory
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    // Tap on an item to open detail screen
    await tester.tap(find.text('Bottled Water'));
    await tester.pumpAndSettle();

    // Verify we're on the detail screen (item name appears in title and body)
    expect(find.text('Bottled Water'), findsWidgets);

    // Tap the delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify delete confirmation dialog appears
    expect(find.text('Delete Item'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete "Bottled Water"?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Tap Delete to confirm
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify we're back to inventory screen and item is deleted
    expect(find.text('Bottled Water'), findsNothing);
    expect(find.text('Bottled Water deleted successfully'), findsOneWidget);
  });

  testWidgets('Delete confirmation can be cancelled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PantryReadyApp());

    // Navigate to inventory
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    // Tap on an item to open detail screen
    await tester.tap(find.text('Canned Beans'));
    await tester.pumpAndSettle();

    // Tap the delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify delete confirmation dialog appears
    expect(find.text('Delete Item'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify we're still on detail screen and item still exists (appears in title and body)
    expect(find.text('Canned Beans'), findsWidgets);

    // Go back to inventory
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify item is still in inventory
    expect(find.text('Canned Beans'), findsOneWidget);
  });
}
