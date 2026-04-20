import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/formatting/currency_format.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_accordion.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';
import 'package:komi_fe/features/seller/orders/orders_model.dart';

class OrderDetailSummaryCard extends StatelessWidget {
  const OrderDetailSummaryCard({super.key, required this.order});

  final BuyerOrder order;

  static String _comboSectionLabel(String type) {
    switch (type) {
      case 'menu':
        return 'Menú';
      case 'executive':
        return 'A la carta';
      default:
        return type.isNotEmpty ? type : 'Ítems';
    }
  }

  @override
  Widget build(BuildContext context) {
    final combos = order.combos;
    final sections = combos.where((c) => c.items.isNotEmpty).toList();
    final hasLines = sections.isNotEmpty;

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hasLines)
                  Text(
                    'No hay detalle de platos en este pedido.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textGray,
                    ),
                  )
                else
                  for (var si = 0; si < sections.length; si++) ...[
                    if (si > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.textGray.withValues(alpha: 0.2),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _comboSectionLabel(sections[si].type),
                          style: AppTextStyles.small.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textGray,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    for (var ii = 0; ii < sections[si].items.length; ii++) ...[
                      OrderDetailDishLineRow(item: sections[si].items[ii]),
                      if (ii < sections[si].items.length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _OrderTotalsBox(order: order),
          ),
        ],
      ),
    );
  }
}

class OrderDetailDishLineRow extends StatelessWidget {
  const OrderDetailDishLineRow({super.key, required this.item});

  final SellerOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: AppTextStyles.bodySmall.copyWith(height: 1.35),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatSolesPrice(item.price),
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Subtotal, delivery inferido (si aplica) y total, dentro del acordeón «Tu orden».
class _OrderTotalsBox extends StatelessWidget {
  const _OrderTotalsBox({required this.order});

  final BuyerOrder order;

  static const _kFreeEpsilon = 0.009;

  @override
  Widget build(BuildContext context) {
    final deliveryFee = order.inferredDeliveryFee;
    final showDeliveryBreakdown = deliveryFee != null;
    final subtotal = order.combosItemsSubtotal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textDark.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textGray.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDeliveryBreakdown) ...[
            _TotalSummaryRow(
              label: 'Subtotal',
              valueText: formatSolesPrice(subtotal),
            ),
            const SizedBox(height: 8),
            _TotalSummaryRow(
              label: 'Delivery',
              valueText: deliveryFee <= _kFreeEpsilon
                  ? 'Gratis'
                  : formatSolesPrice(deliveryFee),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColors.textGray.withValues(alpha: 0.22),
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatSolesPrice(order.total),
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalSummaryRow extends StatelessWidget {
  const _TotalSummaryRow({required this.label, required this.valueText});

  final String label;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: valueStyle.copyWith(color: AppColors.textGray),
        ),
        Text(valueText, style: valueStyle),
      ],
    );
  }
}
