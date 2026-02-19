import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/inventory_item_detail_screen.dart';
import 'package:pantryready/screens/add_item_screen.dart';

enum InventoryFilterMode { all, alerts }

class InventoryScreen extends StatefulWidget {
  final List<PantryItem> pantryItems;
  final Function(PantryItem?) onAddItem;
  final Function(PantryItem) onDeleteItem;
  final Function(PantryItem) onEditItem;
  final Function(PantryItem) onItemUpdated;
  final InventoryFilterMode filterMode;

  const InventoryScreen({
    super.key,
    required this.pantryItems,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onEditItem,
    required this.onItemUpdated,
    this.filterMode = InventoryFilterMode.all,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SystemCategory? _selectedCategory;

  bool get _isAlerts => widget.filterMode == InventoryFilterMode.alerts;

  List<PantryItem> get _filteredItems {
    List<PantryItem> items = widget.pantryItems;

    if (_isAlerts) {
      items =
          items
              .where((item) => item.isLowStock || item.hasExpiringItems)
              .toList();
      return items;
    }

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

  int get _lowStockCount =>
      widget.pantryItems.where((item) => item.isLowStock).length;

  int get _expiringCount =>
      widget.pantryItems.where((item) => item.hasExpiringItems).length;

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
          if (_isAlerts)
            _buildAlertsHeader()
          else
            _buildSearchAndFilterSection(),
          Expanded(
            child:
                _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildInventoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsHeader() {
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
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active,
            color: AppConstants.accentColor,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Items Needing Attention',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
          ),
          if (_lowStockCount > 0)
            _buildAlertPill('$_lowStockCount low', AppConstants.warningColor),
          const SizedBox(width: 8),
          if (_expiringCount > 0)
            _buildAlertPill(
              '$_expiringCount expiring',
              AppConstants.errorColor,
            ),
        ],
      ),
    );
  }

  Widget _buildAlertPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
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
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stats bar
          _buildStatsBar(),
          const SizedBox(height: 12),
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
                    fillColor: AppConstants.surfaceColor,
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
                      builder:
                          (context) =>
                              AddItemScreen(existingItems: widget.pantryItems),
                    ),
                  );
                  if (newItem != null) {
                    widget.onAddItem(newItem);
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.accentColor,
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

  Widget _buildStatsBar() {
    return Row(
      children: [
        _buildStatPill(
          '${widget.pantryItems.length} items',
          AppConstants.primaryColor,
        ),
        const SizedBox(width: 8),
        _buildStatPill('$_lowStockCount low stock', AppConstants.warningColor),
        const SizedBox(width: 8),
        _buildStatPill('$_expiringCount expiring', AppConstants.errorColor),
      ],
    );
  }

  Widget _buildStatPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
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
        backgroundColor: AppConstants.surfaceColor,
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
    if (_isAlerts) {
      return _buildAlertsList();
    }

    // Group items by system category
    final Map<SystemCategory, List<PantryItem>> grouped = {};
    for (final item in _filteredItems) {
      grouped.putIfAbsent(item.systemCategory, () => []).add(item);
    }

    final sortedCategories =
        grouped.keys.toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

    int totalItems = 0;
    for (final category in sortedCategories) {
      totalItems += 1;
      totalItems += grouped[category]!.length;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        int runningIndex = 0;
        for (final category in sortedCategories) {
          if (index == runningIndex) {
            return _buildCategoryHeader(category, grouped[category]!.length);
          }
          runningIndex++;
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

  Widget _buildAlertsList() {
    final lowStockItems =
        _filteredItems.where((item) => item.isLowStock).toList();
    final expiringItems =
        _filteredItems.where((item) => item.hasExpiringItems).toList();

    final sections = <Widget>[];

    if (lowStockItems.isNotEmpty) {
      sections.add(
        _buildAlertSectionHeader('Low Stock', AppConstants.warningColor),
      );
      sections.addAll(lowStockItems.map(_buildInventoryItemTile));
    }

    if (expiringItems.isNotEmpty) {
      sections.add(
        _buildAlertSectionHeader('Expiring Soon', AppConstants.errorColor),
      );
      sections.addAll(expiringItems.map(_buildInventoryItemTile));
    }

    return ListView(padding: const EdgeInsets.all(16.0), children: sections);
  }

  Widget _buildAlertSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(SystemCategory category, int itemCount) {
    final color =
        AppConstants.categoryColors[category] ?? AppConstants.primaryColor;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(category.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            category.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($itemCount)',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemTile(PantryItem item) {
    final isLowStock = item.isLowStock;
    final isExpiringSoon = item.hasExpiringItems;
    final categoryColor =
        AppConstants.categoryColors[item.systemCategory] ??
        AppConstants.primaryColor;

    // Calculate stock percentage for the progress bar
    final stockPercent =
        (item.maxStockLevel != null && item.maxStockLevel! > 0)
            ? (item.totalQuantity / item.maxStockLevel!).clamp(0.0, 1.0)
            : 1.0;
    final barColor =
        stockPercent > 0.6
            ? AppConstants.successColor
            : stockPercent > 0.3
            ? AppConstants.warningColor
            : AppConstants.errorColor;

    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right — add 1
          final newBatch = ItemBatch(
            quantity: 1.0,
            purchaseDate: DateTime.now(),
            costPerUnit: null,
          );
          widget.onItemUpdated(item.addBatch(newBatch));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added 1 ${item.unit} of ${item.name}'),
                backgroundColor: AppConstants.successColor,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          // Swipe left — remove 1
          if (item.totalQuantity >= 1.0) {
            widget.onItemUpdated(item.consumeQuantity(1.0));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed 1 ${item.unit} of ${item.name}'),
                  backgroundColor: AppConstants.warningColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        }
        return false; // Never actually dismiss
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: AppConstants.successColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: AppConstants.successColor),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppConstants.errorColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.remove, color: AppConstants.errorColor),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left color bar
                Container(width: 4, color: categoryColor),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: name + emoji
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppConstants.textColor,
                                ),
                              ),
                            ),
                            Text(
                              item.systemCategory.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Middle row: quantity + days of supply
                        Row(
                          children: [
                            Text(
                              '${item.totalQuantity.toStringAsFixed(1)} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            if (item.daysOfSupply != null) ...[
                              const Text(
                                '  |  ',
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${item.daysOfSupply!.toStringAsFixed(0)} days supply',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      item.daysOfSupply! < 7
                                          ? AppConstants.errorColor
                                          : AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Stock bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: stockPercent,
                            backgroundColor: AppConstants.surfaceColor,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Bottom row: subcategory + badges
                        Row(
                          children: [
                            if (item.subcategory != null &&
                                item.subcategory!.isNotEmpty)
                              Text(
                                item.subcategory!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            const Spacer(),
                            if (isLowStock)
                              _buildBadge(
                                'Low Stock',
                                AppConstants.warningColor,
                              ),
                            if (isLowStock && isExpiringSoon)
                              const SizedBox(width: 6),
                            if (isExpiringSoon)
                              _buildBadge('Expiring', AppConstants.errorColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Chevron
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppConstants.textSecondaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_isAlerts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppConstants.successColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Everything looks good!',
              style: TextStyle(
                fontSize: 18,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No items need attention right now',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? 'No items found'
                : 'No items in your pantry',
            style: const TextStyle(
              fontSize: 18,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? 'Try adjusting your search or filters'
                : 'Add your first item to get started',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
