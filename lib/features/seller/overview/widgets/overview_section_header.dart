import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

/// Encabezado «título + ver más» para secciones del resumen.
class OverviewSectionHeader extends StatelessWidget {
  const OverviewSectionHeader({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: AppTextStyles.h4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'ver mas',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textGray,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textGray,
            ),
          ),
        ),
      ],
    );
  }
}
