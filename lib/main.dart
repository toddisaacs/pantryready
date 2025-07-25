import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantryready/firebase_options.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/screens/home_screen.dart';
import 'package:pantryready/screens/inventory_screen.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';
import 'package:pantryready/screens/edit_item_screen.dart';
import 'package:pantryready/screens/settings_screen.dart';
import 'package:pantryready/screens/environment_settings_screen.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/services/data_service.dart';
import 'package:pantryready/services/data_service_factory.dart';
import 'package:pantryready/config/environment_config.dart';
import 'dart:async'; // Added for StreamSubscription

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure based on build mode and arguments
  if (kReleaseMode) {
    // Production: Use build-time configuration or default to PROD
    EnvironmentConfig.configureFromBuildArgs();
    // Fallback to production if no build args provided
    if (EnvironmentConfig.environment == Environment.local) {
      EnvironmentConfig.configureForProd();
    }
  } else {
    // Development: Check for build args or use local development
    const String buildEnv = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: '',
    );
    if (buildEnv.isNotEmpty) {
      EnvironmentConfig.configureFromBuildArgs();
    } else {
      EnvironmentConfig.configureForLocalDevelopment();
    }
  }

  runApp(const PantryReadyApp());
}

class PantryReadyApp extends StatefulWidget {
  const PantryReadyApp({super.key});

  @override
  State<PantryReadyApp> createState() => _PantryReadyAppState();
}

class _PantryReadyAppState extends State<PantryReadyApp> {
  int _selectedIndex = 0;
  final List<PantryItem> _pantryItems = [];
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Data service - managed by factory
  late DataService _dataService;
  StreamSubscription<List<PantryItem>>? _dataSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDataService();
    _loadDataFromService();
  }

  void _initializeDataService() {
    _dataService = DataServiceFactory.getDataService();
  }

  // Method to handle data service changes from environment settings
  void _onDataServiceChanged(DataService newDataService) {
    // Cancel previous subscription
    _dataSubscription?.cancel();

    setState(() {
      _dataService = newDataService;
    });

    // Start listening to the new data service
    _loadDataFromService();

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Data service changed: ${DataServiceFactory.getCurrentServiceInfo()}',
        ),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  // Load data from the current data service
  void _loadDataFromService() {
    _dataSubscription?.cancel();
    _dataSubscription = _dataService.getPantryItems().listen(
      (items) {
        setState(() {
          _pantryItems.clear();
          _pantryItems.addAll(items);
        });
      },
      onError: (error) {
        debugPrint('Error loading data: $error');
      },
    );
  }

  void _addPantryItem(PantryItem? item) {
    if (item != null) {
      setState(() {
        _pantryItems.add(item);
      });

      // Also save to data service
      _dataService.addPantryItem(item);
    }
  }

  void _deletePantryItem(PantryItem item) {
    setState(() {
      _pantryItems.removeWhere((pantryItem) => pantryItem.id == item.id);
    });

    // Also delete from data service
    _dataService.deletePantryItem(item.id);
  }

  // Method to edit an existing pantry item (direct navigation)
  void _editPantryItem(PantryItem item) async {
    final context = navigatorKey.currentContext;
    if (context == null || !mounted) return;

    final PantryItem? updatedItem = await Navigator.push<PantryItem>(
      context,
      MaterialPageRoute(builder: (context) => EditItemScreen(item: item)),
    );
    if (mounted && updatedItem != null) {
      _updatePantryItem(updatedItem);
    }
  }

  // Method to handle already updated pantry item (from detail screen)
  void _handleUpdatedItem(PantryItem updatedItem) {
    _updatePantryItem(updatedItem);
  }

  // Common method to update pantry item in the list
  void _updatePantryItem(PantryItem updatedItem) {
    setState(() {
      final index = _pantryItems.indexWhere(
        (item) => item.id == updatedItem.id,
      );
      if (index != -1) {
        _pantryItems[index] = updatedItem;
      }
    });

    // Also update in data service
    _dataService.updatePantryItem(updatedItem);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Test Firestore connection
  void _testFirestoreConnection() {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Firestore Status: ${EnvironmentConfig.useFirestore ? "Connected" : "Not Connected"} - Profile: ${EnvironmentConfig.firestoreProfile}',
        ),
        backgroundColor:
            EnvironmentConfig.useFirestore
                ? AppConstants.successColor
                : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryReady',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppConstants.cardColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppConstants.backgroundColor,
        ),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              key: ValueKey(
                'home_${EnvironmentConfig.environment}_${EnvironmentConfig.dataSource}',
              ),
              pantryItems: _pantryItems,
              onAddItem: _addPantryItem,
              onUpdateItem: _updatePantryItem,
              onEditItem: _editPantryItem,
              useFirestore: EnvironmentConfig.useFirestore,
              onTestFirestore: _testFirestoreConnection,
            ),
            InventoryScreen(
              key: ValueKey(
                'inventory_${EnvironmentConfig.environment}_${EnvironmentConfig.dataSource}',
              ),
              pantryItems: _pantryItems,
              onAddItem: _addPantryItem,
              onDeleteItem: _deletePantryItem,
              onEditItem: (item) => _editPantryItem(item),
              onItemUpdated: _handleUpdatedItem,
            ),
            SettingsScreen(
              key: ValueKey(
                'settings_${EnvironmentConfig.environment}_${EnvironmentConfig.dataSource}',
              ),
              useFirestore: EnvironmentConfig.useFirestore,
              onFirestoreToggle: (value) {
                // This will be handled by environment settings now
              },
              useOpenFoodFacts: true, // _useOpenFoodFacts removed
              onApiToggle: (value) {
                // setState(() {
                //   _useOpenFoodFacts = value;
                //   _initializeApiService();
                // });
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppConstants.primaryColor,
          onTap: _onItemTapped,
        ),
        floatingActionButton:
            _selectedIndex == 1
                ? Builder(
                  builder:
                      (fabContext) => FloatingActionButton(
                        onPressed: () async {
                          // Scan barcode first
                          final String? scannedBarcode =
                              await Navigator.push<String>(
                                fabContext,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const BarcodeScannerScreen(),
                                ),
                              );
                          if (scannedBarcode == null ||
                              scannedBarcode.isEmpty) {
                            return;
                          }
                          PantryItem? existingItem;
                          for (final item in _pantryItems) {
                            if (item.barcode == scannedBarcode) {
                              existingItem = item;
                              break;
                            }
                          }
                          if (existingItem == null) {
                            if (mounted) {
                              final PantryItem? newItem =
                                  await Navigator.push<PantryItem>(
                                    fabContext,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddItemScreen(
                                            initialBarcode: scannedBarcode,
                                          ),
                                    ),
                                  );
                              if (mounted) {
                                _addPantryItem(newItem);
                              }
                            }
                            return;
                          }
                          final PantryItem item = existingItem;
                          if (mounted) {
                            showDialog(
                              context: fabContext,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text('Item Found: ${item.name}'),
                                    content: Text(
                                      'Quantity: ${item.quantity} ${item.unit}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          final updated = item.copyWith(
                                            quantity: item.quantity + 1,
                                            updatedAt: DateTime.now(),
                                          );
                                          _updatePantryItem(updated);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('+1'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final updated = item.copyWith(
                                            quantity: (item.quantity - 1).clamp(
                                              0,
                                              double.infinity,
                                            ),
                                            updatedAt: DateTime.now(),
                                          );
                                          _updatePantryItem(updated);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('-1'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _editPantryItem(item);
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    ],
                                  ),
                            );
                          }
                          return;
                        },
                        backgroundColor: AppConstants.primaryColor,
                        tooltip: 'Scan Barcode',
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                      ),
                )
                : null,
      ),
      routes: {
        '/add-item': (context) => const AddItemScreen(),
        '/barcode-scanner': (context) => const BarcodeScannerScreen(),
        '/environment-settings':
            (context) => EnvironmentSettingsScreen(
              onDataServiceChanged: _onDataServiceChanged,
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    DataServiceFactory.dispose();
    _dataSubscription?.cancel(); // Cancel the subscription on dispose
    super.dispose();
  }
}
