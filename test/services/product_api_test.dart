import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:pantryready/services/product_api_service.dart';
import 'package:pantryready/services/mock_product_api_service.dart';
import 'package:pantryready/services/openfoodfacts_service.dart';

void main() {
  group('ProductLookupResult Tests', () {
    test('creates successful result with product data', () {
      final result = ProductLookupResult.success(
        name: 'Test Product',
        brand: 'Test Brand',
        category: 'Test Category',
        ingredients: 'Test ingredients',
        nutritionFacts: {'calories_per_100g': 100.0},
      );

      expect(result.found, true);
      expect(result.name, 'Test Product');
      expect(result.brand, 'Test Brand');
      expect(result.category, 'Test Category');
      expect(result.ingredients, 'Test ingredients');
      expect(result.nutritionFacts, {'calories_per_100g': 100.0});
      expect(result.errorMessage, null);
    });

    test('creates not found result', () {
      final result = ProductLookupResult.notFound();

      expect(result.found, false);
      expect(result.name, null);
      expect(result.errorMessage, null);
    });

    test('creates error result', () {
      final result = ProductLookupResult.error('Test error');

      expect(result.found, false);
      expect(result.errorMessage, 'Test error');
    });

    test('converts to PantryItem correctly', () {
      final result = ProductLookupResult.success(
        name: 'Test Product',
        category: 'snacks',
      );

      final item = result.toPantryItem(
        barcode: '1234567890123',
        quantity: 2.0,
        unit: 'pieces',
        notes: 'Test notes',
      );

      expect(item.name, 'Test Product');
      expect(item.category, 'Snacks'); // Should be mapped
      expect(item.barcode, '1234567890123');
      expect(item.quantity, 2.0);
      expect(item.unit, 'pieces');
      expect(item.notes, 'Test notes');
    });

    test('maps external categories to app categories', () {
      final testCases = {
        'snacks': 'Snacks',
        'beverages': 'Beverages',
        'dairy': 'Dairy',
        'meat': 'Meat',
        'fruits': 'Produce',
        'grains': 'Grains',
        'condiments': 'Condiments',
        'frozen': 'Frozen Foods',
        'canned': 'Canned Goods',
        'unknown': 'Other',
        null: 'Other',
      };

      testCases.forEach((input, expected) {
        final result = ProductLookupResult.success(
          name: 'Test',
          category: input,
        );
        final item = result.toPantryItem(barcode: '123');
        expect(item.category, expected, reason: 'Failed for input: $input');
      });
    });
  });

  group('MockProductApiService Tests', () {
    late MockProductApiService mockService;

    setUp(() {
      mockService = MockProductApiService(
        networkDelay: const Duration(milliseconds: 10), // Faster for tests
        simulateErrors: false,
      );
    });

    test('service name is correct', () {
      expect(mockService.serviceName, 'Mock Product API');
    });

    test('isAvailable returns true when not simulating errors', () async {
      final isAvailable = await mockService.isAvailable();
      expect(isAvailable, true);
    });

    test('isAvailable returns false when simulating errors', () async {
      final errorService = MockProductApiService(simulateErrors: true);
      final isAvailable = await errorService.isAvailable();
      expect(isAvailable, false);
    });

    test('lookupProduct returns success for known barcode', () async {
      final result = await mockService.lookupProduct('3274080005003');

      expect(result.found, true);
      expect(result.name, 'Nutella');
      expect(result.brand, 'Ferrero');
      expect(result.category, 'Spreads');
      expect(result.ingredients, contains('Sugar'));
      expect(result.nutritionFacts, isNotNull);
      expect(result.nutritionFacts!['calories_per_100g'], 539.0);
    });

    test('lookupProduct returns not found for unknown barcode', () async {
      final result = await mockService.lookupProduct('0000000000000');

      expect(result.found, false);
      expect(result.errorMessage, null);
    });

    test('lookupProduct validates barcode format', () async {
      final result = await mockService.lookupProduct('invalid');

      expect(result.found, false);
      expect(result.errorMessage, 'Invalid barcode format');
    });

    test('addMockProduct and removeMockProduct work correctly', () async {
      const testBarcode = '1111111111111';
      const testProduct = {
        'name': 'Test Product',
        'brand': 'Test Brand',
        'category': 'Test Category',
      };

      // Add mock product
      mockService.addMockProduct(testBarcode, testProduct);

      // Should find the product
      final result = await mockService.lookupProduct(testBarcode);
      expect(result.found, true);
      expect(result.name, 'Test Product');

      // Remove mock product
      mockService.removeMockProduct(testBarcode);

      // Should not find the product
      final result2 = await mockService.lookupProduct(testBarcode);
      expect(result2.found, false);
    });

    test('getMockBarcodes returns available barcodes', () {
      final barcodes = mockService.getMockBarcodes();
      expect(barcodes, contains('3274080005003')); // Nutella
      expect(barcodes, contains('1234567890123')); // Organic Bananas
    });

    test('clearMockData removes all products', () async {
      mockService.clearMockData();

      final result = await mockService.lookupProduct('3274080005003');
      expect(result.found, false);

      final barcodes = mockService.getMockBarcodes();
      expect(barcodes, isEmpty);
    });
  });

  group('OpenFoodFactsService Tests', () {
    late OpenFoodFactsService service;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient((request) async {
        // Default response for unhandled requests
        return http.Response('Not Found', 404);
      });
      service = OpenFoodFactsService(httpClient: mockHttpClient);
    });

    tearDown(() {
      service.dispose();
    });

    test('service name is correct', () {
      expect(service.serviceName, 'Open Food Facts');
    });

    test('isAvailable returns true for successful API response', () async {
      mockHttpClient = MockClient((request) async {
        if (request.url.path.contains('/api/v2/product/3274080005003.json')) {
          return http.Response('{"status": 1}', 200);
        }
        return http.Response('Not Found', 404);
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final isAvailable = await service.isAvailable();
      expect(isAvailable, true);
      service.dispose();
    });

    test('isAvailable returns false for failed API response', () async {
      mockHttpClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final isAvailable = await service.isAvailable();
      expect(isAvailable, false);
      service.dispose();
    });

    test('lookupProduct returns success for valid product', () async {
      const mockResponse = {
        'status': 1,
        'product': {
          'product_name': 'Test Product',
          'brands': 'Test Brand',
          'categories_tags': ['en:snacks', 'en:cookies'],
          'ingredients_text': 'flour, sugar, butter',
          'image_front_url': 'https://example.com/image.jpg',
          'nutriments': {
            'energy-kcal_100g': 450.0,
            'proteins_100g': 6.0,
            'carbohydrates_100g': 65.0,
            'fat_100g': 18.0,
            'sugars_100g': 25.0,
            'salt_100g': 0.5,
          },
        },
      };

      mockHttpClient = MockClient((request) async {
        if (request.url.path.contains('/api/v2/product/1234567890123.json')) {
          return http.Response(json.encode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final result = await service.lookupProduct('1234567890123');

      expect(result.found, true);
      expect(result.name, 'Test Brand Test Product');
      expect(result.brand, 'Test Brand');
      expect(result.category, 'Cookies');
      expect(result.ingredients, 'flour, sugar, butter');
      expect(result.imageUrl, 'https://example.com/image.jpg');
      expect(result.nutritionFacts!['calories_per_100g'], 450.0);
      expect(result.nutritionFacts!['protein_per_100g'], 6.0);

      service.dispose();
    });

    test('lookupProduct returns not found for unknown product', () async {
      const mockResponse = {'status': 0};

      mockHttpClient = MockClient((request) async {
        return http.Response(json.encode(mockResponse), 200);
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final result = await service.lookupProduct('0000000000000');

      expect(result.found, false);
      expect(result.errorMessage, null);

      service.dispose();
    });

    test('lookupProduct returns error for invalid barcode', () async {
      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final result = await service.lookupProduct('invalid');

      expect(result.found, false);
      expect(result.errorMessage, 'Invalid barcode format');

      service.dispose();
    });

    test('lookupProduct returns error for HTTP error', () async {
      mockHttpClient = MockClient((request) async {
        return http.Response(
          'Server Error',
          500,
          reasonPhrase: 'Internal Server Error',
        );
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final result = await service.lookupProduct('1234567890123');

      expect(result.found, false);
      expect(result.errorMessage, contains('HTTP 500'));

      service.dispose();
    });

    test('lookupProduct handles missing essential data', () async {
      const mockResponse = {
        'status': 1,
        'product': {
          'brands': 'Test Brand',
          // Missing product_name
        },
      };

      mockHttpClient = MockClient((request) async {
        return http.Response(json.encode(mockResponse), 200);
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      final result = await service.lookupProduct('1234567890123');

      expect(result.found, false);
      expect(result.errorMessage, contains('missing essential data'));

      service.dispose();
    });

    test('uses correct User-Agent header', () async {
      String? userAgent;

      mockHttpClient = MockClient((request) async {
        userAgent = request.headers['User-Agent'];
        return http.Response('{"status": 1}', 200);
      });

      service = OpenFoodFactsService(httpClient: mockHttpClient);
      await service.isAvailable();

      expect(userAgent, 'PantryReady/1.0 (pantryready@example.com)');

      service.dispose();
    });
  });

  group('Integration Tests', () {
    test('ProductLookupResult toPantryItem creates valid PantryItem', () {
      final result = ProductLookupResult.success(
        name: 'Farm Fresh Organic Apples', // Already formatted name
        brand: 'Farm Fresh',
        category: 'fruit',
        ingredients: 'Organic apples',
        nutritionFacts: {
          'calories_per_100g': 52.0,
          'carbs_per_100g': 14.0,
          'fiber_per_100g': 2.4,
        },
      );

      final item = result.toPantryItem(
        barcode: '1234567890123',
        quantity: 1.5,
        unit: 'kg',
        notes: 'Fresh from local farm',
      );

      expect(item.name, 'Farm Fresh Organic Apples');
      expect(item.category, 'Produce');
      expect(item.barcode, '1234567890123');
      expect(item.quantity, 1.5);
      expect(item.unit, 'kg');
      expect(item.notes, 'Fresh from local farm');
      expect(item.createdAt, isA<DateTime>());
      expect(item.updatedAt, isA<DateTime>());
      expect(item.id, isNotEmpty);
    });

    test('Services implement ProductApiService interface correctly', () {
      final mockService = MockProductApiService();
      final openFoodFactsService = OpenFoodFactsService();

      expect(mockService, isA<ProductApiService>());
      expect(openFoodFactsService, isA<ProductApiService>());

      expect(mockService.serviceName, isA<String>());
      expect(openFoodFactsService.serviceName, isA<String>());

      openFoodFactsService.dispose();
    });
  });
}
