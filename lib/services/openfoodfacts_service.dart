import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      debugPrint('[OFF] Requesting: $url');
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'PantryReady/2.0 (Flutter; pantryready-app)',
            },
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('[OFF] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseProductData(data, barcode);
      } else if (response.statusCode == 429) {
        debugPrint('[OFF] Rate limited (429) for barcode $barcode');
        return ProductApiResult.error(
          'Rate limited — wait a moment and try again',
          barcode: barcode,
        );
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
    // Try English/generic fields first, then any localized product_name_* field
    final direct =
        product['product_name'] ??
        product['product_name_en'] ??
        product['generic_name'] ??
        product['generic_name_en'] ??
        product['abbreviated_product_name'];
    if (direct != null) return direct.toString();

    // Fall back to any non-empty product_name_* locale field
    for (final key in product.keys) {
      if (key.startsWith('product_name_') && product[key] != null) {
        final value = product[key].toString().trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  String? _extractCategory(Map<String, dynamic> product) {
    // Most-specific structured tag (last = most specific in OFF taxonomy)
    final tags = product['categories_tags'] as List<dynamic>?;
    if (tags != null && tags.isNotEmpty) {
      final lastTag = tags.last.toString();
      final extracted =
          lastTag.contains(':') ? lastTag.split(':').last : lastTag;
      debugPrint('[OFF] category_tag (last): $extracted');
      return extracted;
    }

    // Free-text fallback — last comma-token is most specific
    final categories = product['categories'];
    if (categories != null) {
      final parts = categories.toString().split(',');
      final extracted = parts.last.trim();
      debugPrint('[OFF] category (free-text fallback): $extracted');
      return extracted;
    }

    return product['product_category']?.toString() ??
        product['main_category']?.toString();
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
