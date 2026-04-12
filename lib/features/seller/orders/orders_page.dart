import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/core/widgets/title_profile_header.dart';
import 'package:komi_fe/features/seller/orders/orders_controller.dart';
import 'package:komi_fe/features/seller/orders/orders_state.dart';
import 'package:komi_fe/features/seller/orders/widgets/orders_active_filters_bar.dart';
import 'package:komi_fe/features/seller/orders/widgets/orders_filter_sheet.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final _searchController = TextEditingController();
  late final OrdersController _controller;
  OrdersPaymentFilter? _paymentFilter;
  OrdersDeliveryFilter? _deliveryFilter;
  OrdersStatusFilter? _statusFilter;

  bool get _hasActiveSheetFilters =>
      _paymentFilter != null ||
      _deliveryFilter != null ||
      _statusFilter != null;

  @override
  void initState() {
    super.initState();
    _controller = OrdersController(ServiceLocator.ordersService);
    _controller.state.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoad());
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _startLoad() {
    final session = ref.read(authSessionProvider);
    final storeId = session?.stores.isNotEmpty == true
        ? session!.stores.first.id
        : null;
    _controller.loadOrders(storeId: storeId);
  }

  Future<void> _onRefresh() async {
    final session = ref.read(authSessionProvider);
    final storeId = session?.stores.isNotEmpty == true
        ? session!.stores.first.id
        : null;
    await _controller.loadOrders(storeId: storeId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.state.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                OrdersActiveFiltersBar(
                  payment: _paymentFilter,
                  delivery: _deliveryFilter,
                  status: _statusFilter,
                  onRemovePayment: () => setState(() => _paymentFilter = null),
                  onRemoveDelivery: () =>
                      setState(() => _deliveryFilter = null),
                  onRemoveStatus: () => setState(() => _statusFilter = null),
                  onClearAll: () => setState(() {
                    _paymentFilter = null;
                    _deliveryFilter = null;
                    _statusFilter = null;
                  }),
                ),
                const SizedBox(height: 20),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final state = _controller.state.value;

    if (state is OrdersLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is OrdersError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            state.message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state is OrdersReady) {
      final filtered = _applyFilters(state.orders);

      if (filtered.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'No hay órdenes activas.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGray,
              ),
            ),
          ),
        );
      }

      return Column(
        children: filtered
            .map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(data: order.toCardData()),
              ),
            )
            .toList(),
      );
    }

    return const SizedBox.shrink();
  }

  List _applyFilters(List orders) {
    return orders.where((order) {
      if (_statusFilter != null) {
        final matches = switch (_statusFilter!) {
          OrdersStatusFilter.pending => order.status == OrderStatus.pending,
          OrdersStatusFilter.confirmed => order.status == OrderStatus.confirmed,
          OrdersStatusFilter.ready => order.status == OrderStatus.ready,
          OrdersStatusFilter.delivered => order.status == OrderStatus.delivered,
          OrdersStatusFilter.completed => order.status == OrderStatus.completed,
          OrdersStatusFilter.cancelled => order.status == OrderStatus.cancelled,
        };
        if (!matches) return false;
      }

      if (_deliveryFilter != null) {
        final matches = switch (_deliveryFilter!) {
          OrdersDeliveryFilter.pickup =>
            order.deliveryType == DeliveryType.pickup,
          OrdersDeliveryFilter.delivery =>
            order.deliveryType == DeliveryType.delivery,
        };
        if (!matches) return false;
      }

      if (_paymentFilter != null) {
        final condition = order.paymentCondition;
        final matches = switch (_paymentFilter!) {
          OrdersPaymentFilter.yapePlin => condition == 'prepaid',
          OrdersPaymentFilter.cash => condition == 'cash_on_delivery',
        };
        if (!matches) return false;
      }

      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.trim().toLowerCase();
        if (!order.fullName.toLowerCase().contains(query)) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.tune_rounded, size: 22, color: AppColors.textDark),
                  if (_hasActiveSheetFilters)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
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
