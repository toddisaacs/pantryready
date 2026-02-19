import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantryready/firebase_options.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/screens/inventory_screen.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';
import 'package:pantryready/screens/edit_item_screen.dart';
import 'package:pantryready/screens/inventory_item_detail_screen.dart';
import 'package:pantryready/screens/settings_screen.dart';
import 'package:pantryready/screens/environment_settings_screen.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/widgets/item_quantity_dialog.dart';
import 'package:pantryready/services/data_service.dart';
import 'package:pantryready/services/data_service_factory.dart';
import 'package:pantryready/config/environment_config.dart';
import 'package:pantryready/services/version_service.dart';
import 'dart:async'; // Added for StreamSubscription

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Log version information for debugging
  VersionService.logVersionInfo();

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
    const String useEmptyData = String.fromEnvironment(
      'USE_EMPTY_DATA',
      defaultValue: 'false',
    );

    if (buildEnv.isNotEmpty) {
      EnvironmentConfig.configureFromBuildArgs();
    } else if (useEmptyData.toLowerCase() == 'true') {
      EnvironmentConfig.configureForLocalDevelopmentWithEmptyData();
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
    debugPrint('Loading data from service: ${_dataService.runtimeType}');
    _dataSubscription?.cancel();
    _dataSubscription = _dataService.getPantryItems().listen(
      (items) {
        debugPrint('Received ${items.length} items from data service');
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
    _dataService.deletePantryItem(item.id).catchError((error) {
      debugPrint('Error deleting item: $error');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to delete item: $error'),
          backgroundColor: Colors.red,
        ),
      );
      // Re-add the item to the list if delete failed
      setState(() {
        _pantryItems.add(item);
      });
    });
  }

  // Method to edit an existing pantry item (direct navigation)
  void _editPantryItem(PantryItem item) async {
    final context = navigatorKey.currentContext;
    if (context == null || !mounted) return;

    final PantryItem? updatedItem = await Navigator.push<PantryItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditItemScreen(item: item, onSave: _updatePantryItem),
      ),
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

  // Nav index mapping: 0=Pantry, 1=Scan(intercepted), 2=Alerts, 3=Settings
  // IndexedStack children: 0=Pantry, 1=Alerts, 2=Settings
  static const _navToStack = {0: 0, 2: 1, 3: 2};

  void _onItemTapped(int index) {
    if (index == 1) {
      _showScanModeSheet();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showScanModeSheet() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppConstants.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppConstants.textSecondaryColor.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What are you doing?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScanOption(
                    context,
                    ScanMode.shelve,
                    Icons.add_circle_outline,
                    AppConstants.successColor,
                    'Shelving',
                    'Adding items to pantry',
                  ),
                  _buildScanOption(
                    context,
                    ScanMode.remove,
                    Icons.remove_circle_outline,
                    AppConstants.errorColor,
                    'Removing',
                    'Taking items from pantry',
                  ),
                  _buildScanOption(
                    context,
                    ScanMode.check,
                    Icons.info_outline,
                    const Color(0xFF2196F3),
                    'Checking',
                    'View stock level',
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildScanOption(
    BuildContext context,
    ScanMode mode,
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppConstants.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppConstants.textSecondaryColor),
      ),
      onTap: () {
        Navigator.pop(context);
        _handleBarcodeScan(mode);
      },
    );
  }

  Future<void> _handleBarcodeScan(ScanMode mode) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !mounted) return;

    final String? scannedBarcode = await Navigator.push<String>(
      ctx,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(scanMode: mode),
      ),
    );
    if (scannedBarcode == null || scannedBarcode.isEmpty || !mounted) return;

    PantryItem? existingItem;
    for (final item in _pantryItems) {
      if (item.barcode == scannedBarcode) {
        existingItem = item;
        break;
      }
    }

    final scanCtx = navigatorKey.currentContext;
    if (scanCtx == null || !mounted) return;

    switch (mode) {
      case ScanMode.shelve:
        if (existingItem != null) {
          showDialog(
            context: scanCtx,
            builder:
                (context) => ItemQuantityDialog(
                  item: existingItem!,
                  onUpdateItem: _updatePantryItem,
                  onEditItem: _editPantryItem,
                  initialAddMode: true,
                ),
          );
        } else {
          final PantryItem? newItem = await Navigator.push<PantryItem>(
            scanCtx,
            MaterialPageRoute(
              builder:
                  (context) => AddItemScreen(
                    initialBarcode: scannedBarcode,
                    existingItems: _pantryItems,
                  ),
            ),
          );
          if (mounted && newItem != null) {
            _addPantryItem(newItem);
          }
        }
      case ScanMode.remove:
        if (existingItem != null) {
          showDialog(
            context: scanCtx,
            builder:
                (context) => ItemQuantityDialog(
                  item: existingItem!,
                  onUpdateItem: _updatePantryItem,
                  onEditItem: _editPantryItem,
                  initialAddMode: false,
                ),
          );
        } else {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Item not found in pantry'),
              backgroundColor: AppConstants.warningColor,
            ),
          );
        }
      case ScanMode.check:
        if (existingItem != null) {
          Navigator.push(
            scanCtx,
            MaterialPageRoute(
              builder:
                  (context) => InventoryItemDetailScreen(
                    item: existingItem!,
                    onDelete: _deletePantryItem,
                    onEdit: _editPantryItem,
                  ),
            ),
          );
        } else {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Item not found in pantry'),
              backgroundColor: AppConstants.warningColor,
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: VersionService.displayVersion,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: _buildBrownSwatch(),
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryDarkColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppConstants.cardColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.accentColor,
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
          fillColor: AppConstants.surfaceColor,
        ),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _navToStack[_selectedIndex] ?? 0,
          children: [
            InventoryScreen(
              key: ValueKey(
                'inventory_${EnvironmentConfig.environment}_${EnvironmentConfig.dataSource}',
              ),
              pantryItems: _pantryItems,
              onAddItem: _addPantryItem,
              onDeleteItem: _deletePantryItem,
              onEditItem: (item) => _editPantryItem(item),
              onItemUpdated: _handleUpdatedItem,
              filterMode: InventoryFilterMode.all,
            ),
            InventoryScreen(
              key: ValueKey(
                'alerts_${EnvironmentConfig.environment}_${EnvironmentConfig.dataSource}',
              ),
              pantryItems: _pantryItems,
              onAddItem: _addPantryItem,
              onDeleteItem: _deletePantryItem,
              onEditItem: (item) => _editPantryItem(item),
              onItemUpdated: _handleUpdatedItem,
              filterMode: InventoryFilterMode.alerts,
            ),
            SettingsScreen(
              key: ValueKey(
                'settings_${EnvironmentConfig.environment}_${EnvironmentConfig.dataSource}',
              ),
              useFirestore: EnvironmentConfig.useFirestore,
              onFirestoreToggle: (value) {},
              useOpenFoodFacts: true,
              onApiToggle: (value) {},
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Pantry'),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppConstants.accentColor,
          unselectedItemColor: AppConstants.textSecondaryColor,
          onTap: _onItemTapped,
        ),
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

  static MaterialColor _buildBrownSwatch() {
    const primary = 0xFF5D4037;
    return const MaterialColor(primary, <int, Color>{
      50: Color(0xFFEFEBE9),
      100: Color(0xFFD7CCC8),
      200: Color(0xFFBCAAA4),
      300: Color(0xFFA1887F),
      400: Color(0xFF8D6E63),
      500: Color(primary),
      600: Color(0xFF546E7A),
      700: Color(0xFF4E342E),
      800: Color(0xFF3E2723),
      900: Color(0xFF2C1810),
    });
  }

  @override
  void dispose() {
    DataServiceFactory.dispose();
    _dataSubscription?.cancel();
    super.dispose();
  }
}
