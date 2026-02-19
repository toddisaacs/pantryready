// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/screens/home_screen.dart';
import 'package:pantryready/screens/inventory_screen.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  testWidgets('Home screen displays welcome message', (
    WidgetTester tester,
  ) async {
    // Test the HomeScreen directly instead of the full app to avoid Firebase issues
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          pantryItems: const [],
          onAddItem: (item) {},
          onUpdateItem: (item) {},
          onEditItem: (item) {},
        ),
      ),
    );

    // Verify the welcome message is shown on the Home screen.
    expect(find.text('Welcome to PantryReady!'), findsOneWidget);
  });

  testWidgets('Inventory screen displays items grouped by category', (
    WidgetTester tester,
  ) async {
    // Test the InventoryScreen directly with sample data
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
        ),
      ),
    );

    // Check for the categories and items
    expect(find.text('Water'), findsWidgets);
    expect(find.text('Bottled Water'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
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
