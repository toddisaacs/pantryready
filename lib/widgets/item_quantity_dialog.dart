import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';

class ItemQuantityDialog extends StatefulWidget {
  final PantryItem item;
  final Function(PantryItem) onUpdateItem;
  final Function(PantryItem)? onEditItem;

  const ItemQuantityDialog({
    super.key,
    required this.item,
    required this.onUpdateItem,
    this.onEditItem,
  });

  @override
  State<ItemQuantityDialog> createState() => _ItemQuantityDialogState();
}

class _ItemQuantityDialogState extends State<ItemQuantityDialog> {
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = '';
  bool _isAddMode = true;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.item.unit;
    _quantityController.text = '1';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${_isAddMode ? 'Add' : 'Remove'} ${widget.item.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current quantity: ${widget.item.totalQuantity.toStringAsFixed(1)} ${widget.item.unit}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    final quantity = double.parse(value);
                    if (quantity <= 0) {
                      return 'Quantity must be greater than 0';
                    }
                    if (!_isAddMode &&
                        quantity > widget.item.availableQuantity) {
                      return 'Cannot remove more than available quantity';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items:
                      AppConstants.units.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddMode = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isAddMode ? AppConstants.primaryColor : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddMode = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isAddMode ? Colors.red : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateQuantity,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isAddMode ? AppConstants.primaryColor : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(_isAddMode ? 'Add' : 'Remove'),
        ),
      ],
    );
  }

  void _updateQuantity() {
    if (_quantityController.text.isEmpty) {
      return;
    }

    final quantity = double.parse(_quantityController.text);
    PantryItem updatedItem;

    if (_isAddMode) {
      // Add a new batch
      final newBatch = ItemBatch(
        quantity: quantity,
        purchaseDate: DateTime.now(),
        costPerUnit: null,
        notes: 'Added via quick dialog',
      );
      updatedItem = widget.item.addBatch(newBatch);
    } else {
      // Remove from available quantity
      updatedItem = widget.item.consumeQuantity(quantity);
    }

    widget.onUpdateItem(updatedItem);
    Navigator.of(context).pop();

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAddMode
              ? 'Added ${quantity.toStringAsFixed(1)} $_selectedUnit of ${widget.item.name}'
              : 'Removed ${quantity.toStringAsFixed(1)} $_selectedUnit of ${widget.item.name}',
        ),
        backgroundColor: _isAddMode ? AppConstants.successColor : Colors.orange,
      ),
    );
  }
}
