import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/orders/widgets/orders_filter_sheet.dart';

/// Row of badges with applied filters and action to remove each one or all.
class OrdersActiveFiltersBar extends StatelessWidget {
  const OrdersActiveFiltersBar({
    super.key,
    required this.payment,
    required this.delivery,
    required this.status,
    required this.onRemovePayment,
    required this.onRemoveDelivery,
    required this.onRemoveStatus,
    required this.onClearAll,
  });

  final OrdersPaymentFilter? payment;
  final OrdersDeliveryFilter? delivery;
  final OrdersStatusFilter? status;
  final VoidCallback onRemovePayment;
  final VoidCallback onRemoveDelivery;
  final VoidCallback onRemoveStatus;
  final VoidCallback onClearAll;

  bool get _hasAny => payment != null || delivery != null || status != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasAny) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Filtros activos',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Quitar todos',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (payment != null)
                _FilterBadge(
                  label: payment!.badgeLabel,
                  onRemove: onRemovePayment,
                ),
              if (delivery != null)
                _FilterBadge(
                  label: delivery!.badgeLabel,
                  onRemove: onRemoveDelivery,
                ),
              if (status != null)
                _FilterBadge(
                  label: status!.badgeLabel,
                  onRemove: onRemoveStatus,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  const _FilterBadge({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
