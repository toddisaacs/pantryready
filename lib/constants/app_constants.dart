import 'package:flutter/material.dart';
import 'package:pantryready/models/pantry_item.dart';

enum ScanMode { shelve, remove, check }

class AppConstants {
  // App Version Information
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '2';
  static const String appName = 'PantryReady';
  static const String appDescription =
      'Pantry inventory management with barcode scanning';

  // Version tracking for analytics and debugging
  static const String versionString = '$appName v$appVersion+$appBuildNumber';
  static const String displayVersion = '$appName v$appVersion';
  static const String userAgent = '$appName/$appVersion';

  // Colors — warm pantry palette
  static const Color primaryColor = Color(0xFF5D4037); // warm brown
  static const Color primaryDarkColor = Color(0xFF3E2723);
  static const Color primaryLightColor = Color(0xFF8B6B61);
  static const Color accentColor = Color(0xFFE67E22); // warm amber CTA
  static const Color backgroundColor = Color(0xFFFFF8F0); // warm off-white
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5EDE4); // warm beige
  static const Color successColor = Color(0xFF27AE60);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color textColor = Color(0xFF2C1810); // dark brown
  static const Color textSecondaryColor = Color(0xFF7B6B63);

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

  // Centralized category colors
  static const Map<SystemCategory, Color> categoryColors = {
    SystemCategory.water: Color(0xFF2196F3),
    SystemCategory.food: Color(0xFFFF9800),
    SystemCategory.medical: Color(0xFFE74C3C),
    SystemCategory.hygiene: Color(0xFF9C27B0),
    SystemCategory.tools: Color(0xFF607D8B),
    SystemCategory.lighting: Color(0xFFFFC107),
    SystemCategory.shelter: Color(0xFF795548),
    SystemCategory.communication: Color(0xFF4CAF50),
    SystemCategory.security: Color(0xFF37474F),
    SystemCategory.other: Color(0xFF5D4037),
  };

  // Centralized category icons
  static const Map<SystemCategory, IconData> categoryIcons = {
    SystemCategory.water: Icons.water_drop,
    SystemCategory.food: Icons.restaurant,
    SystemCategory.medical: Icons.medical_services,
    SystemCategory.hygiene: Icons.cleaning_services,
    SystemCategory.tools: Icons.build,
    SystemCategory.lighting: Icons.lightbulb,
    SystemCategory.shelter: Icons.home,
    SystemCategory.communication: Icons.phone,
    SystemCategory.security: Icons.security,
    SystemCategory.other: Icons.inventory,
  };

  // Centralized subcategories per category
  static const Map<SystemCategory, List<String>> subcategories = {
    SystemCategory.food: [
      'Canned Goods',
      'Grains',
      'Condiments',
      'Snacks',
      'Frozen Foods',
      'Dairy',
      'Produce',
      'Meat',
    ],
    SystemCategory.water: ['Drinking Water', 'Purified Water', 'Spring Water'],
    SystemCategory.medical: ['First Aid', 'Medications', 'Supplies'],
    SystemCategory.hygiene: ['Personal Care', 'Cleaning', 'Sanitation'],
    SystemCategory.tools: ['Hand Tools', 'Power Tools', 'Equipment'],
    SystemCategory.lighting: ['Flashlights', 'Batteries', 'Candles'],
    SystemCategory.shelter: ['Tents', 'Tarps', 'Sleeping Bags'],
    SystemCategory.communication: ['Radios', 'Phones', 'Chargers'],
    SystemCategory.security: ['Locks', 'Alarms', 'Safes'],
    SystemCategory.other: ['Miscellaneous'],
  };

  // Smart default units per category
  static const Map<SystemCategory, String> defaultUnits = {
    SystemCategory.water: 'gallons',
    SystemCategory.food: 'cans',
    SystemCategory.medical: 'kits',
    SystemCategory.hygiene: 'pieces',
    SystemCategory.tools: 'pieces',
    SystemCategory.lighting: 'pieces',
    SystemCategory.shelter: 'pieces',
    SystemCategory.communication: 'pieces',
    SystemCategory.security: 'pieces',
    SystemCategory.other: 'pieces',
  };

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
