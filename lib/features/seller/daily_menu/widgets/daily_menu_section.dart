import 'package:flutter/material.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/menu_item_card.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class DailyMenuSection extends StatelessWidget {
  const DailyMenuSection({
    super.key,
    required this.title,
    required this.items,
    required this.onActiveChanged,
    required this.onSave,
  });

  final String title;
  final List<DailyMenuItem> items;
  final void Function(DailyMenuItem item, bool value) onActiveChanged;
  final void Function(
      DailyMenuItem item, String name, double? price, int stock) onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 12),
        ...items.map(
          (item) => MenuItemCard(
            item: item,
            onActiveChanged: (value) => onActiveChanged(item, value),
            onSave: (i, name, price, stock) => onSave(i, name, price, stock),
          ),
        ),
      ],
    );
  }
}
