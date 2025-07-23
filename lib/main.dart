import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantryready/firebase_options.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/screens/home_screen.dart';
import 'package:pantryready/screens/inventory_screen.dart';
import 'package:pantryready/screens/settings_screen.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PantryReadyApp());
}

class PantryReadyApp extends StatelessWidget {
  const PantryReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryReady',
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
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<PantryItem> _pantryItems = List.from(
    AppConstants.samplePantryItems,
  );

  static const List<String> _titles = <String>[
    'PantryReady',
    'Inventory',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addPantryItem(PantryItem? item) {
    if (item != null) {
      setState(() {
        _pantryItems.add(item);
      });
    }
  }

  void _deletePantryItem(PantryItem item) {
    setState(() {
      _pantryItems.removeWhere((pantryItem) => pantryItem.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(onAddItem: _addPantryItem),
      InventoryScreen(
        pantryItems: _pantryItems,
        onAddItem: _addPantryItem,
        onDeleteItem: _deletePantryItem,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 1) // Only show on inventory screen
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final newItem = await Navigator.push<PantryItem>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemScreen(),
                  ),
                );
                _addPantryItem(newItem);
              },
            ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
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
        unselectedItemColor: AppConstants.textSecondaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(PantryItem?) onAddItem;

  const HomeScreen({super.key, required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Welcome to PantryReady!',
      style: TextStyle(fontSize: 24),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Settings Screen', style: TextStyle(fontSize: 24));
  }
}
