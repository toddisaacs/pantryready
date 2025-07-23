import 'package:pantryready/services/product_api_service.dart';

/// Mock implementation of ProductApiService for testing and development
class MockProductApiService implements ProductApiService {
  final Map<String, Map<String, dynamic>> _mockData = {
    '3274080005003': {
      'name': 'Nutella',
      'brand': 'Ferrero',
      'category': 'Spreads',
      'ingredients':
          'Sugar, palm oil, hazelnuts (13%), skimmed milk powder (8.7%), fat-reduced cocoa (7.4%), emulsifier: lecithins (soya), vanillin',
      'nutrition': {
        'calories_per_100g': 539.0,
        'fat_per_100g': 30.9,
        'carbs_per_100g': 57.5,
        'sugar_per_100g': 56.3,
        'protein_per_100g': 6.3,
        'salt_per_100g': 0.107,
      },
    },
    '4901301234567': {
      'name': 'Green Tea',
      'brand': 'Generic Brand',
      'category': 'Beverages',
      'ingredients': 'Green tea extract, water, natural flavoring',
      'nutrition': {
        'calories_per_100g': 1.0,
        'fat_per_100g': 0.0,
        'carbs_per_100g': 0.2,
        'sugar_per_100g': 0.0,
        'protein_per_100g': 0.1,
        'salt_per_100g': 0.001,
      },
    },
    '1234567890123': {
      'name': 'Organic Bananas',
      'brand': 'Farm Fresh',
      'category': 'Produce',
      'ingredients': 'Organic bananas',
      'nutrition': {
        'calories_per_100g': 89.0,
        'fat_per_100g': 0.3,
        'carbs_per_100g': 22.8,
        'sugar_per_100g': 12.2,
        'protein_per_100g': 1.1,
        'fiber_per_100g': 2.6,
      },
    },
    '9876543210987': {
      'name': 'Whole Wheat Bread',
      'brand': 'Baker\'s Choice',
      'category': 'Grains',
      'ingredients':
          'Whole wheat flour, water, yeast, salt, sugar, vegetable oil',
      'nutrition': {
        'calories_per_100g': 247.0,
        'fat_per_100g': 3.4,
        'carbs_per_100g': 41.0,
        'sugar_per_100g': 5.6,
        'protein_per_100g': 13.0,
        'fiber_per_100g': 7.0,
        'salt_per_100g': 1.2,
      },
    },
  };

  /// Simulated network delay for realistic testing
  final Duration _networkDelay;

  /// Whether to simulate network errors
  final bool _simulateErrors;

  MockProductApiService({
    Duration networkDelay = const Duration(milliseconds: 500),
    bool simulateErrors = false,
  }) : _networkDelay = networkDelay,
       _simulateErrors = simulateErrors;

  @override
  String get serviceName => 'Mock Product API';

  @override
  Future<bool> isAvailable() async {
    await Future.delayed(_networkDelay);
    return !_simulateErrors;
  }

  @override
  Future<ProductLookupResult> lookupProduct(String barcode) async {
    // Simulate network delay
    await Future.delayed(_networkDelay);

    // Simulate network errors occasionally
    if (_simulateErrors && DateTime.now().millisecond % 5 == 0) {
      return ProductLookupResult.error('Simulated network error');
    }

    // Validate barcode format
    if (barcode.isEmpty || !_isValidBarcode(barcode)) {
      return ProductLookupResult.error('Invalid barcode format');
    }

    // Check if we have mock data for this barcode
    final mockProduct = _mockData[barcode];
    if (mockProduct == null) {
      return ProductLookupResult.notFound();
    }

    try {
      return ProductLookupResult.success(
        name: mockProduct['name'] as String,
        brand: mockProduct['brand'] as String?,
        category: mockProduct['category'] as String?,
        ingredients: mockProduct['ingredients'] as String?,
        nutritionFacts: mockProduct['nutrition'] as Map<String, dynamic>?,
        imageUrl: _generateMockImageUrl(barcode),
      );
    } catch (e) {
      return ProductLookupResult.error(
        'Error processing mock data: ${e.toString()}',
      );
    }
  }

  /// Generates a mock image URL for testing
  String _generateMockImageUrl(String barcode) {
    return 'https://via.placeholder.com/300x200.png?text=Product+$barcode';
  }

  /// Basic barcode validation (same as real service)
  bool _isValidBarcode(String barcode) {
    // Remove any whitespace
    barcode = barcode.trim();

    // Check if it's numeric and has valid length
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;

    // Common barcode lengths: UPC (12), EAN-13 (13), EAN-8 (8)
    final length = barcode.length;
    return length == 8 || length == 12 || length == 13 || length == 14;
  }

  /// Adds a mock product for testing
  void addMockProduct(String barcode, Map<String, dynamic> productData) {
    _mockData[barcode] = productData;
  }

  /// Removes a mock product
  void removeMockProduct(String barcode) {
    _mockData.remove(barcode);
  }

  /// Clears all mock data
  void clearMockData() {
    _mockData.clear();
  }

  /// Gets all available mock barcodes
  List<String> getMockBarcodes() {
    return _mockData.keys.toList();
  }
}
