import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_accordion.dart';

/// Summary line (mock until integrating API items).
class OrderSummaryLineItem {
  const OrderSummaryLineItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;
}

/// Datos de líneas y total **estáticos** (maqueta) hasta integrar ítems del API.
class OrderDetailSummaryCard extends StatelessWidget {
  const OrderDetailSummaryCard({
    super.key,
    required this.items,
    required this.total,
  });

  final List<OrderSummaryLineItem> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return OrderDetailAccordion(
      icon: Icons.receipt_long_rounded,
      title: 'Tu orden',
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  OrderDetailOrderLineRow(item: items[i]),
                  if (i < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.textGray.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textGray.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'S/${total.toStringAsFixed(0)}',
                    style: AppTextStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailOrderLineRow extends StatelessWidget {
  const OrderDetailOrderLineRow({super.key, required this.item});

  final OrderSummaryLineItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.textDark.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${item.quantity}×',
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            style: AppTextStyles.bodySmall.copyWith(height: 1.35),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'S/${item.price.toStringAsFixed(0)}',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
