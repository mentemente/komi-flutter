import 'package:flutter/material.dart';
import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/title_profile_header.dart';
import 'package:komi_fe/features/seller/orders/widgets/orders_filter_sheet.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchController = TextEditingController();
  OrdersPaymentFilter? _paymentFilter;
  OrdersDeliveryFilter? _deliveryFilter;
  OrdersStatusFilter? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleProfileHeader(title: 'Ordenes activas'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 12),
                  _buildFilterButton(),
                ],
              ),
              const SizedBox(height: 20),
              // TODO: Remove this once we have the API implemented
              ..._mockOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderCard(data: order),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<OrderCardData> _mockOrders = [
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
  ];

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar',
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.textGray,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Material(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          OrdersFilterSheet.show(
            context,
            initialPayment: _paymentFilter,
            initialDelivery: _deliveryFilter,
            initialStatus: _statusFilter,
            onApply: (payment, delivery, status) {
              setState(() {
                _paymentFilter = payment;
                _deliveryFilter = delivery;
                _statusFilter = status;
              });
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 22, color: AppColors.textDark),
              const SizedBox(width: 8),
              Text(
                'Filtrar',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
