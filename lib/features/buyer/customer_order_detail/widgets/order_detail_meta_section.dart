import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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
      if (order.deliveryType == DeliveryType.pickup &&
          order.coordLat != null &&
          order.coordLng != null)
        _OpenMapsButton(lat: order.coordLat!, lng: order.coordLng!),
    ];

    if (rows.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: rows.first,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kOrderDetailCardOuterRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kOrderDetailCardInnerRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i < rows.length - 1) const SizedBox(height: 8),
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
      spacing: 6,
      runSpacing: 6,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
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
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: AppColors.textGray),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDark,
                height: 1.25,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray,
                    height: 1.25,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenMapsButton extends StatelessWidget {
  const _OpenMapsButton({required this.lat, required this.lng});

  final double lat;
  final double lng;

  String get _mapsUrl => 'https://www.google.com/maps?q=$lat,$lng';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MapsActionButton(
          icon: Icons.location_on_outlined,
          label: 'Ver en Maps',
          onTap: () async {
            final uri = Uri.parse(_mapsUrl);
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo abrir Google Maps.')),
              );
            }
          },
        ),
        const SizedBox(width: 6),
        _MapsActionButton(
          icon: Icons.copy_rounded,
          label: 'Copiar enlace',
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: _mapsUrl));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enlace copiado')),
            );
          },
        ),
      ],
    );
  }
}

class _MapsActionButton extends StatelessWidget {
  const _MapsActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
