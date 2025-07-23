import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';

class AddItemScreen extends StatefulWidget {
  final String? initialBarcode;
  final PantryItem? suggestedItem;

  const AddItemScreen({super.key, this.initialBarcode, this.suggestedItem});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();

  String _selectedUnit = AppConstants.units.first;
  String _selectedCategory = AppConstants.categories.first;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();

    // Pre-fill barcode if provided
    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }

    // Pre-fill fields from suggested item if provided
    if (widget.suggestedItem != null) {
      final item = widget.suggestedItem!;
      _nameController.text = item.name;
      _quantityController.text = item.quantity.toString();
      _notesController.text = item.notes ?? '';
      _selectedUnit = item.unit;
      _selectedCategory = item.category;
      _selectedExpiryDate = item.expiryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _scanBarcode() async {
    final String? scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
      setState(() {
        _barcodeController.text = scannedBarcode;
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = PantryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        quantity: double.tryParse(_quantityController.text.trim()) ?? 1.0,
        unit: _selectedUnit,
        category: _selectedCategory,
        expiryDate: _selectedExpiryDate,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        barcode:
            _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter a name'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter quantity';
                        }
                        final n = int.tryParse(value.trim());
                        if (n == null || n < 1) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          AppConstants.units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a unit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    AppConstants.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expiry Date'),
                subtitle: Text(
                  _selectedExpiryDate == null
                      ? 'Not set'
                      : '${_selectedExpiryDate!.month}/${_selectedExpiryDate!.day}/${_selectedExpiryDate!.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickExpiryDate,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Barcode field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Scan or enter barcode',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan Barcode',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
