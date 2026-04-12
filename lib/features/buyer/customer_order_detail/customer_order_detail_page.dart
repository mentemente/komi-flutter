import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/customer_order_detail_controller.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/customer_order_detail_state.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/order_detail_timeline_index.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_app_bar.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_error_view.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_meta_section.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_status_card.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_summary_card.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';

const List<OrderSummaryLineItem> _kMockOrderLines = [
  OrderSummaryLineItem(name: 'Arroz con pollo', quantity: 2, price: 24),
  OrderSummaryLineItem(name: 'Tallarines rojos', quantity: 1, price: 13),
];

const double _kMockOrderTotal = 40;

/// Order detail: loaded by API; the "Your order" card follows with static data.
class CustomerOrderDetailPage extends StatefulWidget {
  const CustomerOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<CustomerOrderDetailPage> createState() =>
      _CustomerOrderDetailPageState();
}

class _CustomerOrderDetailPageState extends State<CustomerOrderDetailPage> {
  late final CustomerOrderDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerOrderDetailController(
      ServiceLocator.customerOrdersService,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load(widget.orderId);
    });
  }

  @override
  void didUpdateWidget(CustomerOrderDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _controller.load(widget.orderId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey<String>(widget.orderId),
      backgroundColor: AppColors.background,
      body: MobileViewportContainer(
        backgroundColor: AppColors.background,
        panelColor: AppColors.background,
        child: SafeArea(
          child: ValueListenableBuilder<CustomerOrderDetailState>(
            valueListenable: _controller.state,
            builder: (context, detailState, _) {
              return switch (detailState) {
                CustomerOrderDetailLoading() => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                CustomerOrderDetailError(:final message) =>
                  OrderDetailErrorView(
                    message: message,
                    onRetry: () => _controller.load(widget.orderId),
                  ),
                CustomerOrderDetailReady(:final order) => _OrderDetailBody(
                  order: order,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final BuyerOrder order;

  @override
  Widget build(BuildContext context) {
    final title = order.storeName.trim().isNotEmpty
        ? order.storeName
        : 'Pedido';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderDetailAppBar(title: title, onBack: () => context.pop()),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrderDetailMetaSection(order: order),
                OrderDetailSummaryCard(
                  items: _kMockOrderLines,
                  total: _kMockOrderTotal,
                ),
                const SizedBox(height: 20),
                OrderDetailStatusCard(
                  steps: buyerOrderTimelineSteps(order.deliveryType),
                  activeIndex: buyerOrderTimelineActiveIndex(
                    status: order.status,
                    deliveryType: order.deliveryType,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
