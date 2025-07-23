import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/constants/app_constants.dart';

void main() {
  group('AddItemScreen', () {
    testWidgets('renders all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Verify all form fields are present
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Item Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Quantity'), findsOneWidget);
      expect(find.text('Unit'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Expiry Date'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save Item'), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Try to save without filling required fields
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter quantity'), findsOneWidget);
      expect(find.text('Select unit'), findsOneWidget);
      expect(find.text('Select category'), findsOneWidget);
    });

    testWidgets('validates quantity is a positive number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Enter invalid quantity
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity'),
        '-1',
      );
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      // Verify validation message
      expect(find.text('Enter a valid number'), findsOneWidget);
    });

    testWidgets('creates PantryItem with valid input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Fill in form fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Item Name'),
        'Test Item',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity'),
        '5',
      );

      // Select unit
      await tester.tap(find.text('Unit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppConstants.units.first).last);
      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppConstants.categories.first).last);
      await tester.pumpAndSettle();

      // Add notes
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes'),
        'Test notes',
      );

      // Save the item
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      // Verify navigation with created item
      expect(find.byType(AddItemScreen), findsNothing);
    });

    testWidgets('shows date picker on calendar icon tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Tap calendar icon
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Verify date picker is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('updates expiry date when selected from picker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Initial state should show 'Not set'
      expect(find.text('Not set'), findsOneWidget);

      // Tap calendar icon
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Select a date (today)
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify date is no longer 'Not set'
      expect(find.text('Not set'), findsNothing);
    });
  });
}
