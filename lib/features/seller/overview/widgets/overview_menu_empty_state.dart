import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class OverviewMenuEmptyState extends StatelessWidget {
  const OverviewMenuEmptyState({super.key, required this.onUploadTap});

  final VoidCallback onUploadTap;

  static const String _ollinAsset = 'assets/images/ollin_señalando.webp';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUploadTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textDark, width: 2.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sube tu menú del día de hoy',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Icon(
                      Icons.add_rounded,
                      size: 52,
                      color: AppColors.textDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Image.asset(
            _ollinAsset,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.restaurant_rounded,
              size: 120,
              color: AppColors.textGray.withValues(alpha: 0.45),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Para poder ayudarte, necesitamos que subas una foto de tu menú',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textGray,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
