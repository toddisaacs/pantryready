/// Result of a product lookup operation
class ProductApiResult {
  final bool found;
  final String? name;
  final String? category;
  final String? brand;
  final String? imageUrl;
  final String? ingredients;
  final Map<String, dynamic>? nutritionFacts;
  final String? errorMessage;
  final String? barcode;

  const ProductApiResult({
    required this.found,
    this.name,
    this.category,
    this.brand,
    this.imageUrl,
    this.ingredients,
    this.nutritionFacts,
    this.errorMessage,
    this.barcode,
  });

  /// Creates a successful result with product data
  factory ProductApiResult.success({
    required String name,
    String? category,
    String? brand,
    String? imageUrl,
    String? ingredients,
    Map<String, dynamic>? nutritionFacts,
    String? barcode,
  }) {
    return ProductApiResult(
      found: true,
      name: name,
      category: category,
      brand: brand,
      imageUrl: imageUrl,
      ingredients: ingredients,
      nutritionFacts: nutritionFacts,
      barcode: barcode,
    );
  }

  /// Creates a result for when product is not found
  factory ProductApiResult.notFound({String? barcode}) {
    return ProductApiResult(found: false, barcode: barcode);
  }

  /// Creates a result for when an error occurred
  factory ProductApiResult.error(String message, {String? barcode}) {
    return ProductApiResult(
      found: false,
      errorMessage: message,
      barcode: barcode,
    );
  }
}
