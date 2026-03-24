import 'package:flutter/material.dart';

enum MenuItemType { entrada, platoSegundo, platoALaCarta }

extension MenuItemTypeColor on MenuItemType {
  /// Colores más fuertes (no pastel) para el fondo de la card.
  Color get cardColor {
    switch (this) {
      case MenuItemType.entrada:
        return const Color(0xFF7EB5D8); // Azul
      case MenuItemType.platoSegundo:
        return const Color(0xFF72C272); // Verde
      case MenuItemType.platoALaCarta:
        return const Color(0xFFB59DD4); // Morado
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
