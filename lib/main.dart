import 'package:flutter/material.dart';

void main() {
  runApp(const PantryReadyApp());
}

class PantryReadyApp extends StatelessWidget {
  const PantryReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryReady',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MainScreen(),
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

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    InventoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PantryReady')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Inventory'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  // Sample static pantry list
  final List<PantryItem> pantryItems = const [
    PantryItem(name: 'Canned Beans', quantity: 12, unit: 'cans'),
    PantryItem(name: 'Rice', quantity: 5, unit: 'lbs'),
    PantryItem(name: 'Bottled Water', quantity: 24, unit: 'bottles'),
    PantryItem(name: 'Pasta', quantity: 8, unit: 'boxes'),
    PantryItem(name: 'Peanut Butter', quantity: 3, unit: 'jars'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pantryItems.length,
      itemBuilder: (context, index) {
        final item = pantryItems[index];
        return ListTile(
          leading: const Icon(Icons.kitchen),
          title: Text(item.name),
          subtitle: Text('${item.quantity} ${item.unit}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryItemDetailScreen(item: item),
              ),
            );
          },
        );
      },
    );
  }
}

class InventoryItemDetailScreen extends StatelessWidget {
  final PantryItem item;

  const InventoryItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantity: ${item.quantity} ${item.unit}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Text(
              'More details coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class PantryItem {
  final String name;
  final int quantity;
  final String unit;

  const PantryItem({
    required this.name,
    required this.quantity,
    required this.unit,
  });
}
