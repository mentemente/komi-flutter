import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';

sealed class CustomerOrderDetailState {
  const CustomerOrderDetailState();
}

class CustomerOrderDetailLoading extends CustomerOrderDetailState {
  const CustomerOrderDetailLoading();
}

class CustomerOrderDetailReady extends CustomerOrderDetailState {
  const CustomerOrderDetailReady(this.order);

  final BuyerOrder order;
}

class CustomerOrderDetailError extends CustomerOrderDetailState {
  const CustomerOrderDetailError(this.message);

  final String message;
}
