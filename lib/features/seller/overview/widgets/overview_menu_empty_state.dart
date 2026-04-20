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
        DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onUploadTap,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentLight,
                      AppColors.accentLight.withValues(alpha: 0.78),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.textDark.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textDark.withValues(alpha: 0.10),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 30,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sube tu menú del día',
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Toca para subir una foto',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textDark.withValues(
                                  alpha: 0.68,
                                ),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        size: 26,
                      ),
                    ],
                  ),
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
