import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/seller/orders/orders_service.dart';
import 'package:komi_fe/features/seller/orders/orders_state.dart';

class OrdersController {
  OrdersController(this._service);

  final OrdersService _service;

  final ValueNotifier<OrdersState> state = ValueNotifier<OrdersState>(
    const OrdersLoading(),
  );

  /// [status] opcional: CSV para el query `?status=` del API.
  Future<void> loadOrders({String? storeId, String? status}) async {
    if (storeId == null || storeId.isEmpty) {
      state.value = const OrdersError('No se encontró la tienda.');
      return;
    }

    state.value = const OrdersLoading();

    try {
      final orders = await _service.fetchOrders(storeId: storeId, status: status);
      state.value = OrdersReady(orders);
    } on ApiException catch (e) {
      state.value = OrdersError(e.displayMessage);
    } catch (e) {
      state.value = OrdersError('$e');
    }
  }

  void dispose() {
    state.dispose();
  }
}
