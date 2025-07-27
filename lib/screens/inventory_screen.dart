import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/inventory_item_detail_screen.dart';
import 'package:pantryready/screens/add_item_screen.dart';

class InventoryScreen extends StatefulWidget {
  final List<PantryItem> pantryItems;
  final Function(PantryItem?) onAddItem;
  final Function(PantryItem) onDeleteItem;
  final Function(PantryItem) onEditItem;
  final Function(PantryItem) onItemUpdated;

  const InventoryScreen({
    super.key,
    required this.pantryItems,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onEditItem,
    required this.onItemUpdated,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SystemCategory? _selectedCategory;

  List<PantryItem> get _filteredItems {
    List<PantryItem> items = widget.pantryItems;

    if (_searchQuery.isNotEmpty) {
      items =
          items
              .where(
                (item) =>
                    item.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (item.subcategory?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    if (_selectedCategory != null) {
      items =
          items
              .where((item) => item.systemCategory == _selectedCategory)
              .toList();
    }

    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child:
                _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildInventoryList(),
          ),
        ],
      ),
      // FAB is now handled by the parent
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar and manual add button row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final newItem = await Navigator.push<PantryItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddItemScreen(),
                    ),
                  );
                  if (newItem != null) {
                    widget.onAddItem(newItem);
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', null),
                ...SystemCategory.values.map(
                  (category) =>
                      _buildCategoryChip(category.displayName, category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, SystemCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: AppConstants.backgroundColor,
        selectedColor: AppConstants.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppConstants.primaryColor,
        labelStyle: TextStyle(
          color:
              isSelected ? AppConstants.primaryColor : AppConstants.textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    // Group items by system category
    final Map<SystemCategory, List<PantryItem>> grouped = {};
    for (final item in _filteredItems) {
      grouped.putIfAbsent(item.systemCategory, () => []).add(item);
    }

    // Sort categories by display name
    final sortedCategories =
        grouped.keys.toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

    // Calculate total items for ListView
    int totalItems = 0;
    for (final category in sortedCategories) {
      totalItems += 1; // Category header
      totalItems += grouped[category]!.length; // Items in category
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        int runningIndex = 0;
        for (final category in sortedCategories) {
          // Category header
          if (index == runningIndex) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          runningIndex++;
          // Category items
          final items = grouped[category]!;
          if (index < runningIndex + items.length) {
            final item = items[index - runningIndex];
            return _buildInventoryItemTile(item);
          }
          runningIndex += items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInventoryItemTile(PantryItem item) {
    final isLowStock = item.isLowStock;
    final isExpiringSoon = item.hasExpiringItems;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(
            item.systemCategory,
          ).withValues(alpha: 0.1),
          child: Icon(
            _getCategoryIcon(item.systemCategory),
            color: _getCategoryColor(item.systemCategory),
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
            if (isLowStock) Icon(Icons.warning, color: Colors.orange, size: 16),
            if (isExpiringSoon)
              Icon(Icons.schedule, color: Colors.red, size: 16),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Add One',
              onPressed: () {
                // Add a new batch with quantity 1
                final newBatch = ItemBatch(
                  quantity: 1.0,
                  purchaseDate: DateTime.now(),
                  costPerUnit: null,
                );
                final updated = item.addBatch(newBatch);
                widget.onItemUpdated(updated);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              tooltip: 'Remove One',
              onPressed: () {
                // Consume 1 unit from oldest batch
                final updated = item.consumeQuantity(1.0);
                widget.onItemUpdated(updated);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => widget.onEditItem(item),
              tooltip: 'Edit Item',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => InventoryItemDetailScreen(
                    item: item,
                    onDelete: widget.onDeleteItem,
                    onEdit: widget.onEditItem,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? 'No items found'
                : 'No items in your pantry',
            style: TextStyle(
              fontSize: 18,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? 'Try adjusting your search or filters'
                : 'Add your first item to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(SystemCategory category) {
    switch (category) {
      case SystemCategory.water:
        return Colors.blue;
      case SystemCategory.food:
        return Colors.orange;
      case SystemCategory.medical:
        return Colors.red;
      case SystemCategory.hygiene:
        return Colors.purple;
      case SystemCategory.tools:
        return Colors.grey;
      case SystemCategory.lighting:
        return Colors.yellow;
      case SystemCategory.shelter:
        return Colors.brown;
      case SystemCategory.communication:
        return Colors.green;
      case SystemCategory.security:
        return Colors.black;
      case SystemCategory.other:
        return AppConstants.primaryColor;
    }
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
