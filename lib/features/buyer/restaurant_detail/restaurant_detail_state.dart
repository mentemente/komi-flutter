import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

sealed class RestaurantDetailState {
  const RestaurantDetailState();
}

class RestaurantDetailLoading extends RestaurantDetailState {
  const RestaurantDetailLoading();
}

class RestaurantDetailReady extends RestaurantDetailState {
  const RestaurantDetailReady(this.menu);

  final StoreMenu menu;
}

class RestaurantDetailError extends RestaurantDetailState {
  const RestaurantDetailError(this.message);

  final String message;
}
