import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/models/menu_item_type.dart';

/// Muestra qué [MenuItemType] representa el borde de cada plato, usando los
/// mismos colores que [MenuItemTypeColor.cardColor].
class MenuTypeColorLegend extends StatelessWidget {
  const MenuTypeColorLegend({super.key});

  static const _types = <MenuItemType>[
    MenuItemType.appetizer,
    MenuItemType.beverage,
    MenuItemType.dessert,
    MenuItemType.main_course,
    MenuItemType.executive_dish,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [for (final t in _types) _LegendChip(type: t)],
      ),
    );
  }
}

String _typeLabelEs(MenuItemType t) {
  switch (t) {
    case MenuItemType.appetizer:
      return 'Entrada';
    case MenuItemType.beverage:
      return 'Bebida';
    case MenuItemType.dessert:
      return 'Postre';
    case MenuItemType.main_course:
      return 'Plato de fondo';
    case MenuItemType.executive_dish:
      return 'A la carta';
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.type});

  final MenuItemType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: type.cardColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.textDark.withValues(alpha: 0.12),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _typeLabelEs(type),
          style: AppTextStyles.small.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
