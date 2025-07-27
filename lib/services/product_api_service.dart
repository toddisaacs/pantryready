import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/models/product_api_result.dart';

abstract class ProductApiService {
  Future<ProductApiResult> lookupProduct(String barcode);
}

class MockProductApiService implements ProductApiService {
  @override
  Future<ProductApiResult> lookupProduct(String barcode) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data based on barcode
    switch (barcode) {
      case '1234567890123':
        return ProductApiResult(
          found: true,
          name: 'Canned Beans',
          brand: 'Generic Brand',
          category: 'Canned Goods',
          barcode: barcode,
        );
      case '2345678901234':
        return ProductApiResult(
          found: true,
          name: 'Rice',
          brand: 'Generic Brand',
          category: 'Grains',
          barcode: barcode,
        );
      case '3456789012345':
        return ProductApiResult(
          found: true,
          name: 'Bottled Water',
          brand: 'Generic Brand',
          category: 'Beverages',
          barcode: barcode,
        );
      case '4567890123456':
        return ProductApiResult(
          found: true,
          name: 'Pasta',
          brand: 'Generic Brand',
          category: 'Grains',
          barcode: barcode,
        );
      case '5678901234567':
        return ProductApiResult(
          found: true,
          name: 'Peanut Butter',
          brand: 'Generic Brand',
          category: 'Condiments',
          barcode: barcode,
        );
      case '6789012345678':
        return ProductApiResult(
          found: true,
          name: 'Pinto Beans',
          brand: 'Generic Brand',
          category: 'Grains',
          barcode: barcode,
        );
      case '7890123456789':
        return ProductApiResult(
          found: true,
          name: 'Canned Tomatoes',
          brand: 'Generic Brand',
          category: 'Canned Goods',
          barcode: barcode,
        );
      case '8901234567890':
        return ProductApiResult(
          found: true,
          name: 'Olive Oil',
          brand: 'Generic Brand',
          category: 'Condiments',
          barcode: barcode,
        );
      default:
        return ProductApiResult(
          found: false,
          errorMessage: 'Product not found',
          barcode: barcode,
        );
    }
  }

  // Helper method to create a PantryItem from API result
  PantryItem createPantryItemFromApiResult(ProductApiResult result) {
    // Map external category to system category
    SystemCategory systemCategory = _mapToSystemCategory(result.category ?? '');

    // Create initial batch
    final initialBatch = ItemBatch(
      quantity: 1.0,
      purchaseDate: DateTime.now(),
      costPerUnit: null,
      notes: 'Added via barcode scan',
    );

    return PantryItem(
      name: result.name ?? 'Unknown Product',
      unit: 'units',
      systemCategory: systemCategory,
      subcategory: result.category,
      batches: [initialBatch],
      barcode: result.barcode,
      notes: result.brand != null ? 'Brand: ${result.brand}' : null,
      // Set reasonable defaults for survival/preparedness fields
      dailyConsumptionRate: _getDefaultConsumptionRate(systemCategory),
      minStockLevel: 1.0,
      maxStockLevel: 10.0,
      isEssential:
          systemCategory == SystemCategory.water ||
          systemCategory == SystemCategory.medical,
      applicableScenarios: _getDefaultScenarios(systemCategory),
    );
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
}
