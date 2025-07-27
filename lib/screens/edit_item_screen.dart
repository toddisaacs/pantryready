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
    // Note: We don't set expiry date from item as it's now per batch
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
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              _buildCategorySection(),
              const SizedBox(height: 16),
              _buildQuantitySection(),
              const SizedBox(height: 16),
              _buildExpirySection(),
              const SizedBox(height: 16),
              _buildNotesSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<SystemCategory>(
              value: _selectedSystemCategory,
              decoration: const InputDecoration(labelText: 'System Category'),
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
                  _selectedSubcategory =
                      null; // Reset subcategory when category changes
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubcategory,
              decoration: const InputDecoration(
                labelText: 'Subcategory (Optional)',
              ),
              items:
                  _getSubcategoriesForCategory(_selectedSystemCategory).map((
                    subcategory,
                  ) {
                    return DropdownMenuItem(
                      value: subcategory,
                      child: Text(subcategory),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubcategory = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSubcategoriesForCategory(SystemCategory category) {
    switch (category) {
      case SystemCategory.food:
        return [
          'Canned Goods',
          'Grains',
          'Condiments',
          'Snacks',
          'Frozen Foods',
          'Dairy',
          'Produce',
          'Meat',
        ];
      case SystemCategory.water:
        return ['Drinking Water', 'Purified Water', 'Spring Water'];
      case SystemCategory.medical:
        return ['First Aid', 'Medications', 'Supplies'];
      case SystemCategory.hygiene:
        return ['Personal Care', 'Cleaning', 'Sanitation'];
      case SystemCategory.tools:
        return ['Hand Tools', 'Power Tools', 'Equipment'];
      case SystemCategory.lighting:
        return ['Flashlights', 'Batteries', 'Candles'];
      case SystemCategory.shelter:
        return ['Tents', 'Tarps', 'Sleeping Bags'];
      case SystemCategory.communication:
        return ['Radios', 'Phones', 'Chargers'];
      case SystemCategory.security:
        return ['Locks', 'Alarms', 'Safes'];
      case SystemCategory.other:
        return ['Miscellaneous'];
    }
  }

  Widget _buildQuantitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildExpirySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expiry Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add any additional notes',
              ),
              maxLines: 3,
            ),
          ],
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
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
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

      // Create a new batch if expiry date is set
      List<ItemBatch> updatedBatches = List.from(widget.item.batches);
      if (_selectedExpiryDate != null) {
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

      // Update the PantryItem
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
