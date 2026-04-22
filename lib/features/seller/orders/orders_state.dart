import 'package:komi_fe/features/seller/orders/orders_model.dart';

sealed class OrdersState {
  const OrdersState();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersError extends OrdersState {
  const OrdersError(this.message);
  final String message;
}

final class OrdersReady extends OrdersState {
  const OrdersReady(this.orders);
  final List<SellerOrder> orders;
}
