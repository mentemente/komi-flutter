import 'package:flutter/material.dart';
import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/models/payment_condition.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_order_progress.dart';

class CustomerOrderCardData {
  const CustomerOrderCardData({
    required this.orderId,
    required this.title,
    required this.address,
    required this.deliveryType,
    required this.paymentCondition,
    required this.status,
    required this.dateTimeLabel,
    required this.priceLabel,
  });

  final String orderId;
  final String title;
  final String address;
  final DeliveryType deliveryType;
  final String paymentCondition;
  final OrderStatus status;
  final String dateTimeLabel;
  final String priceLabel;
}

class CustomerOrderCard extends StatelessWidget {
  const CustomerOrderCard({super.key, required this.data, this.onTap});

  final CustomerOrderCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = data.status.borderColor;
    final progressValue = customerOrderProgress(
      deliveryType: data.deliveryType,
      status: data.status,
    );

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.status.labelEs,
                  style: AppTextStyles.small.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (data.address.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.address,
              style: AppTextStyles.caption.copyWith(height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                data.deliveryType == DeliveryType.pickup
                    ? Icons.directions_walk_rounded
                    : Icons.electric_moped_rounded,
                size: 22,
                color: AppColors.textDark,
              ),
              const SizedBox(width: 12),
              _CustomerOrderPaymentIcon(
                paymentCondition: data.paymentCondition,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: AppColors.textGray.withValues(alpha: 0.15),
              color: const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.textGray.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(data.dateTimeLabel, style: AppTextStyles.small),
              ),
              Text(
                data.priceLabel,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class _CustomerOrderPaymentIcon extends StatelessWidget {
  const _CustomerOrderPaymentIcon({required this.paymentCondition});

  final String paymentCondition;

  @override
  Widget build(BuildContext context) {
    final normalized = paymentCondition.trim().toLowerCase();
    if (normalized == OrderPaymentCondition.prepaid) {
      return Image.asset(
        'assets/images/yape_plin.webp',
        height: 24,
        width: 56,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.phone_android_rounded,
          size: 22,
          color: AppColors.textDark,
        ),
      );
    }
    if (normalized == OrderPaymentCondition.cashOnDelivery) {
      return const Icon(
        Icons.payments_outlined,
        size: 22,
        color: AppColors.textDark,
      );
    }
    return const SizedBox.shrink();
  }
}
