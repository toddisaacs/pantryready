class PantryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final DateTime? expiryDate;
  final String? notes;
  final String? barcode; // Added barcode field
  final DateTime createdAt;
  final DateTime updatedAt;

  PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.expiryDate,
    this.notes,
    this.barcode, // Added barcode parameter
    required this.createdAt,
    required this.updatedAt,
  });

  PantryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    DateTime? expiryDate,
    String? notes,
    String? barcode, // Added barcode parameter
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      barcode: barcode ?? this.barcode, // Added barcode field
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'barcode': barcode, // Added barcode field
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'],
      category: json['category'],
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      notes: json['notes'],
      barcode: json['barcode'], // Added barcode field
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PantryItem &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.category == category &&
        other.expiryDate == expiryDate &&
        other.notes == notes &&
        other.barcode == barcode && // Added barcode field
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      quantity,
      unit,
      category,
      expiryDate,
      notes,
      barcode, // Added barcode field
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'PantryItem(id: $id, name: $name, quantity: $quantity, unit: $unit, category: $category, expiryDate: $expiryDate, notes: $notes, barcode: $barcode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
