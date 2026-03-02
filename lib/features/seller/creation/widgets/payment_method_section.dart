import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum PaymentMethod { yapePlin, cash }

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    super.key,
    required this.selectedMethods,
    required this.onMethodToggled,
  });

  final Set<PaymentMethod> selectedMethods;
  final void Function(PaymentMethod method) onMethodToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Método de pago', style: AppTextStyles.h5),
        const SizedBox(height: 16),
        _PaymentOptionCard(
          method: PaymentMethod.yapePlin,
          label: 'Yape / Plin',
          checked: selectedMethods.contains(PaymentMethod.yapePlin),
          onTap: () => onMethodToggled(PaymentMethod.yapePlin),
        ),
        const SizedBox(height: 12),
        _PaymentOptionCard(
          method: PaymentMethod.cash,
          label: 'Efectivo',
          checked: selectedMethods.contains(PaymentMethod.cash),
          onTap: () => onMethodToggled(PaymentMethod.cash),
        ),
        // TODO: Add input File field for Yape/Plin QR code
        if (selectedMethods.contains(PaymentMethod.yapePlin)) ...[
          const SizedBox(height: 16),
          _QrPlaceholder(),
        ],
      ],
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      child: Icon(
        Icons.qr_code_2_outlined,
        size: 64,
        color: AppColors.textGray.withValues(alpha: 0.5),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.method,
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final PaymentMethod method;
  final String label;
  final bool checked;
  final VoidCallback onTap;

  IconData get _icon => method == PaymentMethod.yapePlin
      ? Icons.phone_android
      : Icons.payments_outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: checked
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
              width: checked ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _icon,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textDark,
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: checked
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
