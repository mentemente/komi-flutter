import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum DeliveryOption { pickup, delivery }

class DeliveryOptionsSection extends StatelessWidget {
  const DeliveryOptionsSection({
    super.key,
    required this.selectedOptions,
    required this.onOptionToggled,
    required this.deliveryCostController,
  });

  final Set<DeliveryOption> selectedOptions;
  final void Function(DeliveryOption option) onOptionToggled;
  final TextEditingController deliveryCostController;

  @override
  Widget build(BuildContext context) {
    final showCostField = selectedOptions.contains(DeliveryOption.delivery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Opciones de entrega', style: AppTextStyles.h4),
        const SizedBox(height: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionCard(
              label: 'Recojo en tienda',
              icon: Icons.store_outlined,
              selected: selectedOptions.contains(DeliveryOption.pickup),
              onTap: () => onOptionToggled(DeliveryOption.pickup),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              label: 'Delivery',
              icon: Icons.delivery_dining_outlined,
              selected: selectedOptions.contains(DeliveryOption.delivery),
              onTap: () => onOptionToggled(DeliveryOption.delivery),
            ),
          ],
        ),
        if (showCostField) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Determina tu costo de delivery:',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextFormField(
                  controller: deliveryCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTextStyles.body,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    prefixText: 'S/ ',
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.textGray.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.textGray.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

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
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
              width: selected ? 1.5 : 1,
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
                child: Icon(icon, size: 26, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textDark,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: selected
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
