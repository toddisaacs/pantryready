import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:pantryready/models/pantry_item.dart';

/// Represents a preparedness scenario with requirements and calculations
class PreparednessScenario {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int recommendedDays; // Recommended days of supply
  final int familySize; // Number of people to prepare for
  final Map<SystemCategory, double>
  categoryRequirements; // Requirements per category
  final List<String> essentialItems; // List of essential item IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  PreparednessScenario({
    String? id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.recommendedDays,
    required this.familySize,
    Map<SystemCategory, double>? categoryRequirements,
    List<String>? essentialItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       categoryRequirements = categoryRequirements ?? {},
       essentialItems = essentialItems ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Calculate readiness level for this scenario
  PreparednessResult calculateReadiness(List<PantryItem> items) {
    final results = <SystemCategory, CategoryReadiness>{};
    double overallReadiness = 0.0;
    int categoriesWithRequirements = 0;

    // Calculate readiness for each category
    for (final category in SystemCategory.values) {
      final requirement = categoryRequirements[category];
      if (requirement == null || requirement <= 0) continue;

      categoriesWithRequirements++;
      final categoryItems =
          items
              .where(
                (item) =>
                    item.systemCategory == category &&
                    item.applicableScenarios.contains(_getSurvivalScenario()),
              )
              .toList();

      final totalQuantity = categoryItems.fold(
        0.0,
        (sum, item) => sum + item.availableQuantity,
      );
      final daysOfSupply = totalQuantity / (requirement * familySize);
      final readinessPercentage = (daysOfSupply / recommendedDays * 100).clamp(
        0.0,
        100.0,
      );

      results[category] = CategoryReadiness(
        category: category,
        requiredQuantity: requirement * familySize * recommendedDays,
        availableQuantity: totalQuantity,
        daysOfSupply: daysOfSupply,
        readinessPercentage: readinessPercentage,
        items: categoryItems,
      );

      overallReadiness += readinessPercentage;
    }

    final averageReadiness =
        categoriesWithRequirements > 0
            ? overallReadiness / categoriesWithRequirements
            : 0.0;

    // Calculate critical shortages
    final criticalShortages = <PantryItem>[];
    for (final result in results.values) {
      if (result.daysOfSupply < 3) {
        // Less than 3 days is critical
        criticalShortages.addAll(result.items);
      }
    }

    return PreparednessResult(
      scenario: this,
      overallReadiness: averageReadiness,
      categoryResults: results,
      criticalShortages: criticalShortages,
      daysOfShortestSupply: _calculateDaysOfShortestSupply(results),
    );
  }

  /// Calculate days of supply for the category with the shortest supply
  double _calculateDaysOfShortestSupply(
    Map<SystemCategory, CategoryReadiness> results,
  ) {
    if (results.isEmpty) return 0.0;

    double shortestDays = double.infinity;
    for (final result in results.values) {
      if (result.daysOfSupply < shortestDays) {
        shortestDays = result.daysOfSupply;
      }
    }
    return shortestDays == double.infinity ? 0.0 : shortestDays;
  }

  /// Convert to SurvivalScenario enum
  SurvivalScenario _getSurvivalScenario() {
    switch (name.toLowerCase()) {
      case 'power outage':
        return SurvivalScenario.powerOutage;
      case 'winter storm':
        return SurvivalScenario.winterStorm;
      case 'hurricane':
        return SurvivalScenario.hurricane;
      case 'earthquake':
        return SurvivalScenario.earthquake;
      case 'pandemic':
        return SurvivalScenario.pandemic;
      case 'economic crisis':
        return SurvivalScenario.economic;
      case 'civil unrest':
        return SurvivalScenario.civilUnrest;
      case 'isolation':
        return SurvivalScenario.isolation;
      default:
        return SurvivalScenario.powerOutage;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'recommendedDays': recommendedDays,
      'familySize': familySize,
      'categoryRequirements': categoryRequirements.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'essentialItems': essentialItems,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PreparednessScenario.fromJson(Map<String, dynamic> json) {
    return PreparednessScenario(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      recommendedDays: json['recommendedDays'],
      familySize: json['familySize'],
      categoryRequirements:
          (json['categoryRequirements'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              SystemCategory.values.firstWhere((e) => e.name == key),
              (value as num).toDouble(),
            ),
          ) ??
          {},
      essentialItems:
          (json['essentialItems'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Represents the readiness level for a specific category
class CategoryReadiness {
  final SystemCategory category;
  final double requiredQuantity;
  final double availableQuantity;
  final double daysOfSupply;
  final double readinessPercentage;
  final List<PantryItem> items;

  CategoryReadiness({
    required this.category,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.daysOfSupply,
    required this.readinessPercentage,
    required this.items,
  });

  bool get isCritical => daysOfSupply < 3;
  bool get isLow => daysOfSupply < 7;
  bool get isAdequate => daysOfSupply >= 7;
}

/// Represents the overall preparedness result for a scenario
class PreparednessResult {
  final PreparednessScenario scenario;
  final double overallReadiness;
  final Map<SystemCategory, CategoryReadiness> categoryResults;
  final List<PantryItem> criticalShortages;
  final double daysOfShortestSupply;

  PreparednessResult({
    required this.scenario,
    required this.overallReadiness,
    required this.categoryResults,
    required this.criticalShortages,
    required this.daysOfShortestSupply,
  });

  String get readinessLevel {
    if (overallReadiness >= 90) return 'Excellent';
    if (overallReadiness >= 75) return 'Good';
    if (overallReadiness >= 50) return 'Fair';
    if (overallReadiness >= 25) return 'Poor';
    return 'Critical';
  }

  Color get readinessColor {
    if (overallReadiness >= 90) return Colors.green;
    if (overallReadiness >= 75) return Colors.lightGreen;
    if (overallReadiness >= 50) return Colors.orange;
    if (overallReadiness >= 25) return Colors.deepOrange;
    return Colors.red;
  }

  String get readinessMessage {
    if (daysOfShortestSupply <= 0) {
      return 'You are not prepared for ${scenario.name}';
    } else if (daysOfShortestSupply < 3) {
      return 'Critical: You have ${daysOfShortestSupply.toStringAsFixed(1)} days of supply';
    } else if (daysOfShortestSupply < 7) {
      return 'Low: You have ${daysOfShortestSupply.toStringAsFixed(1)} days of supply';
    } else if (daysOfShortestSupply < 14) {
      return 'Adequate: You have ${daysOfShortestSupply.toStringAsFixed(1)} days of supply';
    } else {
      return 'Well Prepared: You have ${daysOfShortestSupply.toStringAsFixed(1)} days of supply';
    }
  }
}

/// Predefined preparedness scenarios
class PreparednessScenarios {
  static final List<PreparednessScenario> scenarios = [
    PreparednessScenario(
      name: 'Power Outage',
      description: 'Loss of electricity for extended periods',
      emoji: '⚡',
      recommendedDays: 14,
      familySize: 4,
      categoryRequirements: {
        SystemCategory.water: 3.0, // 3 liters per person per day
        SystemCategory.food: 2.0, // 2 lbs per person per day
        SystemCategory.lighting: 0.0, // Not consumed daily
        SystemCategory.medical: 0.01, // Very low consumption
        SystemCategory.hygiene: 0.5, // 0.5 units per person per day
      },
    ),
    PreparednessScenario(
      name: 'Winter Storm',
      description: 'Snow and cold weather isolation',
      emoji: '❄️',
      recommendedDays: 21,
      familySize: 4,
      categoryRequirements: {
        SystemCategory.water: 3.0,
        SystemCategory.food: 2.5, // Higher food requirement in cold
        SystemCategory.shelter: 0.0, // Not consumed daily
        SystemCategory.medical: 0.01,
        SystemCategory.hygiene: 0.5,
        SystemCategory.lighting: 0.0,
      },
    ),
    PreparednessScenario(
      name: 'Hurricane',
      description: 'Severe weather event preparation',
      emoji: '🌀',
      recommendedDays: 7,
      familySize: 4,
      categoryRequirements: {
        SystemCategory.water: 3.0,
        SystemCategory.food: 2.0,
        SystemCategory.medical: 0.01,
        SystemCategory.hygiene: 0.5,
        SystemCategory.lighting: 0.0,
        SystemCategory.tools: 0.0,
      },
    ),
    PreparednessScenario(
      name: 'Pandemic',
      description: 'Health emergency preparation',
      emoji: '🦠',
      recommendedDays: 30,
      familySize: 4,
      categoryRequirements: {
        SystemCategory.water: 3.0,
        SystemCategory.food: 2.0,
        SystemCategory.medical: 0.05, // Higher medical needs
        SystemCategory.hygiene: 1.0, // Higher hygiene needs
        SystemCategory.communication: 0.0, // Not consumed daily
      },
    ),
    PreparednessScenario(
      name: 'Isolation',
      description: 'Remote living or complete isolation',
      emoji: '🏔️',
      recommendedDays: 90,
      familySize: 4,
      categoryRequirements: {
        SystemCategory.water: 3.0,
        SystemCategory.food: 2.0,
        SystemCategory.medical: 0.01,
        SystemCategory.hygiene: 0.5,
        SystemCategory.tools: 0.0,
        SystemCategory.lighting: 0.0,
        SystemCategory.communication: 0.0,
      },
    ),
  ];
}
