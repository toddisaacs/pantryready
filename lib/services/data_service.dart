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

  @override
  Stream<List<PantryItem>> getPantryItems() async* {
    yield _items;
  }

  @override
  Future<void> addPantryItem(PantryItem item) async {
    _items.add(item);
  }

  @override
  Future<void> updatePantryItem(PantryItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> deletePantryItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
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
              (item) => item.name.toLowerCase().contains(query.toLowerCase()),
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
  Stream<List<PantryItem>> searchPantryItems(String query) {
    return _firestoreService.searchPantryItems(query);
  }

  @override
  Stream<List<PantryItem>> getPantryItemsByCategory(String category) {
    return _firestoreService.getPantryItemsByCategory(category);
  }

  @override
  Stream<List<PantryItem>> getLowStockItems() {
    return _firestoreService.getLowStockItems();
  }

  @override
  Stream<List<PantryItem>> getExpiringItems() {
    return _firestoreService.getExpiringItems();
  }
}
