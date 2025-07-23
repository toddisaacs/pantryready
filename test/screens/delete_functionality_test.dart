import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/screens/inventory_item_detail_screen.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  group('Delete Functionality Tests', () {
    late PantryItem testItem;

    setUp(() {
      testItem = PantryItem(
        id: 'test-1',
        name: 'Test Item',
        quantity: 5,
        unit: 'pieces',
        category: 'Test Category',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('Delete button shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      bool deleteCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InventoryItemDetailScreen(
            item: testItem,
            onDelete: (item) {
              deleteCallbackCalled = true;
            },
          ),
        ),
      );

      // Verify delete button is present
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete "Test Item"?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Verify callback hasn't been called yet
      expect(deleteCallbackCalled, false);
    });

    testWidgets('Confirming delete calls onDelete callback', (
      WidgetTester tester,
    ) async {
      PantryItem? deletedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: InventoryItemDetailScreen(
            item: testItem,
            onDelete: (item) {
              deletedItem = item;
            },
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify callback was called with correct item
      expect(deletedItem, equals(testItem));
    });

    testWidgets('Cancelling delete does not call onDelete callback', (
      WidgetTester tester,
    ) async {
      bool deleteCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InventoryItemDetailScreen(
            item: testItem,
            onDelete: (item) {
              deleteCallbackCalled = true;
            },
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Cancel delete
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify callback was not called
      expect(deleteCallbackCalled, false);

      // Verify we're still on the detail screen (item name appears in title and body)
      expect(find.text('Test Item'), findsWidgets);
    });

    testWidgets('Delete button not shown when onDelete callback is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InventoryItemDetailScreen(
            item: testItem,
            // No onDelete callback provided
          ),
        ),
      );

      // Verify delete button is not present
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}
