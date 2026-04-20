import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_service.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_state.dart';

class CustomerOrdersController {
  CustomerOrdersController(this._service);

  final CustomerOrdersService _service;

  final ValueNotifier<CustomerOrdersState> state =
      ValueNotifier<CustomerOrdersState>(const CustomerOrdersLoading());

  void setUnauthenticated() {
    state.value = const CustomerOrdersUnauthenticated();
  }

  Future<void> load() async {
    state.value = const CustomerOrdersLoading();
    try {
      final orders = await _service.fetchOrders();
      state.value = CustomerOrdersReady(orders);
    } on ApiException catch (e) {
      if (e.code == 'NO_SESSION') {
        state.value = const CustomerOrdersUnauthenticated();
      } else {
        state.value = CustomerOrdersError(e.displayMessage);
      }
    } catch (e) {
      state.value = CustomerOrdersError('$e');
    }
  }

  void dispose() {
    state.dispose();
  }
}
