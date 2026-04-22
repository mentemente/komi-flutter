import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class OrderInProgressCard extends StatelessWidget {
  const OrderInProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pedidos en curso',
                    style: AppTextStyles.h5.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => context.go(RouteNames.orders),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.textDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ver seguimiento',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              'assets/images/ollin_con_plato.webp',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.restaurant_rounded,
                size: 64,
                color: AppColors.textGray.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
