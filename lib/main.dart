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
import 'package:pantryready/services/product_api_service.dart';
import 'package:pantryready/services/openfoodfacts_service.dart';
import 'package:pantryready/services/mock_product_api_service.dart';
import 'package:pantryready/services/data_service.dart';
import 'package:pantryready/services/data_service_factory.dart';
import 'package:pantryready/config/environment_config.dart';

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

  // Product API service - can be switched between implementations
  late ProductApiService _productApiService;
  bool _useOpenFoodFacts = true; // Toggle for testing

  // Data service - managed by factory
  late DataService _dataService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _initializeDataService();
    _loadSampleData();
  }

  void _initializeApiService() {
    if (_useOpenFoodFacts) {
      _productApiService = OpenFoodFactsService();
    } else {
      _productApiService = MockProductApiService();
    }
  }

  void _initializeDataService() {
    _dataService = DataServiceFactory.getDataService();
  }

  // Method to switch API service (useful for testing)
  void _switchApiService() {
    setState(() {
      _useOpenFoodFacts = !_useOpenFoodFacts;
      _initializeApiService();
    });

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Switched to ${_productApiService.serviceName}'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  // Method to handle data service changes from environment settings
  void _onDataServiceChanged(DataService newDataService) {
    setState(() {
      _dataService = newDataService;
    });

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Data service changed: ${DataServiceFactory.getCurrentServiceInfo()}',
        ),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  void _loadSampleData() {
    // Load sample data from AppConstants
    _pantryItems.addAll(AppConstants.samplePantryItems);
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
  void _editPantryItem(PantryItem item, BuildContext scaffoldContext) async {
    final PantryItem? updatedItem = await Navigator.push<PantryItem>(
      scaffoldContext,
      MaterialPageRoute(builder: (context) => EditItemScreen(item: item)),
    );

    if (updatedItem != null) {
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

  // Enhanced method to handle barcode scanning with API integration
  void _handleBarcodeScanning(BuildContext scaffoldContext) async {
    final String? scannedBarcode = await Navigator.push<String>(
      scaffoldContext,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (scannedBarcode != null && scannedBarcode.isNotEmpty && mounted) {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: scaffoldContext,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Look up product information using the API
        final ProductLookupResult result = await _productApiService
            .lookupProduct(scannedBarcode);

        if (mounted) {
          Navigator.of(scaffoldContext).pop(); // Dismiss loading dialog

          if (result.found) {
            await _handleApiProductResult(
              result,
              scannedBarcode,
              scaffoldContext,
            );
          } else if (result.errorMessage != null) {
            // Show error and fall back to manual entry
            if (mounted) {
              await _showApiErrorDialog(
                result.errorMessage!,
                scannedBarcode,
                scaffoldContext,
              );
            }
          } else {
            // Product not found, proceed with manual entry
            if (mounted) {
              await _handleProductNotFound(scannedBarcode, scaffoldContext);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(scaffoldContext).pop(); // Dismiss loading dialog
          if (mounted) {
            await _showApiErrorDialog(
              'Unexpected error: ${e.toString()}',
              scannedBarcode,
              scaffoldContext,
            );
          }
        }
      }
    }
  }

  // Handle successful API product lookup
  Future<void> _handleApiProductResult(
    ProductLookupResult result,
    String barcode,
    BuildContext scaffoldContext,
  ) async {
    // Check if item already exists
    final existingItem =
        _pantryItems.where((item) => item.barcode == barcode).firstOrNull;

    if (existingItem != null) {
      _showQuantityUpdateDialog(existingItem, result.name!);
    } else {
      // Create new item from API data
      final newItem = result.toPantryItem(barcode: barcode);
      await _showApiProductDialog(newItem, result, scaffoldContext);
    }
  }

  // Show dialog with API product information and option to add/customize
  Future<void> _showApiProductDialog(
    PantryItem suggestedItem,
    ProductLookupResult result,
    BuildContext scaffoldContext,
  ) async {
    if (!mounted) return;

    final bool? shouldAdd = await showDialog<bool>(
      context: scaffoldContext,
      builder:
          (context) => AlertDialog(
            title: Text('Product Found: ${result.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.brand != null)
                    Text(
                      'Brand: ${result.brand}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (result.category != null)
                    Text('Category: ${result.category}'),
                  if (result.ingredients != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      result.ingredients!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  if (result.nutritionFacts != null &&
                      result.nutritionFacts!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Nutrition (per 100g):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...result.nutritionFacts!.entries.map(
                      (entry) => Text(
                        '${_formatNutritionKey(entry.key)}: ${entry.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Would you like to add this item to your pantry?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Customize'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Item'),
              ),
            ],
          ),
    );

    if (shouldAdd == true && mounted) {
      // Navigate to add item screen with pre-filled data
      final PantryItem? newItem = await Navigator.push<PantryItem>(
        scaffoldContext,
        MaterialPageRoute(
          builder:
              (context) => AddItemScreen(
                initialBarcode: suggestedItem.barcode,
                suggestedItem: suggestedItem,
              ),
        ),
      );

      if (newItem != null && mounted) {
        _addPantryItem(newItem);
      }
    }
  }

  // Handle product not found in API
  Future<void> _handleProductNotFound(
    String barcode,
    BuildContext scaffoldContext,
  ) async {
    if (!mounted) return;

    final bool? shouldAdd = await showDialog<bool>(
      context: scaffoldContext,
      builder:
          (context) => AlertDialog(
            title: const Text('Product Not Found'),
            content: Text(
              'No product information found for barcode $barcode.\nWould you like to add it manually?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Manually'),
              ),
            ],
          ),
    );

    if (shouldAdd == true && mounted) {
      final PantryItem? newItem = await Navigator.push<PantryItem>(
        scaffoldContext,
        MaterialPageRoute(
          builder: (context) => AddItemScreen(initialBarcode: barcode),
        ),
      );

      if (newItem != null && mounted) {
        _addPantryItem(newItem);
      }
    }
  }

  // Show API error dialog with fallback option
  Future<void> _showApiErrorDialog(
    String error,
    String barcode,
    BuildContext scaffoldContext,
  ) async {
    if (!mounted) return;

    final bool? shouldContinue = await showDialog<bool>(
      context: scaffoldContext,
      builder:
          (context) => AlertDialog(
            title: const Text('API Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error looking up product: $error'),
                const SizedBox(height: 16),
                const Text('Would you like to add the item manually instead?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Manually'),
              ),
            ],
          ),
    );

    if (shouldContinue == true && mounted) {
      final PantryItem? newItem = await Navigator.push<PantryItem>(
        scaffoldContext,
        MaterialPageRoute(
          builder: (context) => AddItemScreen(initialBarcode: barcode),
        ),
      );

      if (newItem != null && mounted) {
        _addPantryItem(newItem);
      }
    }
  }

  // Format nutrition fact keys for display
  String _formatNutritionKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Show dialog to update quantity for existing item
  void _showQuantityUpdateDialog(PantryItem existingItem, String barcode) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Found: ${existingItem.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current quantity: ${existingItem.quantity} ${existingItem.unit}',
              ),
              const SizedBox(height: 16),
              const Text('Add quantity:'),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter quantity to add',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final additionalQuantity =
                    double.tryParse(quantityController.text) ?? 0;
                if (additionalQuantity > 0) {
                  final updatedItem = existingItem.copyWith(
                    quantity: existingItem.quantity + additionalQuantity,
                    updatedAt: DateTime.now(),
                  );

                  setState(() {
                    final index = _pantryItems.indexWhere(
                      (item) => item.id == existingItem.id,
                    );
                    if (index != -1) {
                      _pantryItems[index] = updatedItem;
                    }
                  });

                  Navigator.of(context).pop();

                  // Show success message
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added $additionalQuantity ${existingItem.unit} to ${existingItem.name}',
                      ),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryReady',
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
            HomeScreen(onAddItem: _addPantryItem),
            InventoryScreen(
              pantryItems: _pantryItems,
              onAddItem: _addPantryItem,
              onDeleteItem: _deletePantryItem,
              onEditItem: (item) => _editPantryItem(item, context),
              onItemUpdated: _handleUpdatedItem,
            ),
            SettingsScreen(
              useFirestore: EnvironmentConfig.useFirestore,
              onFirestoreToggle: (value) {
                // This will be handled by environment settings now
              },
              useOpenFoodFacts: _useOpenFoodFacts,
              onApiToggle: (value) {
                setState(() {
                  _useOpenFoodFacts = value;
                  _initializeApiService();
                });
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
                ? FloatingActionButton(
                  onPressed: () async {
                    final PantryItem? newItem =
                        await Navigator.push<PantryItem>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddItemScreen(),
                          ),
                        );
                    _addPantryItem(newItem);
                  },
                  backgroundColor: AppConstants.primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
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
    super.dispose();
  }
}
