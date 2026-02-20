import 'package:uuid/uuid.dart';

/// Represents a batch of items purchased together
class ItemBatch {
  final String id;
  final double quantity;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final double? costPerUnit;
  final String? notes;

  ItemBatch({
    String? id,
    required this.quantity,
    required this.purchaseDate,
    this.expiryDate,
    this.costPerUnit,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  ItemBatch copyWith({
    String? id,
    double? quantity,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? costPerUnit,
    String? notes,
  }) {
    return ItemBatch(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'costPerUnit': costPerUnit,
      'notes': notes,
    };
  }

  factory ItemBatch.fromJson(Map<String, dynamic> json) {
    return ItemBatch(
      id: json['id'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(json['purchaseDate']),
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      costPerUnit: json['costPerUnit']?.toDouble(),
      notes: json['notes'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemBatch &&
        other.id == id &&
        other.quantity == quantity &&
        other.purchaseDate == purchaseDate &&
        other.expiryDate == expiryDate &&
        other.costPerUnit == costPerUnit &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      quantity,
      purchaseDate,
      expiryDate,
      costPerUnit,
      notes,
    );
  }
}

/// System categories for survival/preparedness tracking
enum SystemCategory {
  water('Water', '💧', 'Essential for survival'),
  food('Food', '🍽️', 'Nutrition and sustenance'),
  medical('Medical', '🏥', 'Health and first aid'),
  hygiene('Hygiene', '🧼', 'Personal care and sanitation'),
  tools('Tools', '🔧', 'Equipment and utilities'),
  lighting('Lighting', '💡', 'Illumination and power'),
  shelter('Shelter', '🏠', 'Protection and warmth'),
  communication('Communication', '📱', 'Information and contact'),
  security('Security', '🔒', 'Safety and protection'),
  other('Other', '📦', 'Miscellaneous items');

  const SystemCategory(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}

/// Survival scenarios for preparedness calculations
enum SurvivalScenario {
  powerOutage('Power Outage', '⚡', 'Loss of electricity'),
  winterStorm('Winter Storm', '❄️', 'Snow and cold weather'),
  hurricane('Hurricane', '🌀', 'Severe weather event'),
  earthquake('Earthquake', '🌋', 'Natural disaster'),
  pandemic('Pandemic', '🦠', 'Health emergency'),
  economic('Economic Crisis', '💰', 'Financial hardship'),
  civilUnrest('Civil Unrest', '🚨', 'Social disruption'),
  isolation('Isolation', '🏔️', 'Remote living');

  const SurvivalScenario(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}

/// Enhanced PantryItem for survival/preparedness tracking
class PantryItem {
  final String id;
  final String name;
  final String unit;
  final SystemCategory systemCategory;
  final String? subcategory; // e.g., "Grains", "Canned Goods"
  final List<ItemBatch> batches;
  final String? brand;
  final String? barcode;
  final String? notes;
  final String? storageLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Consumption and preparedness fields
  final double? dailyConsumptionRate; // units per person per day
  final double? minStockLevel; // minimum quantity to maintain
  final double? maxStockLevel; // maximum quantity to avoid excess
  final bool isEssential; // critical for survival
  final List<SurvivalScenario>
  applicableScenarios; // which scenarios this item covers
  final String? productId; // for API integration (OpenFoodFacts, etc.)

  PantryItem({
    String? id,
    required this.name,
    required this.unit,
    required this.systemCategory,
    this.subcategory,
    List<ItemBatch>? batches,
    this.brand,
    this.barcode,
    this.notes,
    this.storageLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dailyConsumptionRate,
    this.minStockLevel,
    this.maxStockLevel,
    this.isEssential = false,
    List<SurvivalScenario>? applicableScenarios,
    this.productId,
  }) : id = id ?? const Uuid().v4(),
       batches = batches ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       applicableScenarios = applicableScenarios ?? [];

  /// Total quantity across all batches
  double get totalQuantity {
    return batches.fold(0.0, (sum, batch) => sum + batch.quantity);
  }

  /// Quantity of non-expired items
  double get availableQuantity {
    final now = DateTime.now();
    return batches
        .where(
          (batch) => batch.expiryDate == null || batch.expiryDate!.isAfter(now),
        )
        .fold(0.0, (sum, batch) => sum + batch.quantity);
  }

  /// Days of supply based on daily consumption rate
  double? get daysOfSupply {
    if (dailyConsumptionRate == null || dailyConsumptionRate! <= 0) return null;
    return availableQuantity / dailyConsumptionRate!;
  }

  /// Whether stock is low (below minimum)
  bool get isLowStock {
    if (minStockLevel == null) return false;
    return availableQuantity < minStockLevel!;
  }

  /// Whether stock is excessive (above maximum)
  bool get isExcessiveStock {
    if (maxStockLevel == null) return false;
    return totalQuantity > maxStockLevel!;
  }

  /// Whether any batches are expiring soon (within 30 days)
  bool get hasExpiringItems {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return batches.any(
      (batch) =>
          batch.expiryDate != null &&
          batch.expiryDate!.isBefore(thirtyDaysFromNow) &&
          batch.quantity > 0,
    );
  }

  /// Get batches sorted by expiry date (FIFO for rotation)
  List<ItemBatch> get sortedBatches {
    final sorted = List<ItemBatch>.from(batches);
    sorted.sort((a, b) {
      if (a.expiryDate == null && b.expiryDate == null) {
        return a.purchaseDate.compareTo(b.purchaseDate);
      }
      if (a.expiryDate == null) return -1;
      if (b.expiryDate == null) return 1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });
    return sorted;
  }

  /// Get expiring batches (within specified days)
  List<ItemBatch> getExpiringBatches(int days) {
    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: days));
    return batches
        .where(
          (batch) =>
              batch.expiryDate != null &&
              batch.expiryDate!.isBefore(cutoffDate) &&
              batch.quantity > 0,
        )
        .toList();
  }

  /// Calculate days of supply for a specific scenario
  double? getDaysOfSupplyForScenario(
    SurvivalScenario scenario,
    int familySize,
  ) {
    if (!applicableScenarios.contains(scenario) ||
        dailyConsumptionRate == null ||
        dailyConsumptionRate! <= 0) {
      return null;
    }

    final dailyNeed = dailyConsumptionRate! * familySize;
    return availableQuantity / dailyNeed;
  }

  PantryItem copyWith({
    String? id,
    String? name,
    String? unit,
    SystemCategory? systemCategory,
    String? subcategory,
    List<ItemBatch>? batches,
    String? brand,
    String? barcode,
    String? notes,
    String? storageLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? dailyConsumptionRate,
    double? minStockLevel,
    double? maxStockLevel,
    bool? isEssential,
    List<SurvivalScenario>? applicableScenarios,
    String? productId,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      systemCategory: systemCategory ?? this.systemCategory,
      subcategory: subcategory ?? this.subcategory,
      batches: batches ?? this.batches,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      notes: notes ?? this.notes,
      storageLocation: storageLocation ?? this.storageLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dailyConsumptionRate: dailyConsumptionRate ?? this.dailyConsumptionRate,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      isEssential: isEssential ?? this.isEssential,
      applicableScenarios: applicableScenarios ?? this.applicableScenarios,
      productId: productId ?? this.productId,
    );
  }

  /// Add a new batch to the item
  PantryItem addBatch(ItemBatch batch) {
    final updatedBatches = List<ItemBatch>.from(batches)..add(batch);
    return copyWith(batches: updatedBatches, updatedAt: DateTime.now());
  }

  /// Remove quantity from oldest batches (FIFO rotation)
  PantryItem consumeQuantity(double quantity) {
    if (quantity <= 0) return this;

    final sorted = sortedBatches;
    final updatedBatches = <ItemBatch>[];
    double remainingToConsume = quantity;

    for (final batch in sorted) {
      if (remainingToConsume <= 0) {
        updatedBatches.add(batch);
        continue;
      }

      if (batch.quantity <= remainingToConsume) {
        // Consume entire batch
        remainingToConsume -= batch.quantity;
        // Don't add batch to updated list (consumed entirely)
      } else {
        // Consume partial batch
        final remainingInBatch = batch.quantity - remainingToConsume;
        updatedBatches.add(batch.copyWith(quantity: remainingInBatch));
        remainingToConsume = 0;
      }
    }

    return copyWith(batches: updatedBatches, updatedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'systemCategory': systemCategory.name,
      'subcategory': subcategory,
      'batches': batches.map((batch) => batch.toJson()).toList(),
      'brand': brand,
      'barcode': barcode,
      'notes': notes,
      'storageLocation': storageLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dailyConsumptionRate': dailyConsumptionRate,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'isEssential': isEssential,
      'applicableScenarios': applicableScenarios.map((s) => s.name).toList(),
      'productId': productId,
    };
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      systemCategory: SystemCategory.values.firstWhere(
        (e) => e.name == json['systemCategory'],
        orElse: () => SystemCategory.other,
      ),
      subcategory: json['subcategory'],
      batches:
          (json['batches'] as List<dynamic>?)
              ?.map((batchJson) => ItemBatch.fromJson(batchJson))
              .toList() ??
          [],
      brand: json['brand'] as String?,
      barcode: json['barcode'],
      notes: json['notes'],
      storageLocation: json['storageLocation'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      dailyConsumptionRate: json['dailyConsumptionRate']?.toDouble(),
      minStockLevel: json['minStockLevel']?.toDouble(),
      maxStockLevel: json['maxStockLevel']?.toDouble(),
      isEssential: json['isEssential'] ?? false,
      applicableScenarios:
          (json['applicableScenarios'] as List<dynamic>?)
              ?.map(
                (scenarioName) => SurvivalScenario.values.firstWhere(
                  (s) => s.name == scenarioName,
                  orElse: () => SurvivalScenario.powerOutage,
                ),
              )
              .toList() ??
          [],
      productId: json['productId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PantryItem &&
        other.id == id &&
        other.name == name &&
        other.unit == unit &&
        other.systemCategory == systemCategory &&
        other.subcategory == subcategory &&
        other.batches.length == batches.length &&
        other.batches.every((batch) => batches.contains(batch)) &&
        other.brand == brand &&
        other.barcode == barcode &&
        other.notes == notes &&
        other.storageLocation == storageLocation &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dailyConsumptionRate == dailyConsumptionRate &&
        other.minStockLevel == minStockLevel &&
        other.maxStockLevel == maxStockLevel &&
        other.isEssential == isEssential &&
        other.applicableScenarios.length == applicableScenarios.length &&
        other.applicableScenarios.every(
          (scenario) => applicableScenarios.contains(scenario),
        ) &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      unit,
      systemCategory,
      subcategory,
      Object.hashAll(batches),
      brand,
      barcode,
      notes,
      storageLocation,
      createdAt,
      updatedAt,
      dailyConsumptionRate,
      minStockLevel,
      maxStockLevel,
      isEssential,
      Object.hashAll(applicableScenarios),
      productId,
    );
  }

  @override
  String toString() {
    return 'PantryItem(id: $id, name: $name, unit: $unit, systemCategory: $systemCategory, totalQuantity: $totalQuantity, isEssential: $isEssential)';
  }
}
