import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_service.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/customer_order_detail_state.dart';

class CustomerOrderDetailController {
  CustomerOrderDetailController(this._ordersService);

  final CustomerOrdersService _ordersService;

  final ValueNotifier<CustomerOrderDetailState> state =
      ValueNotifier<CustomerOrderDetailState>(const CustomerOrderDetailLoading());

  Future<void> load(String orderId) async {
    state.value = const CustomerOrderDetailLoading();
    try {
      final order = await _ordersService.fetchOrderById(orderId);
      state.value = CustomerOrderDetailReady(order);
    } on ApiException catch (e) {
      state.value = CustomerOrderDetailError(e.displayMessage);
    } catch (e) {
      state.value = CustomerOrderDetailError('$e');
    }
  }

  void dispose() {
    state.dispose();
  }
}
