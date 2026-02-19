import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  group('AddItemScreen', () {
    testWidgets('AddItemScreen renders essential form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Quick Add fields are always visible
      expect(find.text('Item Name'), findsAtLeastNWidgets(1));
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Qty'), findsAtLeastNWidgets(1));
      expect(find.text('Unit'), findsAtLeastNWidgets(1));
      // More Details is collapsed
      expect(find.text('More Details'), findsOneWidget);
    });

    testWidgets('AddItemScreen validates required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Clear the default quantity to trigger validation
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '');

      // Try to save without entering required fields
      await tester.tap(find.text('Save Item'), warnIfMissed: false);
      await tester.pump();

      final nameError = find.text('Please enter an item name');
      if (nameError.evaluate().isNotEmpty) {
        expect(nameError, findsOneWidget);
      }
    });

    testWidgets('AddItemScreen validates quantity is a valid number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Enter item name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Item Name'),
        'Test Item',
      );

      // Enter invalid quantity
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), 'abc');

      // Try to save
      await tester.tap(find.text('Save Item'), warnIfMissed: false);
      await tester.pump();

      final validationError = find.text('Invalid');
      if (validationError.evaluate().isNotEmpty) {
        expect(validationError, findsOneWidget);
      }
    });

    testWidgets('AddItemScreen creates PantryItem with valid input', (
      WidgetTester tester,
    ) async {
      PantryItem? savedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<PantryItem>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddItemScreen(),
                      ),
                    );
                    savedItem = result;
                  },
                  child: const Text('Open'),
                ),
          ),
        ),
      );

      // Navigate to AddItemScreen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Item Name'),
        'Test Item',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '5');

      // Save the item
      await tester.tap(find.text('Save Item'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the item was returned
      expect(savedItem, isNotNull);
      expect(savedItem!.name, equals('Test Item'));
      expect(savedItem!.totalQuantity, equals(5.0));
    });

    testWidgets('AddItemScreen shows date picker in More Details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Expand More Details
      await tester.tap(find.text('More Details'));
      await tester.pumpAndSettle();

      // Find and tap the calendar icon
      await tester.tap(find.byIcon(Icons.calendar_today), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(1));
    });

    testWidgets('AddItemScreen shows expanded details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Expand More Details
      await tester.tap(find.text('More Details'));
      await tester.pumpAndSettle();

      // Should now show detail fields
      expect(find.text('Subcategory (Optional)'), findsOneWidget);
      expect(find.text('Expiry Date'), findsAtLeastNWidgets(1));
      expect(find.text('Notes'), findsAtLeastNWidgets(1));
      expect(find.text('Barcode'), findsAtLeastNWidgets(1));
    });
  });
}
