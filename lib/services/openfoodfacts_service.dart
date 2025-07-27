import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pantryready/models/product_api_result.dart';
import 'package:pantryready/services/product_api_service.dart';

/// Implementation of ProductApiService using Open Food Facts API
/// Uses direct HTTP calls to the Open Food Facts API v2
class OpenFoodFactsService implements ProductApiService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v0/product';

  @override
  Future<ProductApiResult> lookupProduct(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseProductData(data, barcode);
      } else {
        return ProductApiResult.error(
          'HTTP Error: ${response.statusCode}',
          barcode: barcode,
        );
      }
    } catch (e) {
      return ProductApiResult.error(
        'Network error: ${e.toString()}',
        barcode: barcode,
      );
    }
  }

  ProductApiResult _parseProductData(
    Map<String, dynamic> data,
    String barcode,
  ) {
    final status = data['status'];

    if (status != 1) {
      return ProductApiResult.notFound(barcode: barcode);
    }

    final product = data['product'];
    if (product == null) {
      return ProductApiResult.notFound(barcode: barcode);
    }

    final name = _extractName(product);
    final category = _extractCategory(product);
    final brand = _extractBrand(product);
    final imageUrl = _extractImageUrl(product);
    final ingredients = _extractIngredients(product);
    final nutritionFacts = _extractNutritionFacts(product);

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

  String? _extractName(Map<String, dynamic> product) {
    // Try multiple possible name fields
    return product['product_name'] ??
        product['generic_name'] ??
        product['product_name_en'] ??
        product['generic_name_en'];
  }

  String? _extractCategory(Map<String, dynamic> product) {
    // Try multiple possible category fields
    final categories = product['categories'];
    if (categories != null) return categories.toString();

    final categoriesTags = product['categories_tags'] as List<dynamic>?;
    if (categoriesTags != null && categoriesTags.isNotEmpty) {
      final firstTag = categoriesTags.first.toString();
      if (firstTag.contains(':')) {
        return firstTag.split(':').last;
      }
    }

    final productCategory = product['product_category'];
    if (productCategory != null) return productCategory.toString();

    final mainCategory = product['main_category'];
    if (mainCategory != null) return mainCategory.toString();

    return null;
  }

  String? _extractBrand(Map<String, dynamic> product) {
    final brands = product['brands'];
    if (brands != null) return brands.toString();

    final brandOwner = product['brand_owner'];
    if (brandOwner != null) return brandOwner.toString();

    final brandsTags = product['brands_tags'] as List<dynamic>?;
    if (brandsTags != null && brandsTags.isNotEmpty) {
      final firstTag = brandsTags.first.toString();
      if (firstTag.contains(':')) {
        return firstTag.split(':').last;
      }
    }

    return null;
  }

  String? _extractImageUrl(Map<String, dynamic> product) {
    return product['image_front_url'] ??
        product['image_url'] ??
        product['image_small_url'];
  }

  String? _extractIngredients(Map<String, dynamic> product) {
    return product['ingredients_text'] ??
        product['ingredients_text_en'] ??
        product['ingredients'];
  }

  Map<String, dynamic>? _extractNutritionFacts(Map<String, dynamic> product) {
    final nutriments = product['nutriments'];
    if (nutriments == null) return null;

    final nutritionFacts = <String, dynamic>{};

    // Extract common nutrition facts
    final commonNutrients = [
      'energy-kcal_100g',
      'proteins_100g',
      'carbohydrates_100g',
      'fat_100g',
      'fiber_100g',
      'sodium_100g',
      'sugars_100g',
    ];

    for (final nutrient in commonNutrients) {
      final value = nutriments[nutrient];
      if (value != null) {
        nutritionFacts[nutrient] = value;
      }
    }

    return nutritionFacts.isNotEmpty ? nutritionFacts : null;
  }
}
