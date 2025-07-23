import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantryready/models/pantry_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'pantry_items';

  // Get all pantry items
  Stream<List<PantryItem>> getPantryItems() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PantryItem.fromJson({'id': doc.id, ...data});
          }).toList();
        });
  }

  // Add a new pantry item
  Future<void> addPantryItem(PantryItem item) async {
    try {
      await _firestore.collection(_collectionName).add(item.toJson());
    } catch (e) {
      throw Exception('Failed to add pantry item: $e');
    }
  }

  // Update an existing pantry item
  Future<void> updatePantryItem(PantryItem item) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(item.id)
          .update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update pantry item: $e');
    }
  }

  // Delete a pantry item
  Future<void> deletePantryItem(String itemId) async {
    try {
      await _firestore.collection(_collectionName).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete pantry item: $e');
    }
  }

  // Get a single pantry item by ID
  Future<PantryItem?> getPantryItem(String itemId) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(itemId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return PantryItem.fromJson({'id': doc.id, ...data});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pantry item: $e');
    }
  }

  // Search pantry items by name
  Stream<List<PantryItem>> searchPantryItems(String query) {
    return _firestore
        .collection(_collectionName)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PantryItem.fromJson({'id': doc.id, ...data});
          }).toList();
        });
  }

  // Get pantry items by category
  Stream<List<PantryItem>> getPantryItemsByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PantryItem.fromJson({'id': doc.id, ...data});
          }).toList();
        });
  }

  // Get low stock items (quantity <= 1)
  Stream<List<PantryItem>> getLowStockItems() {
    return _firestore
        .collection(_collectionName)
        .where('quantity', isLessThanOrEqualTo: 1.0)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PantryItem.fromJson({'id': doc.id, ...data});
          }).toList();
        });
  }

  // Get expiring items (within next 7 days)
  Stream<List<PantryItem>> getExpiringItems() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return _firestore
        .collection(_collectionName)
        .where('expiryDate', isGreaterThanOrEqualTo: now.toIso8601String())
        .where('expiryDate', isLessThanOrEqualTo: weekFromNow.toIso8601String())
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PantryItem.fromJson({'id': doc.id, ...data});
          }).toList();
        });
  }

  // Batch operations
  Future<void> addMultipleItems(List<PantryItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final docRef = _firestore.collection(_collectionName).doc();
        batch.set(docRef, item.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add multiple items: $e');
    }
  }

  // Clear all items (for testing/reset)
  Future<void> clearAllItems() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear all items: $e');
    }
  }
}
