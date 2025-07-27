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
      PantryItem(
        id: 'mock-1',
        name: 'Canned Beans',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Canned Goods',
        batches: [
          ItemBatch(
            quantity: 12.0,
            purchaseDate: now.subtract(const Duration(days: 5)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 1.25,
            notes: 'Black beans for tacos',
          ),
        ],
        notes: 'Black beans for tacos',
        barcode: '1234567890123',
        dailyConsumptionRate: 0.5,
        minStockLevel: 6.0,
        maxStockLevel: 24.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
        ],
      ),
      PantryItem(
        id: 'mock-2',
        name: 'Rice',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains',
        batches: [
          ItemBatch(
            quantity: 5.0,
            purchaseDate: now.subtract(const Duration(days: 10)),
            expiryDate: now.add(const Duration(days: 730)),
            costPerUnit: 0.80,
            notes: 'Long grain white rice',
          ),
        ],
        notes: 'Long grain white rice',
        barcode: '2345678901234',
        dailyConsumptionRate: 0.25,
        minStockLevel: 3.5,
        maxStockLevel: 15.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ],
      ),
      PantryItem(
        id: 'mock-3',
        name: 'Bottled Water',
        unit: 'liters',
        systemCategory: SystemCategory.water,
        subcategory: 'Drinking Water',
        batches: [
          ItemBatch(
            quantity: 24.0,
            purchaseDate: now.subtract(const Duration(days: 3)),
            expiryDate: now.add(const Duration(days: 1095)),
            costPerUnit: 0.50,
            notes: 'Spring water',
          ),
        ],
        notes: 'Spring water',
        barcode: '3456789012345',
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
      PantryItem(
        id: 'mock-4',
        name: 'Pasta',
        unit: 'boxes',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains',
        batches: [
          ItemBatch(
            quantity: 8.0,
            purchaseDate: now.subtract(const Duration(days: 7)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 1.50,
            notes: 'Spaghetti',
          ),
        ],
        notes: 'Spaghetti',
        barcode: '4567890123456',
        dailyConsumptionRate: 0.3,
        minStockLevel: 4.2,
        maxStockLevel: 12.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      PantryItem(
        id: 'mock-5',
        name: 'Peanut Butter',
        unit: 'jars',
        systemCategory: SystemCategory.food,
        subcategory: 'Condiments',
        batches: [
          ItemBatch(
            quantity: 3.0,
            purchaseDate: now.subtract(const Duration(days: 15)),
            expiryDate: now.add(const Duration(days: 180)),
            costPerUnit: 2.50,
            notes: 'Natural peanut butter',
          ),
        ],
        notes: 'Natural peanut butter',
        barcode: '5678901234567',
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
        id: 'mock-6',
        name: 'Pinto Beans',
        unit: 'lbs',
        systemCategory: SystemCategory.food,
        subcategory: 'Grains',
        batches: [
          ItemBatch(
            quantity: 2.0,
            purchaseDate: now.subtract(const Duration(days: 20)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 1.20,
            notes: 'Dried pinto beans',
          ),
        ],
        notes: 'Dried pinto beans',
        barcode: '6789012345678',
        dailyConsumptionRate: 0.2,
        minStockLevel: 2.8,
        maxStockLevel: 8.0,
        isEssential: true,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.isolation,
        ],
      ),
      PantryItem(
        id: 'mock-7',
        name: 'Canned Tomatoes',
        unit: 'cans',
        systemCategory: SystemCategory.food,
        subcategory: 'Canned Goods',
        batches: [
          ItemBatch(
            quantity: 6.0,
            purchaseDate: now.subtract(const Duration(days: 8)),
            expiryDate: now.add(const Duration(days: 730)),
            costPerUnit: 1.00,
            notes: 'Crushed tomatoes for cooking',
          ),
        ],
        notes: 'Crushed tomatoes for cooking',
        barcode: '7890123456789',
        dailyConsumptionRate: 0.3,
        minStockLevel: 4.2,
        maxStockLevel: 12.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
        ],
      ),
      PantryItem(
        id: 'mock-8',
        name: 'Olive Oil',
        unit: 'bottles',
        systemCategory: SystemCategory.food,
        subcategory: 'Condiments',
        batches: [
          ItemBatch(
            quantity: 1.0,
            purchaseDate: now.subtract(const Duration(days: 12)),
            expiryDate: now.add(const Duration(days: 365)),
            costPerUnit: 8.00,
            notes: 'Extra virgin olive oil',
          ),
        ],
        notes: 'Extra virgin olive oil',
        barcode: '8901234567890',
        dailyConsumptionRate: 0.05,
        minStockLevel: 0.7,
        maxStockLevel: 2.0,
        isEssential: false,
        applicableScenarios: [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
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
