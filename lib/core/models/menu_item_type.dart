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

extension MenuItemTypePricing on MenuItemType {
  bool get isPricedDishCategory =>
      this == MenuItemType.main_course || this == MenuItemType.executive_dish;
}
