import 'package:komi_fe/features/buyer/restaurants/restaurants_model.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurant_card.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurants_filter_sheet.dart';

sealed class RestaurantsState {
  const RestaurantsState();
}

class RestaurantsLoading extends RestaurantsState {
  const RestaurantsLoading();
}

class RestaurantsNoNearbyStores extends RestaurantsState {
  const RestaurantsNoNearbyStores({this.searchText});

  final String? searchText;
}

class RestaurantsReady extends RestaurantsState {
  const RestaurantsReady({
    required this.stores,
    required this.filtered,
    this.paymentFilter,
    this.deliveryFilter,
  });

  final List<NearbyStore> stores;
  final List<RestaurantCardData> filtered;
  final RestaurantPaymentFilter? paymentFilter;
  final RestaurantDeliveryFilter? deliveryFilter;
}

class RestaurantsError extends RestaurantsState {
  const RestaurantsError(this.message);

  final String message;
}
