import 'package:pantryready/models/product_api_result.dart';
import 'package:pantryready/services/product_api_service.dart';

/// Mock implementation of ProductApiService for testing and development
class MockProductApiService implements ProductApiService {
  final bool simulateErrors;

  MockProductApiService({this.simulateErrors = false});

  @override
  Future<ProductApiResult> lookupProduct(String barcode) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (simulateErrors) {
      return ProductApiResult.error(
        'Simulated network error',
        barcode: barcode,
      );
    }

    // Validate barcode format
    if (barcode.isEmpty || !_isValidBarcode(barcode)) {
      return ProductApiResult.error('Invalid barcode format', barcode: barcode);
    }

    // Mock data based on barcode
    switch (barcode) {
      case '1234567890123':
        return ProductApiResult.notFound(barcode: barcode);
      case '2345678901234':
        return ProductApiResult.success(
          name: 'Rice',
          category: 'Grains',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      case '3456789012345':
        return ProductApiResult.success(
          name: 'Bottled Water',
          category: 'Beverages',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      case '4567890123456':
        return ProductApiResult.success(
          name: 'Pasta',
          category: 'Grains',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      case '5678901234567':
        return ProductApiResult.success(
          name: 'Peanut Butter',
          category: 'Condiments',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      case '6789012345678':
        return ProductApiResult.success(
          name: 'Pinto Beans',
          category: 'Grains',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      case '7890123456789':
        return ProductApiResult.success(
          name: 'Canned Tomatoes',
          category: 'Canned Goods',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      case '8901234567890':
        return ProductApiResult.success(
          name: 'Olive Oil',
          category: 'Condiments',
          brand: 'Generic Brand',
          barcode: barcode,
        );
      default:
        return ProductApiResult.error(
          'Product not found in mock database',
          barcode: barcode,
        );
    }
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
}
