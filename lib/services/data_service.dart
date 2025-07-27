import 'dart:async';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/services/firestore_service.dart';

abstract class DataService {
  Stream<List<PantryItem>> getPantryItems();
  Future<void> addPantryItem(PantryItem item);
  Future<void> updatePantryItem(PantryItem item);
  Future<void> deletePantryItem(String itemId);
  Future<PantryItem?> getPantryItem(String itemId);
  Stream<List<PantryItem>> searchPantryItems(String query);
  Stream<List<PantryItem>> getPantryItemsByCategory(String category);
  Stream<List<PantryItem>> getLowStockItems();
  Stream<List<PantryItem>> getExpiringItems();
}

class LocalDataService implements DataService {
  final List<PantryItem> _items = [];
  late final StreamController<List<PantryItem>> _itemsController;

  LocalDataService() {
    _itemsController = StreamController<List<PantryItem>>.broadcast(
      onListen: () {
        _itemsController.add(List<PantryItem>.from(_items));
      },
    );
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
    _itemsController.add(List.from(_items));
  }

  void dispose() {
    _itemsController.close();
  }
}

class FirestoreDataService implements DataService {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Stream<List<PantryItem>> getPantryItems() {
    return _firestoreService.getPantryItems();
  }

  @override
  Future<void> addPantryItem(PantryItem item) async {
    await _firestoreService.addPantryItem(item);
  }

  @override
  Future<void> updatePantryItem(PantryItem item) async {
    await _firestoreService.updatePantryItem(item);
  }

  @override
  Future<void> deletePantryItem(String itemId) async {
    await _firestoreService.deletePantryItem(itemId);
  }

  @override
  Future<PantryItem?> getPantryItem(String itemId) async {
    return await _firestoreService.getPantryItem(itemId);
  }

  @override
  Stream<List<PantryItem>> searchPantryItems(String query) async* {
    await for (final items in _firestoreService.getPantryItems()) {
      final filtered =
          items
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query.toLowerCase()) ||
                    (item.subcategory?.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
      yield filtered;
    }
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

    await for (final items in _firestoreService.getPantryItems()) {
      final filtered =
          items
              .where(
                (item) =>
                    item.systemCategory == systemCategory ||
                    item.subcategory?.toLowerCase() == category.toLowerCase(),
              )
              .toList();
      yield filtered;
    }
  }

  @override
  Stream<List<PantryItem>> getLowStockItems() async* {
    await for (final items in _firestoreService.getPantryItems()) {
      final filtered = items.where((item) => item.isLowStock).toList();
      yield filtered;
    }
  }

  @override
  Stream<List<PantryItem>> getExpiringItems() async* {
    await for (final items in _firestoreService.getPantryItems()) {
      final filtered = items.where((item) => item.hasExpiringItems).toList();
      yield filtered;
    }
  }
}
