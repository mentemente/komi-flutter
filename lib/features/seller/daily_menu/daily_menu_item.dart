// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum MenuItemType { appetizer, beverage, dessert, main_course, executive_dish }

MenuItemType menuItemTypeFromApi(String? raw) {
  switch (raw) {
    case 'appetizer':
      return MenuItemType.appetizer;
    case 'beverage':
      return MenuItemType.beverage;
    case 'dessert':
      return MenuItemType.dessert;
    case 'main_course':
      return MenuItemType.main_course;
    case 'executive_dish':
      return MenuItemType.executive_dish;
    default:
      return MenuItemType.main_course;
  }
}

extension MenuItemTypeColor on MenuItemType {
  Color get cardColor {
    switch (this) {
      case MenuItemType.appetizer:
        return const Color(0xFF7EB5D8);
      case MenuItemType.beverage:
        return const Color(0xFFF5A623);
      case MenuItemType.dessert:
        return const Color(0xFFE8A5B8);
      case MenuItemType.main_course:
        return const Color(0xFF72C272);
      case MenuItemType.executive_dish:
        return const Color(0xFFB59DD4);
    }
  }
}

/// Solo plato de fondo y a la carta tienen precio; acompañantes (entrada/bebida/postre) no.
extension MenuItemTypePricing on MenuItemType {
  bool get isPricedDishCategory =>
      this == MenuItemType.main_course || this == MenuItemType.executive_dish;
}

class DailyMenuItem {
  DailyMenuItem({
    this.id,
    required this.name,
    this.price,
    required this.stock,
    required this.isActive,
    required this.type,
  });

  /// Item from API (`GET` / `POST /v1/food`).
  factory DailyMenuItem.fromFoodApiMap(Map<String, dynamic> json) {
    final priceVal = json['price'];
    double? price;
    if (priceVal is num) {
      price = priceVal.toDouble();
    }
    return DailyMenuItem(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      price: price,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      type: menuItemTypeFromApi(json['type'] as String?),
    );
  }

  /// From [AddDishModal]: `unit` is the text of units/stock.
  factory DailyMenuItem.fromAddDishModal({
    required String name,
    required MenuItemType type,
    required String unit,
    double? price,
  }) {
    final parsed = int.tryParse(unit.trim());
    final stock = (parsed == null || parsed < 0) ? 0 : parsed;
    return DailyMenuItem(
      name: name,
      price: price,
      stock: stock,
      isActive: true,
      type: type,
    );
  }

  final String? id;
  String name;
  double? price;
  int stock;
  bool isActive;
  final MenuItemType type;

  /// Item for `foods` in `POST /v1/food`.
  Map<String, dynamic> toPublishFoodJson() {
    return <String, dynamic>{
      'name': name,
      'stock': stock,
      'price': price ?? 0,
      'type': type.name,
    };
  }
}
