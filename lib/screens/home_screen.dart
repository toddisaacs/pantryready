import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/add_item_screen.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';

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
            _buildRecentItemsSection(),
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
    final lowStockItems = pantryItems.where((item) => item.quantity < 5).length;
    final expiringItems =
        pantryItems
            .where(
              (item) =>
                  item.expiryDate != null &&
                  item.expiryDate!.isBefore(
                    DateTime.now().add(const Duration(days: 30)),
                  ),
            )
            .length;

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

  Widget _buildRecentItemsSection() {
    final recentItems = pantryItems.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...recentItems.map((item) => _buildRecentItemTile(item)),
      ],
    );
  }

  Widget _buildRecentItemTile(PantryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.kitchen, color: AppConstants.primaryColor),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${item.quantity} ${item.unit}'),
        trailing: Text(
          item.category,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
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
              child: _buildActionCard(
                context,
                'Add Item',
                Icons.add,
                AppConstants.primaryColor,
                () async {
                  final newItem = await Navigator.push<PantryItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddItemScreen(),
                    ),
                  );
                  onAddItem(newItem);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Scan Barcode',
                Icons.qr_code_scanner,
                AppConstants.accentColor,
                () async {
                  // Scan barcode first
                  final String? scannedBarcode = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                  if (scannedBarcode == null || scannedBarcode.isEmpty) {
                    return;
                  }

                  // Check if item already exists
                  PantryItem? existingItem;
                  for (final item in pantryItems) {
                    if (item.barcode == scannedBarcode) {
                      existingItem = item;
                      break;
                    }
                  }

                  if (existingItem == null) {
                    // New item - navigate to add item screen
                    final PantryItem? newItem =
                        await Navigator.push<PantryItem>(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddItemScreen(
                                  initialBarcode: scannedBarcode,
                                ),
                          ),
                        );
                    if (newItem != null) {
                      onAddItem(newItem);
                    }
                    return;
                  }

                  // Existing item - show quick actions dialog
                  final PantryItem item = existingItem;
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Item Found: ${item.name}'),
                            content: Text(
                              'Quantity: ${item.quantity} ${item.unit}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (onUpdateItem != null) {
                                    final updated = item.copyWith(
                                      quantity: item.quantity + 1,
                                      updatedAt: DateTime.now(),
                                    );
                                    onUpdateItem!(updated);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('+1'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (onUpdateItem != null) {
                                    final updated = item.copyWith(
                                      quantity: (item.quantity - 1).clamp(
                                        0,
                                        double.infinity,
                                      ),
                                      updatedAt: DateTime.now(),
                                    );
                                    onUpdateItem!(updated);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('-1'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  if (onEditItem != null) {
                                    onEditItem!(item);
                                  }
                                },
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
