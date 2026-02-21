import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/edit_item_screen.dart';
import 'package:pantryready/widgets/item_quantity_dialog.dart';

class InventoryItemDetailScreen extends StatelessWidget {
  final PantryItem item;
  final Function(PantryItem) onDelete;
  final Function(PantryItem) onEdit;

  const InventoryItemDetailScreen({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
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
            onPressed: () => _editItem(context),
            tooltip: 'Edit Item',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(context),
            tooltip: 'Delete Item',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemHeader(),
            const SizedBox(height: 16),
            _buildItemDetails(),
            const SizedBox(height: 16),
            _buildBatchInformation(),
            const SizedBox(height: 16),
            _buildSurvivalInformation(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppConstants.categoryColors[item.systemCategory]!
                  .withValues(alpha: 0.1),
              child: Icon(
                AppConstants.categoryIcons[item.systemCategory],
                size: 30,
                color: AppConstants.categoryColors[item.systemCategory]!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (item.isEssential)
                        const Icon(
                          Icons.priority_high,
                          color: Colors.red,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.totalQuantity.toStringAsFixed(1)} ${item.unit}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  if (item.subcategory != null && item.subcategory!.isNotEmpty)
                    Text(
                      item.subcategory!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              item.systemCategory.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('System Category', item.systemCategory.displayName),
            if (item.subcategory != null && item.subcategory!.isNotEmpty)
              _buildDetailRow('Subcategory', item.subcategory!),
            _buildDetailRow(
              'Total Quantity',
              '${item.totalQuantity.toStringAsFixed(1)} ${item.unit}',
            ),
            if (item.availableQuantity != item.totalQuantity)
              _buildDetailRow(
                'Available Quantity',
                '${item.availableQuantity.toStringAsFixed(1)} ${item.unit}',
              ),
            if (item.daysOfSupply != null)
              _buildDetailRow(
                'Days of Supply',
                '${item.daysOfSupply!.toStringAsFixed(1)} days',
              ),
            if (item.dailyConsumptionRate != null)
              _buildDetailRow(
                'Daily Consumption',
                '${item.dailyConsumptionRate!.toStringAsFixed(2)} ${item.unit}/day',
              ),
            if (item.minStockLevel != null)
              _buildDetailRow(
                'Min Stock Level',
                '${item.minStockLevel!.toStringAsFixed(1)} ${item.unit}',
              ),
            if (item.maxStockLevel != null)
              _buildDetailRow(
                'Max Stock Level',
                '${item.maxStockLevel!.toStringAsFixed(1)} ${item.unit}',
              ),
            if (item.storageLocation != null &&
                item.storageLocation!.isNotEmpty)
              _buildDetailRow('Storage Location', item.storageLocation!),
            if (item.brand != null && item.brand!.isNotEmpty)
              _buildDetailRow('Brand', item.brand!),
            if (item.barcode != null && item.barcode!.isNotEmpty)
              _buildDetailRow('Barcode', item.barcode!),
            if (item.notes != null && item.notes!.isNotEmpty)
              _buildDetailRow('Notes', item.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchInformation() {
    if (item.batches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...item.sortedBatches.map((batch) => _buildBatchRow(batch)),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchRow(ItemBatch batch) {
    final isExpiringSoon =
        batch.expiryDate != null &&
        batch.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        );
    final isExpired =
        batch.expiryDate != null && batch.expiryDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isExpired
                ? Colors.red.withValues(alpha: 0.1)
                : isExpiringSoon
                ? Colors.orange.withValues(alpha: 0.1)
                : AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isExpired
                  ? Colors.red
                  : isExpiringSoon
                  ? Colors.orange
                  : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${batch.quantity.toStringAsFixed(1)} ${item.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Purchased: ${_formatDate(batch.purchaseDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          if (batch.expiryDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Expires: ${_formatDate(batch.expiryDate!)}',
              style: TextStyle(
                fontSize: 12,
                color:
                    isExpired
                        ? Colors.red
                        : isExpiringSoon
                        ? Colors.orange
                        : AppConstants.textSecondaryColor,
                fontWeight:
                    isExpired || isExpiringSoon
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ],
          if (batch.notes != null && batch.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              batch.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurvivalInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Survival & Preparedness',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Essential Item', item.isEssential ? 'Yes' : 'No'),
            if (item.isLowStock)
              _buildDetailRow('Stock Status', 'Low Stock', Colors.orange),
            if (item.isExcessiveStock)
              _buildDetailRow('Stock Status', 'Excessive Stock', Colors.blue),
            if (item.hasExpiringItems)
              _buildDetailRow(
                'Expiry Status',
                'Has Expiring Items',
                Colors.red,
              ),
            if (item.applicableScenarios.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Applicable Scenarios:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children:
                    item.applicableScenarios.map((scenario) {
                      return Chip(
                        label: Text(scenario.displayName),
                        backgroundColor: AppConstants.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        labelStyle: const TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => ItemQuantityDialog(
                      item: item,
                      onUpdateItem: onEdit,
                      onEditItem: onEdit,
                    ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add/Remove'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _editItem(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? AppConstants.textColor),
            ),
          ),
        ],
      ),
    );
  }

  void _editItem(BuildContext context) async {
    final PantryItem? updatedItem = await Navigator.of(
      context,
    ).push<PantryItem>(
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item, onSave: onEdit),
      ),
    );
    if (updatedItem != null) {
      onEdit(updatedItem);
    }
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Are you sure you want to delete "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete(item);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
