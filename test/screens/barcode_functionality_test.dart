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

      await tester.pumpAndSettle();

      // When initialBarcode is provided, the barcode chip is shown at top
      expect(find.text(testBarcode), findsOneWidget);
    });

    testWidgets('AddItemScreen can be created without initial barcode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('AddItemScreen includes barcode scanner in More Details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Expand More Details to find the scanner button
      await tester.tap(find.text('More Details'));
      await tester.pumpAndSettle();

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

      await tester.pumpAndSettle();

      // Fill in required fields
      final nameField = find.widgetWithText(TextFormField, 'Item Name');
      await tester.enterText(nameField, 'Test Item');
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '2');

      // Save the item
      await tester.ensureVisible(find.text('Save Item'));
      await tester.tap(find.text('Save Item'), warnIfMissed: false);
      await tester.pump();

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
      expect(originalItem.barcode, equals(originalBarcode));
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

      final deserializedItem = PantryItem.fromJson({'id': item.id, ...json});
      expect(deserializedItem.barcode, equals(testBarcode));
    });

    test('PantryItem equality includes barcode field', () {
      const testBarcode = '1234567890123';
      final now = DateTime(2024, 1, 1, 12, 0, 0);
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
        barcode: '9876543210987',
        batches: [ItemBatch(id: batchId, quantity: 2.0, purchaseDate: now)],
        createdAt: now,
        updatedAt: now,
      );

      expect(item1.barcode, equals(item2.barcode));
      expect(item1, equals(item2));
      expect(item1.barcode, isNot(equals(item3.barcode)));
      expect(item1, isNot(equals(item3)));
    });

    testWidgets('AddItemScreen barcode scanner in More Details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddItemScreen()));

      // Expand More Details
      await tester.tap(find.text('More Details'));
      await tester.pumpAndSettle();

      // Verify barcode scanner button is present
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });
  });
}
