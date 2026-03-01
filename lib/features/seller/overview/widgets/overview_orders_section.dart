import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'overview_order_card.dart';

class OverviewOrdersSection extends StatelessWidget {
  const OverviewOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch orders from API
    const orders = [
      OrderCardData(
        customerName: 'Dayra Barboza',
        deliveryType: DeliveryType.pickup,
        paymentMethods: ['yape', 'plin'],
        amount: 40,
        timeAgo: 'Hace 15 minutos',
        borderColor: Color(0xFFEF4444),
        orderNumber: 'XXXXXXXXXX',
        dishes: [
          OrderDish(
            name: 'Arroz con pollo',
            quantity: 2,
            description: 'Papa a la huancaína',
          ),
          OrderDish(name: 'Seco con frejoles', quantity: 1),
        ],
        notes: 'De preferencia parte pecho los dos arroces',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Ordenes activas', style: AppTextStyles.h3),
            GestureDetector(
              onTap: () {},
              child: Text(
                'ver mas',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textGray,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textGray,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OverviewOrderCard(data: order),
          ),
        ),
      ],
    );
  }
}
