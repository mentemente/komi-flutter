import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

class MenuSectionHeader extends StatelessWidget {
  const MenuSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          'Opcional',
          style: AppTextStyles.small.copyWith(
            color: AppColors.textGray,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class MenuSectionDivider extends StatelessWidget {
  const MenuSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: AppColors.textGray.withValues(alpha: 0.15),
      ),
    );
  }
}

class SelectableMenuDishRow extends StatelessWidget {
  const SelectableMenuDishRow({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final DishItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.textDark,
              checkColor: AppColors.white,
              side: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.5),
                width: 1.5,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name, style: AppTextStyles.bodySmall)),
          ],
        ),
      ),
    );
  }
}
