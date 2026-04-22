import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class KomiBrandPanel extends StatelessWidget {
  const KomiBrandPanel({super.key, this.illustrationSize = 256});

  final double illustrationSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ollin.webp',
                width: illustrationSize,
                height: illustrationSize,
              ),
              Text(
                'KOMI',
                style: AppTextStyles.h1.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Alimento casero más cerca de ti',
                style: AppTextStyles.h2.copyWith(color: AppColors.accentLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
