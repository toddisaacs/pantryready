import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/screens/inventory_screen.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  testWidgets('Alerts screen shows friendly empty state when no alerts', (
    WidgetTester tester,
  ) async {
    final testItems = [
      PantryItem(
        id: '1',
        name: 'Bottled Water',
        unit: 'bottles',
        systemCategory: SystemCategory.water,
        subcategory: 'Beverages',
        batches: [ItemBatch(quantity: 50.0, purchaseDate: DateTime.now())],
        minStockLevel: 5.0,
        maxStockLevel: 100.0,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: InventoryScreen(
          pantryItems: testItems,
          onAddItem: (item) {},
          onDeleteItem: (item) {},
          onEditItem: (item) {},
          onItemUpdated: (item) {},
          filterMode: InventoryFilterMode.alerts,
        ),
      ),
    );

    expect(find.text('Everything looks good!'), findsOneWidget);
  });

  testWidgets('Inventory screen displays items grouped by category', (
    WidgetTester tester,
  ) async {
    final testItems = [
      PantryItem(
        id: '1',
        name: 'Bottled Water',
        unit: 'bottles',
        systemCategory: SystemCategory.water,
        subcategory: 'Beverages',
        batches: [ItemBatch(quantity: 6.0, purchaseDate: DateTime.now())],
      ),
      PantryItem(
        id: '2',
        name: 'Canned Beans',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Canned Goods',
        batches: [ItemBatch(quantity: 2.0, purchaseDate: DateTime.now())],
      ),
      PantryItem(
        id: '3',
        name: 'Rice',
        unit: 'bags',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains',
        batches: [ItemBatch(quantity: 1.0, purchaseDate: DateTime.now())],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: InventoryScreen(
          pantryItems: testItems,
          onAddItem: (item) {},
          onDeleteItem: (item) {},
          onEditItem: (item) {},
          onItemUpdated: (item) {},
          filterMode: InventoryFilterMode.all,
        ),
      ),
    );

    // Check for items (category headers are now uppercase)
    expect(find.text('WATER'), findsWidgets);
    expect(find.text('Bottled Water'), findsOneWidget);
    expect(find.text('FOOD'), findsWidgets);
    expect(find.text('Canned Beans'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
  });

  testWidgets('Delete item functionality works correctly', (
    WidgetTester tester,
  ) async {
    final testItems = [
      PantryItem(
        id: '1',
        name: 'Bottled Water',
        unit: 'bottles',
        systemCategory: SystemCategory.water,
        subcategory: 'Beverages',
        batches: [ItemBatch(quantity: 6.0, purchaseDate: DateTime.now())],
      ),
    ];

    bool itemDeleted = false;
    PantryItem? deletedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: InventoryScreen(
          pantryItems: testItems,
          onAddItem: (item) {},
          onDeleteItem: (item) {
            itemDeleted = true;
            deletedItem = item;
          },
          onEditItem: (item) {},
          onItemUpdated: (item) {},
          filterMode: InventoryFilterMode.all,
        ),
      ),
    );

    // Tap on an item to open detail screen
    await tester.tap(find.text('Bottled Water'));
    await tester.pumpAndSettle();

    // Verify we're on the detail screen
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

    // Verify the delete callback was called
    expect(itemDeleted, true);
    expect(deletedItem?.name, 'Bottled Water');
  });

  testWidgets('Delete confirmation can be cancelled', (
    WidgetTester tester,
  ) async {
    final testItems = [
      PantryItem(
        id: '1',
        name: 'Canned Beans',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Canned Goods',
        batches: [ItemBatch(quantity: 2.0, purchaseDate: DateTime.now())],
      ),
    ];

    bool itemDeleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: InventoryScreen(
          pantryItems: testItems,
          onAddItem: (item) {},
          onDeleteItem: (item) {
            itemDeleted = true;
          },
          onEditItem: (item) {},
          onItemUpdated: (item) {},
          filterMode: InventoryFilterMode.all,
        ),
      ),
    );

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

    // Verify we're still on detail screen and item still exists
    expect(find.text('Canned Beans'), findsWidgets);

    // Verify the delete callback was NOT called
    expect(itemDeleted, false);
  });
}
