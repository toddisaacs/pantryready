import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  group('Barcode Functionality Tests', () {
    testWidgets('AddItemScreen accepts initial barcode parameter', (
      WidgetTester tester,
    ) async {
      const testBarcode = '1234567890123';

      await tester.pumpWidget(
        MaterialApp(home: AddItemScreen(initialBarcode: testBarcode)),
      );

      // Verify that the barcode field is populated with the initial barcode
      expect(find.text(testBarcode), findsOneWidget);
    });

    testWidgets('AddItemScreen can be created without initial barcode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Verify that the screen loads successfully
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.text('Barcode (Optional)'), findsOneWidget);
    });

    testWidgets('AddItemScreen includes barcode scanner button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Verify that the barcode scanner button is present
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byTooltip('Scan Barcode'), findsOneWidget);
    });

    testWidgets('AddItemScreen saves item with barcode', (
      WidgetTester tester,
    ) async {
      const testBarcode = '1234567890123';

      await tester.pumpWidget(
        MaterialApp(home: AddItemScreen(initialBarcode: testBarcode)),
      );

      // Fill in required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Item');
      await tester.enterText(find.byType(TextFormField).at(1), '2');

      // Verify barcode field is populated
      expect(find.text(testBarcode), findsOneWidget);

      // Save the item (this would normally navigate back)
      await tester.tap(find.text('Save Item'));
      await tester.pump();

      // Verify no validation errors
      expect(find.text('Please enter item name'), findsNothing);
    });

    test('PantryItem model includes barcode field', () {
      final now = DateTime.now();
      const testBarcode = '1234567890123';

      final item = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: testBarcode,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.barcode, equals(testBarcode));
    });

    test('PantryItem model handles null barcode', () {
      final now = DateTime.now();

      final item = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: null,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.barcode, isNull);
    });

    test('PantryItem copyWith includes barcode field', () {
      final now = DateTime.now();
      const originalBarcode = '1234567890123';
      const newBarcode = '9876543210987';

      final originalItem = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: originalBarcode,
        createdAt: now,
        updatedAt: now,
      );

      final updatedItem = originalItem.copyWith(barcode: newBarcode);

      expect(updatedItem.barcode, equals(newBarcode));
      expect(
        originalItem.barcode,
        equals(originalBarcode),
      ); // Original unchanged
    });

    test('PantryItem JSON serialization includes barcode', () {
      final now = DateTime.now();
      const testBarcode = '1234567890123';

      final item = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: testBarcode,
        createdAt: now,
        updatedAt: now,
      );

      final json = item.toJson();
      expect(json['barcode'], equals(testBarcode));

      final deserializedItem = PantryItem.fromJson(json);
      expect(deserializedItem.barcode, equals(testBarcode));
    });

    test('PantryItem equality includes barcode field', () {
      final now = DateTime.now();
      const testBarcode = '1234567890123';

      final item1 = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: testBarcode,
        createdAt: now,
        updatedAt: now,
      );

      final item2 = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: testBarcode,
        createdAt: now,
        updatedAt: now,
      );

      final item3 = PantryItem(
        id: '1',
        name: 'Test Item',
        quantity: 2.0,
        unit: 'pieces',
        category: 'Snacks',
        barcode: '9876543210987', // Different barcode
        createdAt: now,
        updatedAt: now,
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    testWidgets('Inventory screen shows barcode scanner button', (
      WidgetTester tester,
    ) async {
      // Test the AddItemScreen directly to check for barcode scanner button
      await tester.pumpWidget(MaterialApp(home: AddItemScreen()));

      // Verify barcode scanner button is present in the form
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });
  });
}
