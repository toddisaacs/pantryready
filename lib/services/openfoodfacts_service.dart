import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pantryready/services/product_api_service.dart';

/// Implementation of ProductApiService using Open Food Facts API
/// Uses direct HTTP calls to the Open Food Facts API v2
class OpenFoodFactsService implements ProductApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';
  static const String _userAgent = 'PantryReady/1.0 (pantryready@example.com)';

  final http.Client _httpClient;

  OpenFoodFactsService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  @override
  String get serviceName => 'Open Food Facts';

  @override
  Future<bool> isAvailable() async {
    try {
      // Try a simple API call to check availability
      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/api/v2/product/3274080005003.json'),
            headers: {'User-Agent': _userAgent},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ProductLookupResult> lookupProduct(String barcode) async {
    try {
      // Validate barcode format
      if (barcode.isEmpty || !_isValidBarcode(barcode)) {
        return ProductLookupResult.error('Invalid barcode format');
      }

      // Make the API call
      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/api/v2/product/$barcode.json'),
            headers: {'User-Agent': _userAgent},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return ProductLookupResult.error(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 1 && data['product'] != null) {
        return _mapProductToResult(data['product'] as Map<String, dynamic>);
      } else if (data['status'] == 0) {
        return ProductLookupResult.notFound();
      } else {
        return ProductLookupResult.error(
          'Product lookup failed: status ${data['status']}',
        );
      }
    } catch (e) {
      // Handle network errors, parsing errors, etc.
      return ProductLookupResult.error('Network error: ${e.toString()}');
    }
  }

  /// Maps Open Food Facts Product JSON to our ProductLookupResult
  ProductLookupResult _mapProductToResult(Map<String, dynamic> product) {
    try {
      // Extract basic information
      final name = product['product_name']?.toString().trim();
      final brand = product['brands']?.toString().trim();
      final category = _extractMainCategory(
        product['categories_tags'] as List<dynamic>?,
      );
      final ingredients = product['ingredients_text']?.toString().trim();
      final imageUrl = product['image_front_url']?.toString();

      // Extract nutrition facts if available
      Map<String, dynamic>? nutritionFacts;
      if (product['nutriments'] != null) {
        nutritionFacts = _extractNutritionFacts(
          product['nutriments'] as Map<String, dynamic>,
        );
      }

      // Ensure we have at least a name
      if (name == null || name.isEmpty) {
        return ProductLookupResult.error(
          'Product found but missing essential data',
        );
      }

      return ProductLookupResult.success(
        name: _formatProductName(name, brand),
        category: category,
        brand: brand,
        imageUrl: imageUrl,
        ingredients: ingredients,
        nutritionFacts: nutritionFacts,
      );
    } catch (e) {
      return ProductLookupResult.error(
        'Error processing product data: ${e.toString()}',
      );
    }
  }

  /// Formats the product name, optionally including brand
  String _formatProductName(String name, String? brand) {
    if (brand != null &&
        brand.isNotEmpty &&
        !name.toLowerCase().contains(brand.toLowerCase())) {
      return '$brand $name';
    }
    return name;
  }

  /// Extracts the main category from Open Food Facts categories
  String? _extractMainCategory(List<dynamic>? categoriesTags) {
    if (categoriesTags == null || categoriesTags.isEmpty) return null;

    // Open Food Facts categories are in format "en:category-name"
    // Find the most specific category (usually the last one)
    for (final tag in categoriesTags.reversed) {
      final tagStr = tag.toString();
      if (tagStr.startsWith('en:')) {
        final category = tagStr.substring(3).replaceAll('-', ' ');
        return _capitalizeWords(category);
      }
    }
    return null;
  }

  /// Extracts relevant nutrition facts from Open Food Facts nutriments
  Map<String, dynamic> _extractNutritionFacts(Map<String, dynamic> nutriments) {
    final facts = <String, dynamic>{};

    // Extract common nutrition values
    final energyKcal = nutriments['energy-kcal_100g'];
    if (energyKcal != null) {
      facts['calories_per_100g'] = _parseDouble(energyKcal);
    }

    final proteins = nutriments['proteins_100g'];
    if (proteins != null) {
      facts['protein_per_100g'] = _parseDouble(proteins);
    }

    final carbs = nutriments['carbohydrates_100g'];
    if (carbs != null) {
      facts['carbs_per_100g'] = _parseDouble(carbs);
    }

    final fat = nutriments['fat_100g'];
    if (fat != null) {
      facts['fat_per_100g'] = _parseDouble(fat);
    }

    final fiber = nutriments['fiber_100g'];
    if (fiber != null) {
      facts['fiber_per_100g'] = _parseDouble(fiber);
    }

    final sugars = nutriments['sugars_100g'];
    if (sugars != null) {
      facts['sugar_per_100g'] = _parseDouble(sugars);
    }

    final salt = nutriments['salt_100g'];
    if (salt != null) {
      facts['salt_per_100g'] = _parseDouble(salt);
    }

    return facts;
  }

  /// Safely parses a value to double
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Basic barcode validation
  bool _isValidBarcode(String barcode) {
    // Remove any whitespace
    barcode = barcode.trim();

    // Check if it's numeric and has valid length
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;

    // Common barcode lengths: UPC (12), EAN-13 (13), EAN-8 (8)
    final length = barcode.length;
    return length == 8 || length == 12 || length == 13 || length == 14;
  }

  /// Capitalizes each word in a string
  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Dispose method to clean up resources
  void dispose() {
    _httpClient.close();
  }
}
