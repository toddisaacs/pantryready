import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/main.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/edit_item_screen.dart';
import 'package:pantryready/screens/inventory_item_detail_screen.dart';

void main() {
  group('Edit Functionality Tests', () {
    late PantryItem testItem;

    setUp(() {
      final now = DateTime.now();
      testItem = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        expiryDate: now.add(const Duration(days: 7)),
        notes: 'Test notes',
        barcode: '1234567890123',
        createdAt: now,
        updatedAt: now,
      );
    });

    testWidgets('EditItemScreen pre-populates fields with existing item data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EditItemScreen(item: testItem)),
      );

      // Verify that all fields are pre-populated
      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
      expect(find.text('1234567890123'), findsOneWidget);

      // Check that the screen title is correct
      expect(find.text('Edit Item'), findsOneWidget);
      expect(find.text('Update Item'), findsOneWidget);
    });

    testWidgets('EditItemScreen validates required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EditItemScreen(item: testItem)),
      );

      // Clear the name field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Test Item'),
        '',
      );

      // Clear the quantity field
      await tester.enterText(find.widgetWithText(TextFormField, '2.0'), '');

      // Try to save
      await tester.tap(find.text('Update Item'));
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter quantity'), findsOneWidget);
    });

    testWidgets('EditItemScreen validates quantity is positive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EditItemScreen(item: testItem)),
      );

      // Enter invalid quantity
      await tester.enterText(find.widgetWithText(TextFormField, '2.0'), '-1');

      // Try to save
      await tester.tap(find.text('Update Item'));
      await tester.pumpAndSettle();

      // Verify validation message
      expect(find.text('Enter a valid number'), findsOneWidget);
    });

    testWidgets('EditItemScreen can clear expiry date', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EditItemScreen(item: testItem)),
      );

      // Initially should show the expiry date
      expect(find.textContaining('/'), findsOneWidget); // Date format

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Should now show 'Not set'
      expect(find.text('Not set'), findsOneWidget);
    });

    testWidgets('EditItemScreen includes barcode scanner button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EditItemScreen(item: testItem)),
      );

      // Verify that the barcode scanner button is present
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byTooltip('Scan Barcode'), findsOneWidget);
    });

    testWidgets('EditItemScreen has Save button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EditItemScreen(item: testItem)),
      );

      // Verify that the Save button is in the app bar
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets(
      'InventoryItemDetailScreen shows edit button when onEdit is provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: InventoryItemDetailScreen(
              item: testItem,
              onEdit: (item) {
                // Callback for when edit is completed
              },
            ),
          ),
        );

        // Verify edit button is present
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byTooltip('Edit Item'), findsOneWidget);

        // Tap edit button should navigate to EditItemScreen
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Verify we navigated to EditItemScreen
        expect(find.text('Edit Item'), findsOneWidget); // EditItemScreen title
        expect(
          find.text('Update Item'),
          findsOneWidget,
        ); // EditItemScreen button

        // The callback is only called when EditItemScreen returns with a result,
        // which doesn't happen in this test since we don't simulate saving
      },
    );

    testWidgets(
      'InventoryItemDetailScreen hides edit button when onEdit is null',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: InventoryItemDetailScreen(item: testItem, onEdit: null),
          ),
        );

        // Verify edit button is not present
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    test(
      'PantryItem copyWith preserves id and timestamps correctly for edit',
      () {
        final now = DateTime.now();
        final originalItem = PantryItem(
          id: '123',
          name: 'Original Item',
          quantity: 1.0,
          unit: 'pieces',
          category: 'Snacks',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );

        final updatedItem = originalItem.copyWith(
          name: 'Updated Item',
          quantity: 3.0,
          updatedAt: now,
        );

        // ID should remain the same
        expect(updatedItem.id, equals(originalItem.id));

        // CreatedAt should remain the same
        expect(updatedItem.createdAt, equals(originalItem.createdAt));

        // UpdatedAt should be different
        expect(updatedItem.updatedAt, isNot(equals(originalItem.updatedAt)));

        // Updated fields should be changed
        expect(updatedItem.name, equals('Updated Item'));
        expect(updatedItem.quantity, equals(3.0));

        // Non-updated fields should remain the same
        expect(updatedItem.unit, equals(originalItem.unit));
        expect(updatedItem.category, equals(originalItem.category));
      },
    );

    testWidgets('Inventory list items show edit button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PantryReadyApp());

      // Navigate to inventory screen
      await tester.tap(find.text('Inventory'));
      await tester.pump();

      // Should show edit icons for list items (if any items exist)
      // Note: This test assumes sample data exists
      final editButtons = find.byIcon(Icons.edit);
      expect(editButtons, findsWidgets); // Should find at least one edit button
    });

    test('EditItemScreen creates updated item with correct timestamp', () {
      final now = DateTime.now();
      final originalItem = PantryItem(
        id: '1',
        name: 'Original',
        quantity: 1.0,
        unit: 'pieces',
        category: 'Snacks',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      );

      // Simulate what happens in EditItemScreen._saveItem()
      final updatedItem = originalItem.copyWith(
        name: 'Updated Name',
        quantity: 5.0,
        updatedAt: DateTime.now(),
      );

      expect(updatedItem.name, equals('Updated Name'));
      expect(updatedItem.quantity, equals(5.0));
      expect(updatedItem.id, equals(originalItem.id));
      expect(updatedItem.createdAt, equals(originalItem.createdAt));
      expect(updatedItem.updatedAt.isAfter(originalItem.updatedAt), true);
    });
  });
}
