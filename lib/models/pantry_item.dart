class PantryItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final DateTime? expiryDate;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  PantryItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
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
      'expiryDate': expiryDate?.toIso8601String(),
      'category': category,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'] as String)
              : null,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PantryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PantryItem(id: $id, name: $name, quantity: $quantity, unit: $unit)';
  }
}
