import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';

class EditItemScreen extends StatefulWidget {
  final PantryItem item;
  final Function(PantryItem) onSave;

  const EditItemScreen({super.key, required this.item, required this.onSave});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late String _selectedUnit;
  late SystemCategory _selectedSystemCategory;
  late String? _selectedSubcategory;
  late DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text: widget.item.totalQuantity.toString(),
    );
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _selectedUnit = widget.item.unit;
    _selectedSystemCategory = widget.item.systemCategory;
    _selectedSubcategory = widget.item.subcategory;
    _selectedExpiryDate = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveItem),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Enter item name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items:
                          AppConstants.units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
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
              const SizedBox(height: 12),
              DropdownButtonFormField<SystemCategory>(
                value: _selectedSystemCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    SystemCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(category.emoji),
                            const SizedBox(width: 8),
                            Text(category.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSystemCategory = value!;
                    _selectedSubcategory = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSubcategory,
                decoration: const InputDecoration(
                  labelText: 'Subcategory (Optional)',
                ),
                items:
                    (AppConstants.subcategories[_selectedSystemCategory] ??
                            ['Miscellaneous'])
                        .map((subcategory) {
                          return DropdownMenuItem(
                            value: subcategory,
                            child: Text(subcategory),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategory = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText:
                            _selectedExpiryDate == null
                                ? 'Select date'
                                : _formatDate(_selectedExpiryDate!),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedExpiryDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedExpiryDate = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveItem,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Changes'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(_quantityController.text);

      final List<ItemBatch> updatedBatches = List.from(widget.item.batches);

      if (updatedBatches.isNotEmpty && quantity != widget.item.totalQuantity) {
        final latestBatch = updatedBatches.last;
        final quantityDiff = quantity - widget.item.totalQuantity;
        updatedBatches[updatedBatches.length - 1] = latestBatch.copyWith(
          quantity: latestBatch.quantity + quantityDiff,
        );
      } else if (updatedBatches.isEmpty && quantity > 0) {
        updatedBatches.add(
          ItemBatch(
            quantity: quantity,
            purchaseDate: DateTime.now(),
            expiryDate: _selectedExpiryDate,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          ),
        );
      } else if (_selectedExpiryDate != null) {
        final newBatch = ItemBatch(
          quantity: quantity,
          purchaseDate: DateTime.now(),
          expiryDate: _selectedExpiryDate,
          costPerUnit: null,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        updatedBatches.add(newBatch);
      }

      final updatedItem = widget.item.copyWith(
        name: _nameController.text,
        unit: _selectedUnit,
        systemCategory: _selectedSystemCategory,
        subcategory: _selectedSubcategory,
        batches: updatedBatches,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      widget.onSave(updatedItem);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
