import 'dart:async';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/services/data_service.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class MockDataService implements DataService {
  final List<PantryItem> _items = [];
  late final StreamController<List<PantryItem>> _itemsController;

  MockDataService() {
    debugPrint('MockDataService: Initializing with sample data');
    _itemsController = StreamController<List<PantryItem>>.broadcast(
      onListen: () {
        debugPrint(
          'MockDataService: New listener attached, emitting ${_items.length} items',
        );
        _itemsController.add(List<PantryItem>.from(_items));
      },
    );
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    final sampleItems = [
      // Cut Green Beans — two brands to demo summary grouping
      PantryItem(
        id: 'mock-1a',
        name: 'Cut Green Beans',
        brand: 'Del Monte',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Vegetables',
        batches: [
          ItemBatch(
            quantity: 8.0,
            purchaseDate: now.subtract(const Duration(days: 5)),
            expiryDate: now.add(const Duration(days: 730)),
            costPerUnit: 0.89,
          ),
        ],
        barcode: '1234567890123',
        dailyConsumptionRate: 0.3,
        minStockLevel: 6.0,
        maxStockLevel: 24.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
        ],
      ),
      PantryItem(
        id: 'mock-1b',
        name: 'Cut Green Beans',
        brand: "Libby's",
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Vegetables',
        batches: [
          ItemBatch(
            quantity: 6.0,
            purchaseDate: now.subtract(const Duration(days: 2)),
            expiryDate: now.add(const Duration(days: 548)),
            costPerUnit: 0.79,
          ),
        ],
        barcode: '1234567890124',
        dailyConsumptionRate: 0.3,
        minStockLevel: 6.0,
        maxStockLevel: 24.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
        ],
      ),
      // Black Beans — two brands
      PantryItem(
        id: 'mock-2a',
        name: 'Black Beans',
        brand: "Bush's",
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Legumes & Beans',
        batches: [
          ItemBatch(
            quantity: 12.0,
            purchaseDate: now.subtract(const Duration(days: 10)),
            expiryDate: now.add(const Duration(days: 1095)),
            costPerUnit: 1.25,
          ),
        ],
        barcode: '2345678901234',
        dailyConsumptionRate: 0.5,
        minStockLevel: 6.0,
        maxStockLevel: 24.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ],
      ),
      PantryItem(
        id: 'mock-2b',
        name: 'Black Beans',
        brand: 'Goya',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Legumes & Beans',
        batches: [
          ItemBatch(
            quantity: 4.0,
            purchaseDate: now.subtract(const Duration(days: 30)),
            expiryDate: now.add(const Duration(days: 25)),
            costPerUnit: 1.10,
          ),
        ],
        barcode: '2345678901235',
        dailyConsumptionRate: 0.5,
        minStockLevel: 6.0,
        maxStockLevel: 24.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ],
      ),
      // Rice — two brands
      PantryItem(
        id: 'mock-3a',
        name: 'White Rice',
        brand: 'Mahatma',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains & Pasta',
        batches: [
          ItemBatch(
            quantity: 10.0,
            purchaseDate: now.subtract(const Duration(days: 10)),
            expiryDate: now.add(const Duration(days: 730)),
            costPerUnit: 0.80,
          ),
        ],
        barcode: '3456789012345',
        dailyConsumptionRate: 0.25,
        minStockLevel: 3.5,
        maxStockLevel: 20.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ],
      ),
      PantryItem(
        id: 'mock-3b',
        name: 'White Rice',
        brand: "Uncle Ben's",
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains & Pasta',
        batches: [
          ItemBatch(
            quantity: 5.0,
            purchaseDate: now.subtract(const Duration(days: 3)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 1.20,
          ),
        ],
        barcode: '3456789012346',
        dailyConsumptionRate: 0.25,
        minStockLevel: 3.5,
        maxStockLevel: 20.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ],
      ),
      // Bottled Water
      PantryItem(
        id: 'mock-4',
        name: 'Bottled Water',
        brand: 'Deer Park',
        unit: 'liters',
        systemCategory: SystemCategory.water,
        subcategory: 'Drinking Water',
        batches: [
          ItemBatch(
            quantity: 24.0,
            purchaseDate: now.subtract(const Duration(days: 3)),
            expiryDate: now.add(const Duration(days: 1095)),
            costPerUnit: 0.50,
          ),
        ],
        barcode: '4567890123456',
        dailyConsumptionRate: 3.0,
        minStockLevel: 30.0,
        maxStockLevel: 100.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ],
      ),
      // Pasta — two brands
      PantryItem(
        id: 'mock-5a',
        name: 'Spaghetti',
        brand: 'Barilla',
        unit: 'boxes',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains & Pasta',
        batches: [
          ItemBatch(
            quantity: 6.0,
            purchaseDate: now.subtract(const Duration(days: 7)),
            expiryDate: now.add(const Duration(days: 730)),
            costPerUnit: 1.50,
          ),
        ],
        barcode: '5678901234567',
        dailyConsumptionRate: 0.3,
        minStockLevel: 4.0,
        maxStockLevel: 12.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      PantryItem(
        id: 'mock-5b',
        name: 'Spaghetti',
        brand: 'De Cecco',
        unit: 'boxes',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains & Pasta',
        batches: [
          ItemBatch(
            quantity: 2.0,
            purchaseDate: now.subtract(const Duration(days: 20)),
            expiryDate: now.add(const Duration(days: 180)),
            costPerUnit: 2.50,
          ),
        ],
        barcode: '5678901234568',
        dailyConsumptionRate: 0.3,
        minStockLevel: 4.0,
        maxStockLevel: 12.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      // Peanut Butter — two brands
      PantryItem(
        id: 'mock-6a',
        name: 'Peanut Butter',
        brand: 'Jif',
        unit: 'jars',
        systemCategory: SystemCategory.food,
        subcategory: 'Condiments',
        batches: [
          ItemBatch(
            quantity: 2.0,
            purchaseDate: now.subtract(const Duration(days: 15)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 3.49,
          ),
        ],
        barcode: '6789012345678',
        dailyConsumptionRate: 0.1,
        minStockLevel: 2.0,
        maxStockLevel: 6.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      PantryItem(
        id: 'mock-6b',
        name: 'Peanut Butter',
        brand: 'Skippy',
        unit: 'jars',
        systemCategory: SystemCategory.food,
        subcategory: 'Condiments',
        batches: [
          ItemBatch(
            quantity: 1.0,
            purchaseDate: now.subtract(const Duration(days: 5)),
            expiryDate: now.add(const Duration(days: 300)),
            costPerUnit: 3.29,
          ),
        ],
        barcode: '6789012345679',
        dailyConsumptionRate: 0.1,
        minStockLevel: 2.0,
        maxStockLevel: 6.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      // Canned Tomatoes — two brands
      PantryItem(
        id: 'mock-7a',
        name: 'Crushed Tomatoes',
        brand: "Hunt's",
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Vegetables',
        batches: [
          ItemBatch(
            quantity: 6.0,
            purchaseDate: now.subtract(const Duration(days: 8)),
            expiryDate: now.add(const Duration(days: 730)),
            costPerUnit: 1.00,
          ),
        ],
        barcode: '7890123456789',
        dailyConsumptionRate: 0.3,
        minStockLevel: 4.0,
        maxStockLevel: 12.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      PantryItem(
        id: 'mock-7b',
        name: 'Crushed Tomatoes',
        brand: 'Muir Glen',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Vegetables',
        batches: [
          ItemBatch(
            quantity: 3.0,
            purchaseDate: now.subtract(const Duration(days: 1)),
            expiryDate: now.add(const Duration(days: 900)),
            costPerUnit: 1.79,
          ),
        ],
        barcode: '7890123456780',
        dailyConsumptionRate: 0.3,
        minStockLevel: 4.0,
        maxStockLevel: 12.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      // Olive Oil — single brand
      PantryItem(
        id: 'mock-8',
        name: 'Olive Oil',
        brand: 'California Olive Ranch',
        unit: 'bottles',
        systemCategory: SystemCategory.food,
        subcategory: 'Condiments',
        batches: [
          ItemBatch(
            quantity: 1.0,
            purchaseDate: now.subtract(const Duration(days: 12)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 9.99,
          ),
        ],
        barcode: '8901234567890',
        dailyConsumptionRate: 0.05,
        minStockLevel: 1.0,
        maxStockLevel: 3.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      // First Aid Kit
      PantryItem(
        id: 'mock-9',
        name: 'First Aid Kit',
        brand: 'Johnson & Johnson',
        unit: 'kits',
        systemCategory: SystemCategory.medical,
        subcategory: 'First Aid',
        batches: [
          ItemBatch(
            quantity: 2.0,
            purchaseDate: now.subtract(const Duration(days: 60)),
            expiryDate: now.add(const Duration(days: 1825)),
            costPerUnit: 25.00,
          ),
        ],
        dailyConsumptionRate: 0.01,
        minStockLevel: 1.0,
        maxStockLevel: 3.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.earthquake,
        ],
      ),
    ];

    debugPrint(
      'MockDataService: Seeding data with ${sampleItems.length} items',
    );
    _items.addAll(sampleItems);
    _notifyListeners();
  }

  @override
  Stream<List<PantryItem>> getPantryItems() {
    return _itemsController.stream;
  }

  @override
  Future<void> addPantryItem(PantryItem item) async {
    _items.add(item);
    _notifyListeners();
  }

  @override
  Future<void> updatePantryItem(PantryItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _notifyListeners();
    }
  }

  @override
  Future<void> deletePantryItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    _notifyListeners();
  }

  @override
  Future<PantryItem?> getPantryItem(String itemId) async {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<PantryItem>> searchPantryItems(String query) async* {
    final filtered =
        _items
            .where(
              (item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()) ||
                  (item.subcategory?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false) ||
                  (item.notes?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
    yield filtered;
  }

  @override
  Stream<List<PantryItem>> getPantryItemsByCategory(String category) async* {
    // Convert legacy category names to system categories
    SystemCategory? systemCategory;
    switch (category.toLowerCase()) {
      case 'canned goods':
        systemCategory = SystemCategory.food;
        break;
      case 'grains':
        systemCategory = SystemCategory.food;
        break;
      case 'beverages':
        systemCategory = SystemCategory.water;
        break;
      case 'condiments':
        systemCategory = SystemCategory.food;
        break;
      case 'snacks':
        systemCategory = SystemCategory.food;
        break;
      case 'frozen foods':
        systemCategory = SystemCategory.food;
        break;
      case 'dairy':
        systemCategory = SystemCategory.food;
        break;
      case 'produce':
        systemCategory = SystemCategory.food;
        break;
      case 'meat':
        systemCategory = SystemCategory.food;
        break;
      case 'water':
        systemCategory = SystemCategory.water;
        break;
      case 'medical':
        systemCategory = SystemCategory.medical;
        break;
      case 'hygiene':
        systemCategory = SystemCategory.hygiene;
        break;
      case 'tools':
        systemCategory = SystemCategory.tools;
        break;
      case 'lighting':
        systemCategory = SystemCategory.lighting;
        break;
      case 'shelter':
        systemCategory = SystemCategory.shelter;
        break;
      case 'communication':
        systemCategory = SystemCategory.communication;
        break;
      case 'security':
        systemCategory = SystemCategory.security;
        break;
      default:
        systemCategory = SystemCategory.other;
    }

    final filtered =
        _items
            .where(
              (item) =>
                  item.systemCategory == systemCategory ||
                  item.subcategory?.toLowerCase() == category.toLowerCase(),
            )
            .toList();
    yield filtered;
  }

  @override
  Stream<List<PantryItem>> getLowStockItems() async* {
    final filtered = _items.where((item) => item.isLowStock).toList();
    yield filtered;
  }

  @override
  Stream<List<PantryItem>> getExpiringItems() async* {
    final filtered = _items.where((item) => item.hasExpiringItems).toList();
    yield filtered;
  }

  void _notifyListeners() {
    debugPrint(
      'MockDataService: Notifying listeners with ${_items.length} items',
    );
    _itemsController.add(List.from(_items));
  }

  void dispose() {
    _itemsController.close();
  }

  // Helper methods for testing and debugging
  List<PantryItem> getItemsByCategory(SystemCategory category) {
    return _items.where((item) => item.systemCategory == category).toList();
  }

  List<PantryItem> getItemsBySubcategory(String subcategory) {
    return _items.where((item) => item.subcategory == subcategory).toList();
  }

  List<PantryItem> getEssentialItems() {
    return _items.where((item) => item.isEssential).toList();
  }

  List<PantryItem> getExcessiveStockItems() {
    return _items.where((item) => item.isExcessiveStock).toList();
  }

  List<PantryItem> getItemsForScenario(SurvivalScenario scenario) {
    return _items
        .where((item) => item.applicableScenarios.contains(scenario))
        .toList();
  }

  double getTotalDaysOfSupply(SystemCategory category, int familySize) {
    final categoryItems = getItemsByCategory(category);
    double totalDays = 0.0;
    int itemCount = 0;

    for (final item in categoryItems) {
      if (item.dailyConsumptionRate != null && item.dailyConsumptionRate! > 0) {
        final days =
            item.availableQuantity / (item.dailyConsumptionRate! * familySize);
        totalDays += days;
        itemCount++;
      }
    }

    return itemCount > 0 ? totalDays / itemCount : 0.0;
  }
}
