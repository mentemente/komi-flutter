import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class RestaurantOrderCartBar extends StatelessWidget {
  const RestaurantOrderCartBar({
    super.key,
    required this.subtotalLabel,
    required this.onVerifyOrder,
    this.verifyLabel = 'Verificar pedido',
    this.enabled = true,
  });

  final String subtotalLabel;
  final VoidCallback onVerifyOrder;
  final String verifyLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.textGray.withValues(alpha: 0.2)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: enabled ? onVerifyOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  verifyLabel,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subtotal', style: AppTextStyles.small),
              Text(
                subtotalLabel,
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
