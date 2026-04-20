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

/// Menú no disponible: la API indica que la tienda está cerrada hoy (`STORE_CLOSED_TODAY`).
class RestaurantDetailStoreClosedToday extends RestaurantDetailState {
  const RestaurantDetailStoreClosedToday({this.weekdayKey});

  /// Valor en inglés desde `details.weekday` (p. ej. `sunday`), si viene en la respuesta.
  final String? weekdayKey;
}

class RestaurantDetailError extends RestaurantDetailState {
  const RestaurantDetailError(this.message);

  final String message;
}
