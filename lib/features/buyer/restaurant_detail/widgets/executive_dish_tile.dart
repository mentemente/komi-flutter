import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/formatting/currency_format.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/menu_count_badge.dart';

class ExecutiveDishTile extends StatelessWidget {
  const ExecutiveDishTile({
    super.key,
    required this.dish,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final DishItem dish;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dish.name,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatSolesPrice(dish.price),
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0) ...[
            MenuSmallRoundButton(label: '−', filled: false, onTap: onRemove),
            const SizedBox(width: 6),
          ],
          MenuCountBadge(count: count, onTap: onAdd),
        ],
      ),
    );
  }
}
