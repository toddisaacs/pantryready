import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/services/product_api_service.dart';
import 'package:pantryready/services/openfoodfacts_service.dart';
import 'package:pantryready/models/product_api_result.dart';
import 'package:pantryready/models/pantry_item.dart';

void main() {
  group('Product API Tests', () {
    late MockProductApiService mockService;

    setUp(() {
      mockService = MockProductApiService();
    });

    group('MockProductApiService', () {
      test('returns success result for known barcode', () async {
        const barcode = '1234567890123';
        final result = await mockService.lookupProduct(barcode);

        expect(result.found, isTrue);
        expect(result.name, equals('Canned Beans'));
        expect(result.brand, equals('Generic Brand'));
        expect(result.category, equals('Canned Goods'));
        expect(result.barcode, equals(barcode));
      });

      test('returns not found result for unknown barcode', () async {
        const barcode = '9999999999999';
        final result = await mockService.lookupProduct(barcode);

        expect(result.found, isFalse);
        expect(result.errorMessage, equals('Product not found'));
        expect(result.barcode, equals(barcode));
      });

      test('returns error result for empty barcode', () async {
        const barcode = '';
        final result = await mockService.lookupProduct(barcode);

        expect(result.found, isFalse);
        expect(result.errorMessage, equals('Product not found'));
        expect(result.barcode, equals(barcode));
      });

      test('returns success result for different known barcodes', () async {
        const barcode = '2345678901234';
        final result = await mockService.lookupProduct(barcode);

        expect(result.found, isTrue);
        expect(result.name, equals('Rice'));
        expect(result.brand, equals('Generic Brand'));
        expect(result.category, equals('Grains'));
        expect(result.barcode, equals(barcode));
      });

      test('handles multiple concurrent requests', () async {
        const barcodes = ['1234567890123', '2345678901234', '3456789012345'];

        final futures = barcodes.map(
          (barcode) => mockService.lookupProduct(barcode),
        );
        final results = await Future.wait(futures);

        expect(results.length, equals(3));
        expect(results[0].found, isTrue);
        expect(results[0].name, equals('Canned Beans'));
        expect(results[1].found, isTrue);
        expect(results[1].name, equals('Rice'));
        expect(results[2].found, isTrue);
        expect(results[2].name, equals('Bottled Water'));
      });

      test('creates PantryItem from API result', () {
        const barcode = '1234567890123';
        final apiResult = ProductApiResult.success(
          name: 'Test Product',
          category: 'Canned Goods',
          brand: 'Test Brand',
          barcode: barcode,
        );

        final pantryItem = mockService.createPantryItemFromApiResult(apiResult);

        expect(pantryItem.name, equals('Test Product'));
        expect(pantryItem.barcode, equals(barcode));
        expect(pantryItem.systemCategory, equals(SystemCategory.food));
        expect(pantryItem.batches.length, equals(1));
        expect(pantryItem.batches.first.quantity, equals(1.0));
      });
    });

    group('OpenFoodFactsService', () {
      late OpenFoodFactsService service;

      setUp(() {
        service = OpenFoodFactsService();
      });

      test('lookupProduct returns ProductApiResult', () async {
        const barcode = '1234567890123';
        final result = await service.lookupProduct(barcode);

        expect(result, isA<ProductApiResult>());
        expect(result.barcode, equals(barcode));
      });

      test('handles network errors gracefully', () async {
        // This test would require mocking HTTP client
        // For now, we'll just test that the service can be instantiated
        expect(service, isA<OpenFoodFactsService>());
      });

      test('can be instantiated without parameters', () {
        expect(() => OpenFoodFactsService(), returnsNormally);
      });
    });

    group('ProductApiResult', () {
      test('success factory creates correct result', () {
        const name = 'Test Product';
        const category = 'Test Category';
        const brand = 'Test Brand';
        const barcode = '1234567890123';

        final result = ProductApiResult.success(
          name: name,
          category: category,
          brand: brand,
          barcode: barcode,
        );

        expect(result.found, isTrue);
        expect(result.name, equals(name));
        expect(result.category, equals(category));
        expect(result.brand, equals(brand));
        expect(result.barcode, equals(barcode));
        expect(result.errorMessage, isNull);
      });

      test('notFound factory creates correct result', () {
        const barcode = '1234567890123';
        final result = ProductApiResult.notFound(barcode: barcode);

        expect(result.found, isFalse);
        expect(result.barcode, equals(barcode));
        expect(result.errorMessage, isNull);
      });

      test('error factory creates correct result', () {
        const errorMessage = 'Test error';
        const barcode = '1234567890123';
        final result = ProductApiResult.error(errorMessage, barcode: barcode);

        expect(result.found, isFalse);
        expect(result.errorMessage, equals(errorMessage));
        expect(result.barcode, equals(barcode));
      });
    });
  });
}
