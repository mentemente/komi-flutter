import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class DishAccordion extends StatelessWidget {
  const DishAccordion({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.body,
    this.trailing,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget body;
  final Widget? trailing;

  static const double _radius = 16;
  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.textDark.withValues(alpha: 0.25),
          width: _borderWidth,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius - 1),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(_radius - 1),
                ),
                splashColor: AppColors.primary.withValues(alpha: 0.12),
                highlightColor: AppColors.accentLight.withValues(alpha: 0.3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? AppColors.accentLight.withValues(alpha: 0.15)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppColors.textDark,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        trailing!,
                        const SizedBox(width: 10),
                      ],
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 28,
                          color: isExpanded
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: AppColors.textGray.withValues(alpha: 0.2),
                    ),
                    body,
                  ],
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
