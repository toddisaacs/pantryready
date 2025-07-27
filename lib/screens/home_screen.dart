import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';
import 'package:pantryready/widgets/item_quantity_dialog.dart';

class HomeScreen extends StatelessWidget {
  final Function(PantryItem?) onAddItem;
  final List<PantryItem> pantryItems;
  final bool useFirestore;
  final VoidCallback? onTestFirestore;
  final Function(PantryItem)? onUpdateItem;
  final Function(PantryItem)? onEditItem;

  const HomeScreen({
    super.key,
    required this.onAddItem,
    required this.pantryItems,
    this.useFirestore = false,
    this.onTestFirestore,
    this.onUpdateItem,
    this.onEditItem,
  });

  static const Widget _spacer = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            _spacer,
            _buildStorageInfoSection(),
            _spacer,
            _buildQuickStatsSection(),
            _spacer,
            _buildRecentItemsSection(context),
            _spacer,
            _buildQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.kitchen, size: 32, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Welcome to PantryReady!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Keep track of your pantry items and never run out of essentials.',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  useFirestore ? Icons.cloud : Icons.storage,
                  size: 24,
                  color: useFirestore ? Colors.blue : Colors.orange,
                ),
                const SizedBox(width: 12),
                Text(
                  'Storage Mode: ${useFirestore ? 'Firestore' : 'Local'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              useFirestore
                  ? 'Data is stored in Firebase Firestore cloud database'
                  : 'Data is stored locally on this device',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onTestFirestore,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Test Firestore Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    final totalItems = pantryItems.length;
    final lowStockItems = pantryItems.where((item) => item.isLowStock).length;
    final expiringItems =
        pantryItems.where((item) => item.hasExpiringItems).length;
    final essentialItems = pantryItems.where((item) => item.isEssential).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Items',
                totalItems.toString(),
                Icons.inventory,
                AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Low Stock',
                lowStockItems.toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Expiring Soon',
                expiringItems.toString(),
                Icons.schedule,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Essential Items',
                essentialItems.toString(),
                Icons.priority_high,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Water Items',
                pantryItems
                    .where(
                      (item) => item.systemCategory == SystemCategory.water,
                    )
                    .length
                    .toString(),
                Icons.water_drop,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Medical Items',
                pantryItems
                    .where(
                      (item) => item.systemCategory == SystemCategory.medical,
                    )
                    .length
                    .toString(),
                Icons.medical_services,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItemsSection(BuildContext context) {
    final recentItems = pantryItems.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...recentItems.map((item) => _buildRecentItemTile(item, context)),
      ],
    );
  }

  Widget _buildRecentItemTile(PantryItem item, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
          child: Icon(
            _getCategoryIcon(item.systemCategory),
            color: AppConstants.primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (item.isEssential)
              Icon(Icons.priority_high, color: Colors.red, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.totalQuantity.toStringAsFixed(1)} ${item.unit}'),
            if (item.subcategory != null && item.subcategory!.isNotEmpty)
              Text(
                item.subcategory!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            if (item.daysOfSupply != null)
              Text(
                '${item.daysOfSupply!.toStringAsFixed(1)} days supply',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      item.daysOfSupply! < 7
                          ? Colors.red
                          : AppConstants.textSecondaryColor,
                ),
              ),
          ],
        ),
        trailing: Text(
          item.systemCategory.emoji,
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          if (onUpdateItem != null) {
            showDialog(
              context: context,
              builder:
                  (dialogContext) => ItemQuantityDialog(
                    item: item,
                    onUpdateItem: onUpdateItem!,
                    onEditItem: onEditItem,
                  ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final newItem = await Navigator.push<PantryItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddItemScreen(),
                    ),
                  );
                  if (context.mounted && newItem != null) {
                    onAddItem(newItem);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final barcode = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                  if (context.mounted && barcode != null) {
                    final newItem = await Navigator.push<PantryItem>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddItemScreen(initialBarcode: barcode),
                      ),
                    );
                    if (context.mounted && newItem != null) {
                      onAddItem(newItem);
                    }
                  }
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(SystemCategory category) {
    switch (category) {
      case SystemCategory.water:
        return Icons.water_drop;
      case SystemCategory.food:
        return Icons.restaurant;
      case SystemCategory.medical:
        return Icons.medical_services;
      case SystemCategory.hygiene:
        return Icons.cleaning_services;
      case SystemCategory.tools:
        return Icons.build;
      case SystemCategory.lighting:
        return Icons.lightbulb;
      case SystemCategory.shelter:
        return Icons.home;
      case SystemCategory.communication:
        return Icons.phone;
      case SystemCategory.security:
        return Icons.security;
      case SystemCategory.other:
        return Icons.inventory;
    }
  }
}
