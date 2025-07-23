import 'package:pantryready/models/pantry_item.dart';

/// Result of a product lookup operation
class ProductLookupResult {
  final bool found;
  final String? name;
  final String? category;
  final String? brand;
  final String? imageUrl;
  final String? ingredients;
  final Map<String, dynamic>? nutritionFacts;
  final String? errorMessage;

  const ProductLookupResult({
    required this.found,
    this.name,
    this.category,
    this.brand,
    this.imageUrl,
    this.ingredients,
    this.nutritionFacts,
    this.errorMessage,
  });

  /// Creates a successful result with product data
  factory ProductLookupResult.success({
    required String name,
    String? category,
    String? brand,
    String? imageUrl,
    String? ingredients,
    Map<String, dynamic>? nutritionFacts,
  }) {
    return ProductLookupResult(
      found: true,
      name: name,
      category: category,
      brand: brand,
      imageUrl: imageUrl,
      ingredients: ingredients,
      nutritionFacts: nutritionFacts,
    );
  }

  /// Creates a result for when product is not found
  factory ProductLookupResult.notFound() {
    return const ProductLookupResult(found: false);
  }

  /// Creates a result for when an error occurred
  factory ProductLookupResult.error(String message) {
    return ProductLookupResult(found: false, errorMessage: message);
  }

  /// Converts the API result to a PantryItem with default values
  PantryItem toPantryItem({
    required String barcode,
    double quantity = 1.0,
    String unit = 'pieces',
    String? notes,
  }) {
    final now = DateTime.now();
    return PantryItem(
      id: now.millisecondsSinceEpoch.toString(),
      name: name ?? 'Unknown Product',
      quantity: quantity,
      unit: unit,
      category: _mapToAppCategory(category),
      barcode: barcode,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Maps external API categories to our app categories
  String _mapToAppCategory(String? externalCategory) {
    if (externalCategory == null) return 'Other';

    final category = externalCategory.toLowerCase();

    // Map common Open Food Facts categories to our app categories
    if (category.contains('snack') ||
        category.contains('chip') ||
        category.contains('cookie')) {
      return 'Snacks';
    } else if (category.contains('beverage') ||
        category.contains('drink') ||
        category.contains('juice')) {
      return 'Beverages';
    } else if (category.contains('dairy') ||
        category.contains('milk') ||
        category.contains('cheese')) {
      return 'Dairy';
    } else if (category.contains('meat') ||
        category.contains('chicken') ||
        category.contains('beef')) {
      return 'Meat';
    } else if (category.contains('fruit') ||
        category.contains('vegetable') ||
        category.contains('produce')) {
      return 'Produce';
    } else if (category.contains('grain') ||
        category.contains('bread') ||
        category.contains('cereal')) {
      return 'Grains';
    } else if (category.contains('condiment') ||
        category.contains('sauce') ||
        category.contains('spice')) {
      return 'Condiments';
    } else if (category.contains('frozen')) {
      return 'Frozen Foods';
    } else if (category.contains('canned') || category.contains('preserved')) {
      return 'Canned Goods';
    }

    return 'Other';
  }
}

/// Abstract interface for product API services
abstract class ProductApiService {
  /// Looks up product information by barcode
  /// Returns a [ProductLookupResult] with product data or error information
  Future<ProductLookupResult> lookupProduct(String barcode);

  /// Gets the service name for identification
  String get serviceName;

  /// Checks if the service is available/configured
  Future<bool> isAvailable();
}
