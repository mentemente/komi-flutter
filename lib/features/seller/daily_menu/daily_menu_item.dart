import 'package:flutter/material.dart';

enum MenuItemType { entrada, bebida, platoSegundo, platoALaCarta }

extension MenuItemTypeColor on MenuItemType {
  Color get cardColor {
    switch (this) {
      case MenuItemType.entrada:
        return const Color(0xFF7EB5D8);
      case MenuItemType.bebida:
        return const Color(0xFFF5A623);
      case MenuItemType.platoSegundo:
        return const Color(0xFF72C272);
      case MenuItemType.platoALaCarta:
        return const Color(0xFFB59DD4);
    }
  }
}

class DailyMenuItem {
  DailyMenuItem({
    required this.name,
    this.price,
    required this.stock,
    required this.isActive,
    required this.type,
  });

  String name;
  double? price;
  int stock;
  bool isActive;
  final MenuItemType type;
}
