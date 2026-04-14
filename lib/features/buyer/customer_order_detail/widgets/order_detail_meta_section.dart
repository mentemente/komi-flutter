import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/models/payment_condition.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/order_card.dart' show DeliveryType;
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_card_style.dart';

class OrderDetailMetaSection extends StatelessWidget {
  const OrderDetailMetaSection({super.key, required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      OrderDetailMetaChipsRow(order: order),
      if (order.fullName.trim().isNotEmpty)
        OrderDetailMetaLine(
          icon: Icons.person_outline_rounded,
          label: 'Nombre',
          value: order.fullName,
        ),
      if (order.buyerPhone != null && order.buyerPhone!.trim().isNotEmpty)
        OrderDetailMetaLine(
          icon: Icons.phone_outlined,
          label: 'Teléfono',
          value: order.buyerPhone!,
        ),
      if (order.addressReference != null &&
          order.addressReference!.trim().isNotEmpty)
        OrderDetailMetaLine(
          icon: Icons.location_on_outlined,
          label: 'Dirección',
          value: order.addressReference!,
        ),
    ];

    if (rows.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: rows.first,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kOrderDetailCardOuterRadius),
          border: Border.all(
            color: AppColors.textDark,
            width: kOrderDetailCardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kOrderDetailCardInnerRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i < rows.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderDetailMetaChipsRow extends StatelessWidget {
  const OrderDetailMetaChipsRow({super.key, required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OrderDetailInfoChip(
          icon: order.deliveryType == DeliveryType.pickup
              ? Icons.directions_walk_rounded
              : Icons.electric_moped_rounded,
          label: order.deliveryType == DeliveryType.pickup
              ? 'Recojo en tienda'
              : 'Delivery',
        ),
        OrderDetailInfoChip(
          icon: orderDetailPaymentIcon(order.paymentCondition),
          label: orderDetailPaymentLabel(order.paymentCondition),
        ),
      ],
    );
  }
}

class OrderDetailInfoChip extends StatelessWidget {
  const OrderDetailInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailMetaLine extends StatelessWidget {
  const OrderDetailMetaLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textGray),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
