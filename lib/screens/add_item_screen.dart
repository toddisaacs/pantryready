import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';
import 'package:pantryready/services/product_api_service.dart';
import 'package:pantryready/services/openfoodfacts_service.dart';

class AddItemScreen extends StatefulWidget {
  final String? initialBarcode;
  final PantryItem? suggestedItem;
  final List<PantryItem>? existingItems;

  const AddItemScreen({
    super.key,
    this.initialBarcode,
    this.suggestedItem,
    this.existingItems,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();

  String _selectedUnit = AppConstants.units.first;
  SystemCategory _selectedSystemCategory = SystemCategory.food;
  String? _selectedSubcategory;
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;
  bool _showDetails = false;
  late ProductApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = OpenFoodFactsService();

    // Smart defaults
    _quantityController.text = '1';
    _selectedUnit =
        AppConstants.defaultUnits[_selectedSystemCategory] ??
        AppConstants.units.first;

    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
      _checkForDuplicate(widget.initialBarcode!);
    }

    if (widget.suggestedItem != null) {
      final item = widget.suggestedItem!;
      _nameController.text = item.name;
      _brandController.text = item.brand ?? '';
      _quantityController.text = item.totalQuantity.toString();
      _notesController.text = item.notes ?? '';
      _selectedUnit = item.unit;
      _selectedSystemCategory = item.systemCategory;
      _selectedSubcategory = item.subcategory;
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    if (barcode.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.lookupProduct(barcode);
      debugPrint(
        '[AddItem] lookup result — found:${result.found} '
        'name:${result.name} category:${result.category} '
        'brand:${result.brand} error:${result.errorMessage}',
      );

      if (result.found) {
        setState(() {
          if (result.name != null) {
            _nameController.text = _normalizeName(result.name!);
          }
          if (result.category != null) {
            _selectedSystemCategory = _mapToSystemCategory(result.category!);
            _selectedUnit =
                AppConstants.defaultUnits[_selectedSystemCategory] ??
                _selectedUnit;
          }
          if (result.brand != null && result.brand!.isNotEmpty) {
            _brandController.text = result.brand!;
          }
        });

        if (mounted) {
          if (result.name != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found product: ${result.name}'),
                backgroundColor: AppConstants.successColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product found — enter the name manually'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else if (result.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lookup error: ${result.errorMessage}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found in database'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  SystemCategory _mapToSystemCategory(String externalCategory) {
    final category = externalCategory.toLowerCase();

    if (category.contains('water') ||
        category.contains('waters') ||
        category.contains('mineral-water') ||
        category.contains('drinking-water') ||
        (category.contains('beverage') &&
            !category.contains('food-and-beverage'))) {
      return SystemCategory.water;
    } else if (category.contains('medical') || category.contains('health')) {
      return SystemCategory.medical;
    } else if (category.contains('hygiene') || category.contains('cleaning')) {
      return SystemCategory.hygiene;
    } else if (category.contains('tool') || category.contains('equipment')) {
      return SystemCategory.tools;
    } else if (category.contains('light') || category.contains('power')) {
      return SystemCategory.lighting;
    } else if (category.contains('shelter') || category.contains('home')) {
      return SystemCategory.shelter;
    } else if (category.contains('communication') ||
        category.contains('phone')) {
      return SystemCategory.communication;
    } else if (category.contains('security') || category.contains('safety')) {
      return SystemCategory.security;
    }

    return SystemCategory.food;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Barcode chip (if present)
                      if (_barcodeController.text.isNotEmpty &&
                          widget.initialBarcode != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Chip(
                            avatar: const Icon(
                              Icons.qr_code,
                              size: 18,
                              color: AppConstants.textSecondaryColor,
                            ),
                            label: Text(_barcodeController.text),
                            backgroundColor: AppConstants.surfaceColor,
                          ),
                        ),
                      // Quick Add: Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          hintText: 'What are you adding?',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Quick Add: Brand
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand (optional)',
                          hintText: 'e.g. Del Monte, Libby',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      // Quick Add: Quantity + Unit (side by side)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                                hintText: '1',
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
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
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
                      // Quick Add: Category
                      DropdownButtonFormField<SystemCategory>(
                        value: _selectedSystemCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
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
                            _selectedUnit =
                                AppConstants
                                    .defaultUnits[_selectedSystemCategory] ??
                                _selectedUnit;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // More Details (expandable)
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: const Text(
                            'More Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                          initiallyExpanded: _showDetails,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _showDetails = expanded;
                            });
                          },
                          tilePadding: EdgeInsets.zero,
                          children: [
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedSubcategory,
                              decoration: const InputDecoration(
                                labelText: 'Subcategory (Optional)',
                              ),
                              items:
                                  (AppConstants
                                              .subcategories[_selectedSystemCategory] ??
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
                            // Expiry date
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
                                              : _formatDate(
                                                _selectedExpiryDate!,
                                              ),
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
                            // Barcode — always editable so misreads can be corrected
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _barcodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Barcode',
                                      hintText: 'Enter or scan barcode',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {
                                    final barcode =
                                        _barcodeController.text.trim();
                                    if (barcode.isNotEmpty) {
                                      _fetchProductDetails(barcode);
                                    }
                                  },
                                  icon: const Icon(Icons.search),
                                  tooltip: 'Look up barcode',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final barcode = await Navigator.push<
                                      String
                                    >(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const BarcodeScannerScreen(),
                                      ),
                                    );
                                    if (barcode != null) {
                                      setState(() {
                                        _barcodeController.text = barcode;
                                      });
                                      _checkForDuplicate(barcode);
                                    }
                                  },
                                  icon: const Icon(Icons.qr_code_scanner),
                                  tooltip: 'Scan Barcode',
                                ),
                              ],
                            ),
                          ],
                        ),
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
            child: const Text('Save Item'),
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

      final initialBatch = ItemBatch(
        quantity: quantity,
        purchaseDate: DateTime.now(),
        expiryDate: _selectedExpiryDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final newItem = PantryItem(
        name: _nameController.text,
        brand:
            _brandController.text.trim().isEmpty
                ? null
                : _brandController.text.trim(),
        unit: _selectedUnit,
        systemCategory: _selectedSystemCategory,
        subcategory: _selectedSubcategory,
        batches: [initialBatch],
        barcode:
            _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        dailyConsumptionRate: _getDefaultConsumptionRate(
          _selectedSystemCategory,
        ),
        minStockLevel: quantity * 0.5,
        maxStockLevel: quantity * 3.0,
        isEssential:
            _selectedSystemCategory == SystemCategory.water ||
            _selectedSystemCategory == SystemCategory.medical,
        applicableScenarios: _getDefaultScenarios(_selectedSystemCategory),
      );

      Navigator.of(context).pop(newItem);
    }
  }

  void _checkForDuplicate(String barcode) {
    debugPrint('=== Checking for duplicate barcode: "$barcode" ===');

    if (barcode.isEmpty || widget.existingItems == null) return;

    final duplicate = widget.existingItems!.firstWhere(
      (item) => item.barcode == barcode,
      orElse:
          () => PantryItem(
            name: '',
            unit: '',
            systemCategory: SystemCategory.other,
          ),
    );

    if (duplicate.name.isNotEmpty) {
      setState(() {
        _nameController.text = duplicate.name;
        _brandController.text = duplicate.brand ?? '';
        _quantityController.text = duplicate.totalQuantity.toString();
        _notesController.text = duplicate.notes ?? '';
        _selectedUnit = duplicate.unit;
        _selectedSystemCategory = duplicate.systemCategory;
        _selectedSubcategory = duplicate.subcategory;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showDuplicateDialog(duplicate);
        }
      });
    } else {
      _fetchProductDetails(barcode);
    }
  }

  void _showDuplicateDialog(PantryItem existingItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Item Already Exists'),
            content: Text(
              'An item with this barcode already exists:\n\n'
              '"${existingItem.name}"\n'
              'Current quantity: ${existingItem.totalQuantity} ${existingItem.unit}\n\n'
              'This barcode is already in your inventory. You cannot create a duplicate item.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  double? _getDefaultConsumptionRate(SystemCategory category) {
    switch (category) {
      case SystemCategory.water:
        return 3.0;
      case SystemCategory.food:
        return 2.0;
      case SystemCategory.medical:
        return 0.01;
      case SystemCategory.hygiene:
        return 0.5;
      default:
        return null;
    }
  }

  List<SurvivalScenario> _getDefaultScenarios(SystemCategory category) {
    switch (category) {
      case SystemCategory.water:
        return [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ];
      case SystemCategory.food:
        return [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.isolation,
        ];
      case SystemCategory.medical:
        return [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.earthquake,
          SurvivalScenario.pandemic,
        ];
      case SystemCategory.hygiene:
        return [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.pandemic,
        ];
      case SystemCategory.tools:
        return [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.earthquake,
        ];
      case SystemCategory.lighting:
        return [
          SurvivalScenario.powerOutage,
          SurvivalScenario.winterStorm,
          SurvivalScenario.hurricane,
          SurvivalScenario.earthquake,
        ];
      default:
        return [SurvivalScenario.powerOutage];
    }
  }

  /// Converts all-caps names (common in OpenFoodFacts) to title case.
  /// Mixed-case names are returned unchanged.
  String _normalizeName(String name) {
    if (name != name.toUpperCase()) return name;
    return name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
