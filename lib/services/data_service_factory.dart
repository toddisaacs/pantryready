import 'package:flutter/foundation.dart';
import 'package:pantryready/config/environment_config.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/services/data_service.dart';
import 'package:pantryready/services/mock_data_service.dart';
import 'package:pantryready/services/environment_firestore_service.dart';

class DataServiceFactory {
  static DataService? _currentService;
  static EnvironmentFirestoreService? _firestoreService;

  // Factory method to get the appropriate data service
  static DataService getDataService() {
    final dataSource = EnvironmentConfig.dataSource;

    debugPrint('Creating data service for: $dataSource');

    switch (dataSource) {
      case DataSource.mock:
        if (_currentService is! MockDataService) {
          _currentService = MockDataService();
          debugPrint('Created MockDataService');
        }
        break;

      case DataSource.local:
        if (_currentService is! LocalDataService) {
          _currentService = LocalDataService();
          debugPrint('Created LocalDataService');
        }
        break;

      case DataSource.firestore:
        if (_currentService is! FirestoreDataService) {
          _firestoreService ??= EnvironmentFirestoreService();
          _currentService = FirestoreDataService(_firestoreService!);
          debugPrint(
            'Created FirestoreDataService for profile: ${EnvironmentConfig.firestoreProfile}',
          );
        }
        break;
    }

    return _currentService!;
  }

  // Method to switch data source
  static DataService switchDataSource(DataSource newDataSource) {
    debugPrint(
      'Switching data source from ${EnvironmentConfig.dataSource} to $newDataSource',
    );

    // Dispose of current service before switching
    if (_currentService is MockDataService) {
      (_currentService as MockDataService).dispose();
    } else if (_currentService is LocalDataService) {
      (_currentService as LocalDataService).dispose();
    }

    EnvironmentConfig.setDataSource(newDataSource);
    _currentService = null; // Force recreation

    return getDataService();
  }

  // Method to switch Firestore profile
  static DataService switchFirestoreProfile(String profile) {
    if (EnvironmentConfig.dataSource != DataSource.firestore) {
      debugPrint(
        'Cannot switch Firestore profile when not using Firestore data source',
      );
      return getDataService();
    }

    debugPrint('Switching Firestore profile to: $profile');
    EnvironmentConfig.setFirestoreProfile(profile);

    // Recreate Firestore service with new profile
    _firestoreService?.switchProfile(profile);
    _currentService = null; // Force recreation

    return getDataService();
  }

  // Method to configure for specific environment
  static DataService configureForEnvironment(Environment environment) {
    debugPrint('Configuring for environment: $environment');

    // Dispose of current service before configuring
    if (_currentService is MockDataService) {
      (_currentService as MockDataService).dispose();
    } else if (_currentService is LocalDataService) {
      (_currentService as LocalDataService).dispose();
    }

    switch (environment) {
      case Environment.local:
        EnvironmentConfig.configureForLocalDevelopment();
        break;
      case Environment.dev:
        EnvironmentConfig.configureForDev();
        break;
      case Environment.prod:
        EnvironmentConfig.configureForProd();
        break;
    }

    _currentService = null; // Force recreation
    return getDataService();
  }

  // Get current service info
  static String getCurrentServiceInfo() {
    final service = _currentService;
    if (service == null) return 'No service initialized';

    final dataSource = EnvironmentConfig.dataSource;
    final environment = EnvironmentConfig.environment;
    final profile = EnvironmentConfig.firestoreProfile;

    return '${service.runtimeType} - $dataSource - $environment - $profile';
  }

  // Reset to default configuration
  static DataService resetToDefault() {
    debugPrint('Resetting to default configuration');

    // Dispose of current service before resetting
    if (_currentService is MockDataService) {
      (_currentService as MockDataService).dispose();
    } else if (_currentService is LocalDataService) {
      (_currentService as LocalDataService).dispose();
    }

    EnvironmentConfig.configureForLocalDevelopment();
    _currentService = null;
    return getDataService();
  }

  // Dispose current service (useful for cleanup)
  static void dispose() {
    if (_currentService is MockDataService) {
      (_currentService as MockDataService).dispose();
    } else if (_currentService is LocalDataService) {
      (_currentService as LocalDataService).dispose();
    }
    _currentService = null;
    _firestoreService = null;
    debugPrint('Data service disposed');
  }
}

// Updated FirestoreDataService that uses EnvironmentFirestoreService
class FirestoreDataService implements DataService {
  final EnvironmentFirestoreService _firestoreService;

  FirestoreDataService(this._firestoreService);

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

  // Additional methods for environment management
  void switchProfile(String profile) {
    _firestoreService.switchProfile(profile);
  }

  String get collectionName => _firestoreService.collectionName;
  String get currentProfile => _firestoreService.currentProfile;
}
