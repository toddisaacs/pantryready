import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  group('ItemBatch', () {
    test('creates batch with generated ID', () {
      final batch = ItemBatch(
        quantity: 10.0,
        purchaseDate: DateTime(2025, 1, 1),
      );

      expect(batch.id, isNotEmpty);
      expect(batch.quantity, 10.0);
      expect(batch.purchaseDate, DateTime(2025, 1, 1));
      expect(batch.expiryDate, isNull);
      expect(batch.costPerUnit, isNull);
      expect(batch.notes, isNull);
    });

    test('creates batch with custom ID', () {
      final batch = ItemBatch(
        id: 'custom-id',
        quantity: 5.0,
        purchaseDate: DateTime(2025, 1, 1),
        expiryDate: DateTime(2026, 1, 1),
        costPerUnit: 2.50,
        notes: 'Test notes',
      );

      expect(batch.id, 'custom-id');
      expect(batch.quantity, 5.0);
      expect(batch.expiryDate, DateTime(2026, 1, 1));
      expect(batch.costPerUnit, 2.50);
      expect(batch.notes, 'Test notes');
    });

    test('copyWith creates new batch with updated fields', () {
      final batch = ItemBatch(
        quantity: 10.0,
        purchaseDate: DateTime(2025, 1, 1),
      );

      final updated = batch.copyWith(quantity: 5.0, notes: 'Updated');

      expect(updated.id, batch.id);
      expect(updated.quantity, 5.0);
      expect(updated.notes, 'Updated');
      expect(updated.purchaseDate, batch.purchaseDate);
    });

    test('toJson and fromJson are symmetric', () {
      final batch = ItemBatch(
        id: 'test-id',
        quantity: 10.0,
        purchaseDate: DateTime(2025, 1, 1),
        expiryDate: DateTime(2026, 1, 1),
        costPerUnit: 2.50,
        notes: 'Test',
      );

      final json = batch.toJson();
      final restored = ItemBatch.fromJson(json);

      expect(restored.id, batch.id);
      expect(restored.quantity, batch.quantity);
      expect(restored.purchaseDate, batch.purchaseDate);
      expect(restored.expiryDate, batch.expiryDate);
      expect(restored.costPerUnit, batch.costPerUnit);
      expect(restored.notes, batch.notes);
    });

    test('equality works correctly', () {
      final batch1 = ItemBatch(
        id: 'same-id',
        quantity: 10.0,
        purchaseDate: DateTime(2025, 1, 1),
      );
      final batch2 = ItemBatch(
        id: 'same-id',
        quantity: 10.0,
        purchaseDate: DateTime(2025, 1, 1),
      );
      final batch3 = ItemBatch(
        id: 'different-id',
        quantity: 10.0,
        purchaseDate: DateTime(2025, 1, 1),
      );

      expect(batch1, equals(batch2));
      expect(batch1, isNot(equals(batch3)));
    });
  });

  group('PantryItem - Basic Properties', () {
    test('creates item with default values', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
      );

      expect(item.id, isNotEmpty);
      expect(item.name, 'Rice');
      expect(item.unit, 'lbs');
      expect(item.systemCategory, SystemCategory.food);
      expect(item.batches, isEmpty);
      expect(item.isEssential, false);
      expect(item.applicableScenarios, isEmpty);
      expect(item.createdAt, isNotNull);
      expect(item.updatedAt, isNotNull);
    });

    test('creates item with custom values', () {
      final item = PantryItem(
        id: 'custom-id',
        name: 'Water',
        unit: 'gallons',
        systemCategory: SystemCategory.water,
        subcategory: 'Drinking Water',
        barcode: '123456',
        notes: 'Important',
        storageLocation: 'Basement',
        isEssential: true,
        dailyConsumptionRate: 1.0,
        minStockLevel: 10.0,
        maxStockLevel: 100.0,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.hurricane,
        ],
      );

      expect(item.id, 'custom-id');
      expect(item.name, 'Water');
      expect(item.unit, 'gallons');
      expect(item.systemCategory, SystemCategory.water);
      expect(item.subcategory, 'Drinking Water');
      expect(item.barcode, '123456');
      expect(item.notes, 'Important');
      expect(item.storageLocation, 'Basement');
      expect(item.isEssential, true);
      expect(item.dailyConsumptionRate, 1.0);
      expect(item.minStockLevel, 10.0);
      expect(item.maxStockLevel, 100.0);
      expect(item.applicableScenarios.length, 2);
    });

    test('toJson and fromJson are symmetric', () {
      final now = DateTime(2025, 1, 1);
      final item = PantryItem(
        id: 'test-id',
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains',
        batches: [
          ItemBatch(
            id: 'batch-1',
            quantity: 10.0,
            purchaseDate: now,
          ),
        ],
        barcode: '123',
        notes: 'Test',
        isEssential: true,
        dailyConsumptionRate: 0.5,
        minStockLevel: 5.0,
        maxStockLevel: 50.0,
        applicableScenarios: [SurvivalScenario.powerOutage],
        createdAt: now,
        updatedAt: now,
      );

      final json = item.toJson();
      final restored = PantryItem.fromJson(json);

      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.unit, item.unit);
      expect(restored.systemCategory, item.systemCategory);
      expect(restored.subcategory, item.subcategory);
      expect(restored.batches.length, item.batches.length);
      expect(restored.barcode, item.barcode);
      expect(restored.isEssential, item.isEssential);
      expect(restored.dailyConsumptionRate, item.dailyConsumptionRate);
    });
  });

  group('PantryItem - Quantity Calculations', () {
    test('totalQuantity sums all batches', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(quantity: 10.0, purchaseDate: DateTime.now()),
          ItemBatch(quantity: 5.0, purchaseDate: DateTime.now()),
          ItemBatch(quantity: 3.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.totalQuantity, 18.0);
    });

    test('totalQuantity returns 0 for empty batches', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
      );

      expect(item.totalQuantity, 0.0);
    });

    test('availableQuantity excludes expired batches', () {
      final now = DateTime.now();
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            quantity: 10.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 30)),
          ),
          ItemBatch(
            quantity: 5.0,
            purchaseDate: now,
            expiryDate: now.subtract(const Duration(days: 1)),
          ),
          ItemBatch(
            quantity: 3.0,
            purchaseDate: now,
          ), // No expiry
        ],
      );

      expect(item.availableQuantity, 13.0); // 10 + 3, excluding expired 5
    });

    test('daysOfSupply calculates correctly', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        dailyConsumptionRate: 2.0,
        batches: [
          ItemBatch(quantity: 20.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.daysOfSupply, 10.0); // 20 / 2 = 10 days
    });

    test('daysOfSupply returns null when no consumption rate', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(quantity: 20.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.daysOfSupply, isNull);
    });
  });

  group('PantryItem - Stock Status', () {
    test('isLowStock returns true when below minimum', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        minStockLevel: 10.0,
        batches: [
          ItemBatch(quantity: 5.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.isLowStock, true);
    });

    test('isLowStock returns false when above minimum', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        minStockLevel: 10.0,
        batches: [
          ItemBatch(quantity: 15.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.isLowStock, false);
    });

    test('isLowStock returns false when no minimum set', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(quantity: 5.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.isLowStock, false);
    });

    test('isExcessiveStock returns true when above maximum', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        maxStockLevel: 50.0,
        batches: [
          ItemBatch(quantity: 60.0, purchaseDate: DateTime.now()),
        ],
      );

      expect(item.isExcessiveStock, true);
    });

    test('hasExpiringItems detects items expiring within 30 days', () {
      final now = DateTime.now();
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            quantity: 10.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 15)),
          ),
        ],
      );

      expect(item.hasExpiringItems, true);
    });

    test('hasExpiringItems returns false for far future expiry', () {
      final now = DateTime.now();
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            quantity: 10.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 365)),
          ),
        ],
      );

      expect(item.hasExpiringItems, false);
    });
  });

  group('PantryItem - Batch Operations', () {
    test('addBatch adds new batch to item', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(quantity: 10.0, purchaseDate: DateTime.now()),
        ],
      );

      final newBatch = ItemBatch(quantity: 5.0, purchaseDate: DateTime.now());
      final updated = item.addBatch(newBatch);

      expect(updated.batches.length, 2);
      expect(updated.totalQuantity, 15.0);
    });

    test('consumeQuantity removes from oldest batch first', () {
      final old = DateTime(2025, 1, 1);
      final recent = DateTime(2025, 6, 1);

      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            id: 'old',
            quantity: 10.0,
            purchaseDate: old,
          ),
          ItemBatch(
            id: 'recent',
            quantity: 5.0,
            purchaseDate: recent,
          ),
        ],
      );

      final updated = item.consumeQuantity(3.0);

      expect(updated.batches.length, 2);
      expect(
        updated.batches.firstWhere((b) => b.id == 'old').quantity,
        7.0,
      ); // 10 - 3
      expect(
        updated.batches.firstWhere((b) => b.id == 'recent').quantity,
        5.0,
      ); // unchanged
    });

    test('consumeQuantity removes entire batch when fully consumed', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            id: 'batch1',
            quantity: 5.0,
            purchaseDate: DateTime(2025, 1, 1),
          ),
          ItemBatch(
            id: 'batch2',
            quantity: 10.0,
            purchaseDate: DateTime(2025, 6, 1),
          ),
        ],
      );

      final updated = item.consumeQuantity(5.0);

      expect(updated.batches.length, 1);
      expect(updated.batches.first.id, 'batch2');
      expect(updated.totalQuantity, 10.0);
    });

    test('consumeQuantity spans multiple batches', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(quantity: 5.0, purchaseDate: DateTime(2025, 1, 1)),
          ItemBatch(quantity: 5.0, purchaseDate: DateTime(2025, 2, 1)),
          ItemBatch(quantity: 5.0, purchaseDate: DateTime(2025, 3, 1)),
        ],
      );

      final updated = item.consumeQuantity(8.0);

      expect(updated.batches.length, 2); // 1st batch gone, 2nd partial, 3rd full
      expect(updated.totalQuantity, 7.0); // 15 - 8 = 7
    });

    test('sortedBatches sorts by expiry date', () {
      final now = DateTime.now();
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            id: 'far',
            quantity: 5.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 100)),
          ),
          ItemBatch(
            id: 'near',
            quantity: 5.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 10)),
          ),
          ItemBatch(
            id: 'none',
            quantity: 5.0,
            purchaseDate: now,
          ),
        ],
      );

      final sorted = item.sortedBatches;

      expect(sorted[0].id, 'none'); // No expiry first
      expect(sorted[1].id, 'near'); // Soonest expiry
      expect(sorted[2].id, 'far'); // Latest expiry
    });

    test('getExpiringBatches returns batches expiring within days', () {
      final now = DateTime.now();
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        batches: [
          ItemBatch(
            quantity: 5.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 5)),
          ),
          ItemBatch(
            quantity: 5.0,
            purchaseDate: now,
            expiryDate: now.add(const Duration(days: 50)),
          ),
        ],
      );

      final expiring = item.getExpiringBatches(10);

      expect(expiring.length, 1);
      expect(expiring.first.quantity, 5.0);
    });
  });

  group('PantryItem - Scenario Calculations', () {
    test('getDaysOfSupplyForScenario calculates for family', () {
      final item = PantryItem(
        name: 'Water',
        unit: 'gallons',
        systemCategory: SystemCategory.water,
        dailyConsumptionRate: 1.0, // per person
        batches: [
          ItemBatch(quantity: 30.0, purchaseDate: DateTime.now()),
        ],
        applicableScenarios: [SurvivalScenario.powerOutage],
      );

      final days = item.getDaysOfSupplyForScenario(
        SurvivalScenario.powerOutage,
        3,
      ); // family of 3

      expect(days, 10.0); // 30 gallons / (1 * 3) = 10 days
    });

    test('getDaysOfSupplyForScenario returns null for non-applicable scenario',
        () {
      final item = PantryItem(
        name: 'Water',
        unit: 'gallons',
        systemCategory: SystemCategory.water,
        dailyConsumptionRate: 1.0,
        batches: [
          ItemBatch(quantity: 30.0, purchaseDate: DateTime.now()),
        ],
        applicableScenarios: [SurvivalScenario.powerOutage],
      );

      final days = item.getDaysOfSupplyForScenario(
        SurvivalScenario.earthquake,
        3,
      );

      expect(days, isNull);
    });
  });

  group('PantryItem - CopyWith', () {
    test('copyWith updates specific fields', () {
      final item = PantryItem(
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
      );

      final updated = item.copyWith(
        name: 'Brown Rice',
        isEssential: true,
      );

      expect(updated.name, 'Brown Rice');
      expect(updated.isEssential, true);
      expect(updated.unit, 'lbs'); // unchanged
      expect(updated.systemCategory, SystemCategory.food); // unchanged
    });
  });

  group('SystemCategory', () {
    test('has correct display names', () {
      expect(SystemCategory.water.displayName, 'Water');
      expect(SystemCategory.food.displayName, 'Food');
      expect(SystemCategory.medical.displayName, 'Medical');
    });

    test('has emojis', () {
      expect(SystemCategory.water.emoji, '💧');
      expect(SystemCategory.food.emoji, '🍽️');
      expect(SystemCategory.medical.emoji, '🏥');
    });
  });

  group('SurvivalScenario', () {
    test('has correct display names', () {
      expect(SurvivalScenario.powerOutage.displayName, 'Power Outage');
      expect(SurvivalScenario.hurricane.displayName, 'Hurricane');
    });

    test('has emojis', () {
      expect(SurvivalScenario.powerOutage.emoji, '⚡');
      expect(SurvivalScenario.hurricane.emoji, '🌀');
    });
  });
}
