import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/features/seller/orders/orders_controller.dart';
import 'package:komi_fe/features/seller/orders/orders_state.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class OverviewOrdersSection extends ConsumerStatefulWidget {
  const OverviewOrdersSection({super.key});

  static const int _previewCount = 3;

  static const String overviewStatusQuery = 'pending,ready,delivered,confirmed';

  @override
  ConsumerState<OverviewOrdersSection> createState() =>
      _OverviewOrdersSectionState();
}

class _OverviewOrdersSectionState extends ConsumerState<OverviewOrdersSection> {
  late final OrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrdersController(ServiceLocator.ordersService);
    _controller.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _load() {
    final session = ref.read(authSessionProvider);
    final storeId = session?.stores.isNotEmpty == true
        ? session!.stores.first.id
        : null;
    _controller.loadOrders(
      storeId: storeId,
      status: OverviewOrdersSection.overviewStatusQuery,
    );
  }

  @override
  void dispose() {
    _controller.state.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state.value;

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
        if (state is OrdersLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (state is OrdersError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.message,
                  style: AppTextStyles.body.copyWith(color: AppColors.textGray),
                ),
                TextButton(onPressed: _load, child: const Text('Reintentar')),
              ],
            ),
          )
        else if (state is OrdersReady)
          ..._buildOrderCards(state),
      ],
    );
  }

  List<Widget> _buildOrderCards(OrdersReady state) {
    if (state.orders.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No hay órdenes activas.',
            style: AppTextStyles.body.copyWith(color: AppColors.textGray),
          ),
        ),
      ];
    }

    return state.orders
        .take(OverviewOrdersSection._previewCount)
        .map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OrderCard(data: order.toCardData()),
          ),
        )
        .toList();
  }
}
