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
  ];

  static final List<PantryItem> samplePantryItems = [
    PantryItem(
      id: '1',
      name: 'Canned Beans',
      quantity: 12,
      unit: 'cans',
      category: 'Canned Goods',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '2',
      name: 'Rice',
      quantity: 5,
      unit: 'lbs',
      category: 'Grains',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '3',
      name: 'Bottled Water',
      quantity: 24,
      unit: 'bottles',
      category: 'Beverages',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '4',
      name: 'Pasta',
      quantity: 8,
      unit: 'boxes',
      category: 'Grains',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '5',
      name: 'Peanut Butter',
      quantity: 3,
      unit: 'jars',
      category: 'Condiments',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '6',
      name: 'Pinto Beans',
      quantity: 2,
      unit: 'lbs',
      category: 'Grains',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
