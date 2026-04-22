import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class RestaurantMenuModeTab extends StatelessWidget {
  const RestaurantMenuModeTab({
    super.key,
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.textDark : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textDark, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppColors.white : AppColors.textDark,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.small.copyWith(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.72)
                      : AppColors.textGray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
