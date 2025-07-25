import 'dart:async';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/services/data_service.dart';

class MockDataService implements DataService {
  final List<PantryItem> _items = [];
  final StreamController<List<PantryItem>> _itemsController =
      StreamController<List<PantryItem>>.broadcast();

  MockDataService() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    final sampleItems = [
      PantryItem(
        id: 'mock-1',
        name: 'Canned Beans',
        quantity: 12.0,
        unit: 'cans',
        category: 'Canned Goods',
        expiryDate: now.add(const Duration(days: 365)),
        notes: 'Black beans for tacos',
        barcode: '1234567890123',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      PantryItem(
        id: 'mock-2',
        name: 'Rice',
        quantity: 5.0,
        unit: 'lbs',
        category: 'Grains',
        expiryDate: now.add(const Duration(days: 730)),
        notes: 'Long grain white rice',
        barcode: '2345678901234',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      PantryItem(
        id: 'mock-3',
        name: 'Bottled Water',
        quantity: 24.0,
        unit: 'bottles',
        category: 'Beverages',
        expiryDate: now.add(const Duration(days: 1095)),
        notes: 'Spring water',
        barcode: '3456789012345',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      PantryItem(
        id: 'mock-4',
        name: 'Pasta',
        quantity: 8.0,
        unit: 'boxes',
        category: 'Grains',
        expiryDate: now.add(const Duration(days: 365)),
        notes: 'Spaghetti',
        barcode: '4567890123456',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      PantryItem(
        id: 'mock-5',
        name: 'Peanut Butter',
        quantity: 3.0,
        unit: 'jars',
        category: 'Condiments',
        expiryDate: now.add(const Duration(days: 180)),
        notes: 'Natural peanut butter',
        barcode: '5678901234567',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      PantryItem(
        id: 'mock-6',
        name: 'Pinto Beans',
        quantity: 2.0,
        unit: 'lbs',
        category: 'Grains',
        expiryDate: now.add(const Duration(days: 365)),
        notes: 'Dried pinto beans',
        barcode: '6789012345678',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      PantryItem(
        id: 'mock-7',
        name: 'Canned Tomatoes',
        quantity: 6.0,
        unit: 'cans',
        category: 'Canned Goods',
        expiryDate: now.add(const Duration(days: 730)),
        notes: 'Crushed tomatoes for cooking',
        barcode: '7890123456789',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      PantryItem(
        id: 'mock-8',
        name: 'Olive Oil',
        quantity: 1.0,
        unit: 'bottles',
        category: 'Condiments',
        expiryDate: now.add(const Duration(days: 365)),
        notes: 'Extra virgin olive oil',
        barcode: '8901234567890',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      PantryItem(
        id: 'mock-9',
        name: 'Frozen Vegetables',
        quantity: 4.0,
        unit: 'bags',
        category: 'Frozen Foods',
        expiryDate: now.add(const Duration(days: 180)),
        notes: 'Mixed vegetables',
        barcode: '9012345678901',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      PantryItem(
        id: 'mock-10',
        name: 'Cereal',
        quantity: 2.0,
        unit: 'boxes',
        category: 'Grains',
        expiryDate: now.add(const Duration(days: 90)),
        notes: 'Whole grain cereal',
        barcode: '0123456789012',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
    ];

    _items.addAll(sampleItems);
    // Don't notify listeners here - wait until stream is accessed
  }

  void _notifyListeners() {
    _itemsController.add(_items);
  }

  @override
  Stream<List<PantryItem>> getPantryItems() {
    // Emit initial data after a short delay to ensure listener is set up
    Future.delayed(const Duration(milliseconds: 10), () {
      _itemsController.add(_items);
    });
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
                  item.category.toLowerCase().contains(query.toLowerCase()) ||
                  (item.notes?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
    yield filtered;
  }

  @override
  Stream<List<PantryItem>> getPantryItemsByCategory(String category) async* {
    final filtered = _items.where((item) => item.category == category).toList();
    yield filtered;
  }

  @override
  Stream<List<PantryItem>> getLowStockItems() async* {
    final filtered = _items.where((item) => item.quantity <= 1.0).toList();
    yield filtered;
  }

  @override
  Stream<List<PantryItem>> getExpiringItems() async* {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    final filtered =
        _items
            .where(
              (item) =>
                  item.expiryDate != null &&
                  item.expiryDate!.isAfter(now) &&
                  item.expiryDate!.isBefore(weekFromNow),
            )
            .toList();
    yield filtered;
  }

  // Additional methods for mock data management
  void resetToSeedData() {
    _items.clear();
    _seedData();
  }

  void addMockItem(PantryItem item) {
    _items.add(item);
    _notifyListeners();
  }

  void clearAllItems() {
    _items.clear();
    _notifyListeners();
  }

  void dispose() {
    _itemsController.close();
  }
}
