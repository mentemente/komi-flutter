import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class PendingDishCard extends StatelessWidget {
  const PendingDishCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  final DailyMenuItem item;
  final void Function(DailyMenuItem item)? onEdit;
  final void Function(DailyMenuItem item)? onDelete;

  @override
  Widget build(BuildContext context) {
    final borderColor = item.type.cardColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.price != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'S/${item.price!.toStringAsFixed(0)}',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${item.stock}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit != null ? () => onEdit!(item) : null,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textGray,
            iconSize: 22,
            style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
          ),
          IconButton(
            onPressed: onDelete != null ? () => onDelete!(item) : null,
            icon: const Icon(Icons.delete_outlined),
            color: AppColors.textGray,
            iconSize: 22,
            style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
          ),
        ],
      ),
    );
  }
}
