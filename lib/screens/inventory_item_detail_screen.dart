import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';

class InventoryItemDetailScreen extends StatelessWidget {
  final PantryItem item;
  final Function(PantryItem)? onDelete;

  const InventoryItemDetailScreen({
    super.key,
    required this.item,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit item screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon!'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemHeader(),
            const SizedBox(height: 24),
            _buildItemDetails(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: _getCategoryColor(
                item.category,
              ).withOpacity(0.1),
              child: Icon(
                _getCategoryIcon(item.category),
                size: 32,
                color: _getCategoryColor(item.category),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.category!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Quantity', '${item.quantity} ${item.unit}'),
            if (item.category != null)
              _buildDetailRow('Category', item.category!),
            if (item.expiryDate != null)
              _buildDetailRow(
                'Expiry Date',
                _formatDate(item.expiryDate!),
                isExpiringSoon: item.expiryDate!.isBefore(
                  DateTime.now().add(const Duration(days: 30)),
                ),
              ),
            _buildDetailRow('Added', _formatDate(item.createdAt)),
            _buildDetailRow('Last Updated', _formatDate(item.updatedAt)),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                item.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isExpiringSoon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isExpiringSoon ? Colors.red : AppConstants.textColor,
                fontWeight:
                    isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement increment quantity
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Increment functionality coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Quantity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement decrement quantity
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Decrement functionality coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.remove),
            label: const Text('Use Item'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              side: BorderSide(color: AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                if (onDelete != null) {
                  onDelete!(item);
                  Navigator.of(context).pop(); // Close detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} deleted successfully'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete functionality not available'),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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
