import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/screens/barcode_scanner_screen.dart';
import 'package:pantryready/services/product_api_service.dart';
import 'package:pantryready/services/openfoodfacts_service.dart';

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
  SystemCategory _selectedSystemCategory = SystemCategory.food;
  String? _selectedSubcategory;
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;
  late ProductApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = OpenFoodFactsService();

    // Pre-fill barcode if provided
    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
      // Try to fetch product details if barcode is provided
      _fetchProductDetails(widget.initialBarcode!);
    }

    // Pre-fill fields from suggested item if provided
    if (widget.suggestedItem != null) {
      final item = widget.suggestedItem!;
      _nameController.text = item.name;
      _quantityController.text = item.totalQuantity.toString();
      _notesController.text = item.notes ?? '';
      _selectedUnit = item.unit;
      _selectedSystemCategory = item.systemCategory;
      _selectedSubcategory = item.subcategory;
      // Note: We don't set expiry date from suggested item as it's now per batch
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    if (barcode.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.lookupProduct(barcode);

      if (result.found && result.name != null) {
        setState(() {
          _nameController.text = result.name!;
          if (result.category != null) {
            _selectedSystemCategory = _mapToSystemCategory(result.category!);
          }
          if (result.brand != null && result.brand!.isNotEmpty) {
            _notesController.text = 'Brand: ${result.brand}';
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found product: ${result.name}'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        }
      } else if (result.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('API Error: ${result.errorMessage}'),
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
        category.contains('beverage') ||
        category.contains('drink')) {
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

    // Default to food for most items
    return SystemCategory.food;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
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
                      _buildBarcodeSection(),
                      const SizedBox(height: 16),
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

  Widget _buildBarcodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Barcode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
                      hintText: 'Enter or scan barcode',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    final barcode = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerScreen(),
                      ),
                    );
                    if (barcode != null) {
                      setState(() {
                        _barcodeController.text = barcode;
                      });
                      _fetchProductDetails(barcode);
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

      // Create initial batch
      final initialBatch = ItemBatch(
        quantity: quantity,
        purchaseDate: DateTime.now(),
        expiryDate: _selectedExpiryDate,
        costPerUnit: null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Create the new PantryItem
      final newItem = PantryItem(
        name: _nameController.text,
        unit: _selectedUnit,
        systemCategory: _selectedSystemCategory,
        subcategory: _selectedSubcategory,
        batches: [initialBatch],
        barcode:
            _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // Set reasonable defaults for survival/preparedness fields
        dailyConsumptionRate: _getDefaultConsumptionRate(
          _selectedSystemCategory,
        ),
        minStockLevel: quantity * 0.5, // 50% of current quantity
        maxStockLevel: quantity * 3.0, // 3x current quantity
        isEssential:
            _selectedSystemCategory == SystemCategory.water ||
            _selectedSystemCategory == SystemCategory.medical,
        applicableScenarios: _getDefaultScenarios(_selectedSystemCategory),
      );

      Navigator.of(context).pop(newItem);
    }
  }

  double? _getDefaultConsumptionRate(SystemCategory category) {
    switch (category) {
      case SystemCategory.water:
        return 3.0; // 3 liters per person per day
      case SystemCategory.food:
        return 2.0; // 2 lbs per person per day
      case SystemCategory.medical:
        return 0.01; // Very low consumption
      case SystemCategory.hygiene:
        return 0.5; // 0.5 units per person per day
      default:
        return null; // No default consumption rate
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
