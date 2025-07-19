import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/pantry_item.dart';
import 'inventory_item_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  List<PantryItem> get _filteredItems {
    List<PantryItem> items = AppConstants.samplePantryItems;

    if (_searchQuery.isNotEmpty) {
      items =
          items
              .where(
                (item) =>
                    item.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (item.category?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    if (_selectedCategory != null && _selectedCategory != 'All') {
      items =
          items.where((item) => item.category == _selectedCategory).toList();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add item screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add item functionality coming soon!'),
            ),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
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
          const SizedBox(height: 12),
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', null),
                const SizedBox(width: 8),
                ...AppConstants.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildCategoryChip(category, category),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: AppConstants.backgroundColor,
      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.primaryColor : AppConstants.textColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildInventoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildInventoryItemTile(item);
      },
    );
  }

  Widget _buildInventoryItemTile(PantryItem item) {
    final isLowStock = item.quantity < 5;
    final isExpiringSoon =
        item.expiryDate != null &&
        item.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(item.category).withOpacity(0.1),
          child: Icon(
            _getCategoryIcon(item.category),
            color: _getCategoryColor(item.category),
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
            if (isLowStock) Icon(Icons.warning, color: Colors.orange, size: 16),
            if (isExpiringSoon)
              Icon(Icons.schedule, color: Colors.red, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.quantity} ${item.unit}'),
            if (item.category != null)
              Text(
                item.category!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            if (item.expiryDate != null)
              Text(
                'Expires: ${_formatDate(item.expiryDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isExpiringSoon
                          ? Colors.red
                          : AppConstants.textSecondaryColor,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InventoryItemDetailScreen(item: item),
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
                : 'Tap the + button to add your first item',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Canned Goods':
        return Colors.orange;
      case 'Grains':
        return Colors.amber;
      case 'Beverages':
        return Colors.blue;
      case 'Condiments':
        return Colors.purple;
      case 'Snacks':
        return Colors.pink;
      case 'Frozen Foods':
        return Colors.cyan;
      case 'Dairy':
        return Colors.white;
      case 'Produce':
        return Colors.green;
      case 'Meat':
        return Colors.red;
      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Canned Goods':
        return Icons.inventory;
      case 'Grains':
        return Icons.grain;
      case 'Beverages':
        return Icons.local_drink;
      case 'Condiments':
        return Icons.kitchen;
      case 'Snacks':
        return Icons.cake;
      case 'Frozen Foods':
        return Icons.ac_unit;
      case 'Dairy':
        return Icons.egg;
      case 'Produce':
        return Icons.eco;
      case 'Meat':
        return Icons.set_meal;
      default:
        return Icons.kitchen;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
