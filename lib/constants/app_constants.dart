import 'package:flutter/material.dart';
import 'package:pantryready/models/pantry_item.dart';

class AppConstants {
  static const Color primaryColor = Colors.green;
  static const Color accentColor = Colors.blue;
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color successColor = Color(0xFF28A745);

  // Legacy categories for backward compatibility
  static const List<String> categories = [
    'Canned Goods',
    'Grains',
    'Beverages',
    'Condiments',
    'Snacks',
    'Frozen Foods',
    'Dairy',
    'Produce',
    'Meat',
    'Other',
  ];

  // Enhanced units for survival/preparedness items
  static const List<String> units = [
    'pieces',
    'cans',
    'boxes',
    'bottles',
    'lbs',
    'oz',
    'kg',
    'g',
    'packs',
    'jars',
    'liters',
    'gallons',
    'rolls',
    'pairs',
    'sets',
    'kits',
  ];

  // Sample data for the enhanced PantryItem model
  static final List<PantryItem> samplePantryItems = [
    // Water - Essential for survival
    PantryItem(
      id: '1',
      name: 'Bottled Water',
      unit: 'liters',
      systemCategory: SystemCategory.water,
      subcategory: 'Drinking Water',
      batches: [
        ItemBatch(
          quantity: 24.0, // 24 liters
          purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
          expiryDate: DateTime.now().add(const Duration(days: 730)), // 2 years
          costPerUnit: 0.50, // $0.50 per liter
        ),
      ],
      dailyConsumptionRate: 3.0, // 3 liters per person per day
      minStockLevel: 30.0, // 30 liters minimum
      maxStockLevel: 100.0, // 100 liters maximum
      isEssential: true,
      applicableScenarios: [
        SurvivalScenario.powerOutage,
        SurvivalScenario.winterStorm,
        SurvivalScenario.hurricane,
        SurvivalScenario.isolation,
      ],
    ),

    // Food - Canned goods
    PantryItem(
      id: '2',
      name: 'Canned Beans',
      unit: 'cans',
      systemCategory: SystemCategory.food,
      subcategory: 'Canned Goods',
      batches: [
        ItemBatch(
          quantity: 12.0,
          purchaseDate: DateTime.now().subtract(const Duration(days: 15)),
          expiryDate: DateTime.now().add(const Duration(days: 1095)), // 3 years
          costPerUnit: 1.25,
        ),
      ],
      dailyConsumptionRate: 0.5, // 0.5 cans per person per day
      minStockLevel: 14.0, // 2 weeks worth
      maxStockLevel: 42.0, // 6 weeks worth
      isEssential: true,
      applicableScenarios: [
        SurvivalScenario.powerOutage,
        SurvivalScenario.winterStorm,
        SurvivalScenario.hurricane,
        SurvivalScenario.isolation,
      ],
    ),

    // Medical - First aid
    PantryItem(
      id: '3',
      name: 'First Aid Kit',
      unit: 'kits',
      systemCategory: SystemCategory.medical,
      subcategory: 'First Aid',
      batches: [
        ItemBatch(
          quantity: 2.0,
          purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
          expiryDate: DateTime.now().add(const Duration(days: 1825)), // 5 years
          costPerUnit: 25.00,
        ),
      ],
      dailyConsumptionRate: 0.01, // Very low consumption rate
      minStockLevel: 1.0,
      maxStockLevel: 3.0,
      isEssential: true,
      applicableScenarios: [
        SurvivalScenario.powerOutage,
        SurvivalScenario.winterStorm,
        SurvivalScenario.hurricane,
        SurvivalScenario.earthquake,
        SurvivalScenario.pandemic,
      ],
    ),

    // Hygiene - Personal care
    PantryItem(
      id: '4',
      name: 'Toilet Paper',
      unit: 'rolls',
      systemCategory: SystemCategory.hygiene,
      subcategory: 'Personal Care',
      batches: [
        ItemBatch(
          quantity: 24.0,
          purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
          expiryDate: null, // No expiry
          costPerUnit: 0.75,
        ),
      ],
      dailyConsumptionRate: 0.5, // 0.5 rolls per person per day
      minStockLevel: 14.0, // 2 weeks worth
      maxStockLevel: 60.0, // 2 months worth
      isEssential: false,
      applicableScenarios: [
        SurvivalScenario.powerOutage,
        SurvivalScenario.winterStorm,
        SurvivalScenario.hurricane,
        SurvivalScenario.pandemic,
      ],
    ),

    // Tools - Flashlight
    PantryItem(
      id: '5',
      name: 'LED Flashlight',
      unit: 'pieces',
      systemCategory: SystemCategory.lighting,
      subcategory: 'Illumination',
      batches: [
        ItemBatch(
          quantity: 3.0,
          purchaseDate: DateTime.now().subtract(const Duration(days: 45)),
          expiryDate: null, // No expiry
          costPerUnit: 15.00,
        ),
      ],
      dailyConsumptionRate: 0.0, // Not consumed daily
      minStockLevel: 2.0,
      maxStockLevel: 5.0,
      isEssential: true,
      applicableScenarios: [
        SurvivalScenario.powerOutage,
        SurvivalScenario.winterStorm,
        SurvivalScenario.hurricane,
        SurvivalScenario.earthquake,
      ],
    ),

    // Food - Rice
    PantryItem(
      id: '6',
      name: 'White Rice',
      unit: 'lbs',
      systemCategory: SystemCategory.food,
      subcategory: 'Grains',
      batches: [
        ItemBatch(
          quantity: 20.0,
          purchaseDate: DateTime.now().subtract(const Duration(days: 20)),
          expiryDate: DateTime.now().add(const Duration(days: 730)), // 2 years
          costPerUnit: 0.80,
        ),
      ],
      dailyConsumptionRate: 0.25, // 0.25 lbs per person per day
      minStockLevel: 7.0, // 2 weeks worth
      maxStockLevel: 35.0, // 10 weeks worth
      isEssential: true,
      applicableScenarios: [
        SurvivalScenario.powerOutage,
        SurvivalScenario.winterStorm,
        SurvivalScenario.hurricane,
        SurvivalScenario.isolation,
      ],
    ),
  ];

  // Helper method to get system category display info
  static String getSystemCategoryDisplayName(SystemCategory category) {
    return category.displayName;
  }

  static String getSystemCategoryEmoji(SystemCategory category) {
    return category.emoji;
  }

  static String getSystemCategoryDescription(SystemCategory category) {
    return category.description;
  }

  // Helper method to get survival scenario display info
  static String getSurvivalScenarioDisplayName(SurvivalScenario scenario) {
    return scenario.displayName;
  }

  static String getSurvivalScenarioEmoji(SurvivalScenario scenario) {
    return scenario.emoji;
  }

  static String getSurvivalScenarioDescription(SurvivalScenario scenario) {
    return scenario.description;
  }
}
