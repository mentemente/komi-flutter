import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';

sealed class CustomerOrdersState {
  const CustomerOrdersState();
}

class CustomerOrdersLoading extends CustomerOrdersState {
  const CustomerOrdersLoading();
}

class CustomerOrdersReady extends CustomerOrdersState {
  const CustomerOrdersReady(this.orders);

  final List<BuyerOrder> orders;
}

class CustomerOrdersError extends CustomerOrdersState {
  const CustomerOrdersError(this.message);

  final String message;
}
