import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';

const Color kMenuCountGreen = Color(0xFF2D9D5C);

class MenuCountBadge extends StatelessWidget {
  const MenuCountBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasCount = count > 0;
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: hasCount ? kMenuCountGreen : Colors.transparent,
            shape: BoxShape.circle,
            border: hasCount
                ? null
                : Border.all(color: AppColors.textDark, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            hasCount ? '$count' : '+',
            style: TextStyle(
              fontSize: hasCount ? 14 : 18,
              fontWeight: FontWeight.w700,
              color: hasCount ? AppColors.white : AppColors.textDark,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuSmallRoundButton extends StatelessWidget {
  const MenuSmallRoundButton({
    super.key,
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: filled ? kMenuCountGreen : Colors.transparent,
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: AppColors.textDark, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: filled ? AppColors.white : AppColors.textDark,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
