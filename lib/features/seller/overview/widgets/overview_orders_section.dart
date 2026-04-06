import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/order_card.dart';

class OverviewOrdersSection extends StatelessWidget {
  const OverviewOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch orders from API
    const orders = [
      OrderCardData(
        customerName: 'Dayra Barboza',
        deliveryType: DeliveryType.pickup,
        paymentMethods: ['yape_plin'],
        amount: 40,
        timeAgo: 'Hace 15 minutos',
        status: OrderStatus.pending,
        orderNumber: 'ORD-001',
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
      OrderCardData(
        customerName: 'Carlos Mendoza',
        deliveryType: DeliveryType.delivery,
        paymentMethods: ['yape_plin'],
        amount: 28.50,
        timeAgo: 'Hace 32 minutos',
        status: OrderStatus.shipped,
        orderNumber: 'ORD-002',
        dishes: [
          OrderDish(name: 'Lomo saltado', quantity: 1),
          OrderDish(name: 'Causa rellena', quantity: 2),
          OrderDish(name: 'Chicha morada', quantity: 2),
        ],
        notes: 'Entregar en portón azul, 2do piso',
      ),
      OrderCardData(
        customerName: 'María Flores',
        deliveryType: DeliveryType.pickup,
        paymentMethods: ['cash'],
        amount: 55,
        timeAgo: 'Hace 5 minutos',
        status: OrderStatus.completed,
        orderNumber: 'ORD-003',
        dishes: [
          OrderDish(
            name: 'Ají de gallina',
            quantity: 1,
            description: 'Porción familiar',
          ),
          OrderDish(name: 'Ensalada fresca', quantity: 2),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Ordenes activas', style: AppTextStyles.h4),
            GestureDetector(
              onTap: () {
                context.go('${RouteNames.seller}${RouteNames.orders}');
              },
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
            child: OrderCard(data: order),
          ),
        ),
      ],
    );
  }
}
