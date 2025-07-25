import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';

class ItemQuantityDialog extends StatefulWidget {
  final PantryItem item;
  final Function(PantryItem)? onUpdateItem;
  final Function(PantryItem)? onEditItem;

  const ItemQuantityDialog({
    super.key,
    required this.item,
    this.onUpdateItem,
    this.onEditItem,
  });

  @override
  State<ItemQuantityDialog> createState() => _ItemQuantityDialogState();
}

class _ItemQuantityDialogState extends State<ItemQuantityDialog> {
  late double _addQuantity;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _addQuantity = 1.0; // Default to adding 1 item
    _quantityController = TextEditingController(text: _addQuantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateAddQuantity(double newQuantity) {
    setState(() {
      _addQuantity = newQuantity.clamp(0, double.infinity);
      _quantityController.text = _addQuantity.toString();
    });
  }

  void _applyChanges() {
    if (widget.onUpdateItem != null && _addQuantity > 0) {
      final updated = widget.item.copyWith(
        quantity: widget.item.quantity + _addQuantity,
        updatedAt: DateTime.now(),
      );
      widget.onUpdateItem!(updated);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final newTotal = widget.item.quantity + _addQuantity;
    return AlertDialog(
      title: Text('Item Found: ${widget.item.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Stock: ${widget.item.quantity} ${widget.item.unit}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _updateAddQuantity(_addQuantity - 1),
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                color: Colors.red,
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    final newQuantity = double.tryParse(value) ?? _addQuantity;
                    _updateAddQuantity(newQuantity);
                  },
                ),
              ),
              IconButton(
                onPressed: () => _updateAddQuantity(_addQuantity + 1),
                icon: const Icon(Icons.add_circle_outline, size: 32),
                color: AppConstants.successColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Add ${_addQuantity.toStringAsFixed(_addQuantity.truncateToDouble() == _addQuantity ? 0 : 1)} for total of ${newTotal.toStringAsFixed(newTotal.truncateToDouble() == newTotal ? 0 : 1)} ${widget.item.unit}',
            style: TextStyle(
              fontSize: 14,
              color:
                  _addQuantity > 0
                      ? AppConstants.primaryColor
                      : AppConstants.textSecondaryColor,
              fontWeight:
                  _addQuantity > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (widget.onEditItem != null) {
              widget.onEditItem!(widget.item);
            }
          },
          child: const Text('Edit'),
        ),
        ElevatedButton(
          onPressed: _addQuantity > 0 ? _applyChanges : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
