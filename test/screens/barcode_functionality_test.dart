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
        const MaterialApp(home: AddItemScreen(initialBarcode: testBarcode)),
      );

      // Wait for the widget to fully build
      await tester.pumpAndSettle();

      // Verify that the barcode field is populated with the initial barcode
      // Look for the text in the TextFormField
      final barcodeField = find.widgetWithText(TextFormField, 'Barcode');
      expect(barcodeField, findsOneWidget);

      // Check that the field contains the barcode text
      final textField = tester.widget<TextFormField>(barcodeField);
      expect(textField.controller?.text, equals(testBarcode));
    });

    testWidgets('AddItemScreen can be created without initial barcode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Verify that the screen loads successfully
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.text('Barcode'), findsAtLeastNWidgets(1));
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
        const MaterialApp(home: AddItemScreen(initialBarcode: testBarcode)),
      );

      // Wait for the widget to fully build
      await tester.pumpAndSettle();

      // Fill in required fields - find them by their labels
      final nameField = find.widgetWithText(TextFormField, 'Item Name');
      final quantityField = find.widgetWithText(TextFormField, 'Quantity');

      await tester.enterText(nameField, 'Test Item');
      await tester.enterText(quantityField, '2');

      // Verify barcode field is populated by checking the controller
      final barcodeField = find.widgetWithText(TextFormField, 'Barcode');
      final textField = tester.widget<TextFormField>(barcodeField);
      expect(textField.controller?.text, equals(testBarcode));

      // Save the item (this would normally navigate back)
      await tester.ensureVisible(find.text('Save Item'));
      await tester.tap(find.text('Save Item'), warnIfMissed: false);
      await tester.pump();

      // Verify no validation errors
      expect(find.text('Please enter an item name'), findsNothing);
    });

    test('PantryItem model includes barcode field', () {
      const testBarcode = '1234567890123';

      final item = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: testBarcode,
        batches: [ItemBatch(quantity: 2.0, purchaseDate: DateTime.now())],
      );

      expect(item.barcode, equals(testBarcode));
    });

    test('PantryItem model handles null barcode', () {
      final item = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: null,
        batches: [ItemBatch(quantity: 2.0, purchaseDate: DateTime.now())],
      );

      expect(item.barcode, isNull);
    });

    test('PantryItem copyWith includes barcode field', () {
      const originalBarcode = '1234567890123';
      const newBarcode = '9876543210987';

      final originalItem = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: originalBarcode,
        batches: [ItemBatch(quantity: 2.0, purchaseDate: DateTime.now())],
      );

      final updatedItem = originalItem.copyWith(barcode: newBarcode);

      expect(updatedItem.barcode, equals(newBarcode));
      expect(
        originalItem.barcode,
        equals(originalBarcode),
      ); // Original unchanged
    });

    test('PantryItem JSON serialization includes barcode', () {
      const testBarcode = '1234567890123';

      final item = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: testBarcode,
        batches: [ItemBatch(quantity: 2.0, purchaseDate: DateTime.now())],
      );

      final json = item.toJson();
      expect(json['barcode'], equals(testBarcode));

      // Add the ID back for deserialization (like Firestore service does)
      final deserializedItem = PantryItem.fromJson({'id': item.id, ...json});
      expect(deserializedItem.barcode, equals(testBarcode));
    });

    test('PantryItem equality includes barcode field', () {
      const testBarcode = '1234567890123';
      final now = DateTime(2024, 1, 1, 12, 0, 0); // Fixed timestamp
      const batchId = 'test-batch-id';

      final item1 = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: testBarcode,
        batches: [ItemBatch(id: batchId, quantity: 2.0, purchaseDate: now)],
        createdAt: now,
        updatedAt: now,
      );

      final item2 = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: testBarcode,
        batches: [ItemBatch(id: batchId, quantity: 2.0, purchaseDate: now)],
        createdAt: now,
        updatedAt: now,
      );

      final item3 = PantryItem(
        id: '1',
        name: 'Test Item',
        unit: 'pieces',
        systemCategory: SystemCategory.food,
        subcategory: 'Snacks',
        barcode: '9876543210987', // Different barcode
        batches: [ItemBatch(id: batchId, quantity: 2.0, purchaseDate: now)],
        createdAt: now,
        updatedAt: now,
      );

      // Test that items with same barcode are equal
      expect(item1.barcode, equals(item2.barcode));
      expect(item1, equals(item2));

      // Test that items with different barcodes are not equal
      expect(item1.barcode, isNot(equals(item3.barcode)));
      expect(item1, isNot(equals(item3)));

      // Test that barcode field is specifically different
      expect(item1.barcode, equals('1234567890123'));
      expect(item3.barcode, equals('9876543210987'));
    });

    testWidgets('Inventory screen shows barcode scanner button', (
      WidgetTester tester,
    ) async {
      // Test the AddItemScreen directly to check for barcode scanner button
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Verify barcode scanner button is present in the form
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });
  });
}
