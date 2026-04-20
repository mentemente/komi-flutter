import 'package:flutter/material.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/daily_menu/widgets/daily_menu_section.dart';

/// Sections Entrees / Beverages / Menus / Executive Dishes.
class DailyMenuGroupedSections extends StatelessWidget {
  const DailyMenuGroupedSections({
    super.key,
    required this.items,
    required this.onActiveChanged,
    required this.onSave,
  });

  final List<DailyMenuItem> items;
  final Future<void> Function(DailyMenuItem item, bool value) onActiveChanged;
  final void Function(DailyMenuItem item, String name, double? price, int stock)
  onSave;

  List<DailyMenuItem> _byType(MenuItemType type) {
    return items.where((e) => e.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    void add(String title, List<DailyMenuItem> sectionItems) {
      if (sectionItems.isEmpty) return;
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 16));
      }
      children.add(
        DailyMenuSection(
          title: title,
          items: sectionItems,
          onActiveChanged: onActiveChanged,
          onSave: onSave,
        ),
      );
    }

    add('Entradas', _byType(MenuItemType.appetizer));
    add('Bebidas', _byType(MenuItemType.beverage));
    add('Postres', _byType(MenuItemType.dessert));
    add('Menus', _byType(MenuItemType.main_course));
    add('Platos a la carta', _byType(MenuItemType.executive_dish));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
