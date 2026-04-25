import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/formatting/currency_format.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/menu_count_badge.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/menu_section_widgets.dart';

class MainCourseTile extends StatelessWidget {
  const MainCourseTile({
    super.key,
    required this.dish,
    required this.count,
    required this.isExpanded,
    required this.appetizers,
    required this.beverages,
    required this.desserts,
    required this.selectedAppetizerId,
    required this.selectedBeverageId,
    required this.selectedDessertId,
    required this.onToggle,
    required this.onAppetizerSelected,
    required this.onBeverageSelected,
    required this.onDessertSelected,
    required this.onAgregar,
  });

  final DishItem dish;
  final int count;
  final bool isExpanded;
  final List<DishItem> appetizers;
  final List<DishItem> beverages;
  final List<DishItem> desserts;
  final String? selectedAppetizerId;
  final String? selectedBeverageId;
  final String? selectedDessertId;
  final VoidCallback onToggle;
  final ValueChanged<String> onAppetizerSelected;
  final ValueChanged<String> onBeverageSelected;
  final ValueChanged<String> onDessertSelected;
  final VoidCallback onAgregar;

  bool get _hasAnyExtras =>
      appetizers.isNotEmpty || beverages.isNotEmpty || desserts.isNotEmpty;

  bool get _dishEnabled => dish.isActive;

  @override
  Widget build(BuildContext context) {
    final showExtras = _dishEnabled && isExpanded;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: showExtras
              ? AppColors.textDark
              : AppColors.textGray.withValues(alpha: 0.3),
          width: showExtras ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dish.name,
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration:
                          _dishEnabled ? null : TextDecoration.lineThrough,
                      color: _dishEnabled
                          ? null
                          : AppColors.textGray.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (dish.price > 0)
                  Text(
                    formatSolesPrice(dish.price),
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          _dishEnabled ? null : TextDecoration.lineThrough,
                      color: _dishEnabled
                          ? null
                          : AppColors.textGray.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(width: 8),
                MenuCountBadge(
                  count: count,
                  onTap: _dishEnabled ? onToggle : null,
                ),
              ],
            ),
            if (showExtras) ...[
              const SizedBox(height: 16),
              if (appetizers.isNotEmpty) ...[
                const MenuSectionHeader(label: 'Escoge tu entrada'),
                const SizedBox(height: 6),
                for (final item in appetizers)
                  SelectableMenuDishRow(
                    item: item,
                    enabled: item.isActive,
                    isSelected: item.isActive && item.id == selectedAppetizerId,
                    onTap: () => onAppetizerSelected(item.id),
                  ),
                if (beverages.isNotEmpty || desserts.isNotEmpty)
                  const MenuSectionDivider(),
              ],
              if (beverages.isNotEmpty) ...[
                const MenuSectionHeader(label: 'Escoge tu bebida'),
                const SizedBox(height: 6),
                for (final item in beverages)
                  SelectableMenuDishRow(
                    item: item,
                    enabled: item.isActive,
                    isSelected: item.isActive && item.id == selectedBeverageId,
                    onTap: () => onBeverageSelected(item.id),
                  ),
                if (desserts.isNotEmpty) const MenuSectionDivider(),
              ],
              if (desserts.isNotEmpty) ...[
                const MenuSectionHeader(label: 'Escoge tu postre'),
                const SizedBox(height: 6),
                for (final item in desserts)
                  SelectableMenuDishRow(
                    item: item,
                    enabled: item.isActive,
                    isSelected: item.isActive && item.id == selectedDessertId,
                    onTap: () => onDessertSelected(item.id),
                  ),
              ],
              if (_hasAnyExtras) const SizedBox(height: 4),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _dishEnabled ? onAgregar : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: AppColors.textDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Agregar',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
