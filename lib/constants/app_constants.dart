import 'package:flutter/material.dart';
import '../models/pantry_item.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Colors.green;
  static const Color primaryDarkColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Sample data
  static List<PantryItem> get samplePantryItems => [
    PantryItem(
      id: '1',
      name: 'Canned Beans',
      quantity: 12,
      unit: 'cans',
      category: 'Canned Goods',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '2',
      name: 'Rice',
      quantity: 5,
      unit: 'lbs',
      category: 'Grains',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '3',
      name: 'Bottled Water',
      quantity: 24,
      unit: 'bottles',
      category: 'Beverages',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '4',
      name: 'Pasta',
      quantity: 8,
      unit: 'boxes',
      category: 'Grains',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    PantryItem(
      id: '5',
      name: 'Peanut Butter',
      quantity: 3,
      unit: 'jars',
      category: 'Condiments',
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Categories
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

  // Units
  static const List<String> units = [
    'cans',
    'lbs',
    'bottles',
    'boxes',
    'jars',
    'bags',
    'pieces',
    'packages',
    'containers',
    'units',
  ];
}
