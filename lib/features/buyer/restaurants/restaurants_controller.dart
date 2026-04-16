import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/buyer/location/location_service.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_model.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_service.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_state.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurants_filter_sheet.dart';

class RestaurantsController {
  RestaurantsController({
    required RestaurantsService restaurantsService,
    required LocationService locationService,
  }) : _restaurantsService = restaurantsService,
       _locationService = locationService;

  final RestaurantsService _restaurantsService;
  final LocationService _locationService;

  final ValueNotifier<RestaurantsState> state = ValueNotifier(
    const RestaurantsLoading(),
  );

  List<NearbyStore> _allStores = [];

  Future<void> load() async {
    state.value = const RestaurantsLoading();
    try {
      final position = await _locationService.getCurrentPosition();
      final stores = await _restaurantsService.fetchNearby(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _allStores = stores;
      state.value = RestaurantsReady(
        stores: stores,
        filtered: stores.map((s) => s.toCardData()).toList(),
      );
    } on ApiException catch (e) {
      state.value = RestaurantsError(e.displayMessage);
    } catch (e) {
      state.value = RestaurantsError('$e');
    }
  }

  void applyFilters({
    RestaurantPaymentFilter? payment,
    RestaurantDeliveryFilter? delivery,
  }) {
    if (state.value is! RestaurantsReady) return;

    var filtered = _allStores;

    if (payment == RestaurantPaymentFilter.yapePlin) {
      filtered = filtered.where((s) => s.payments.prepaid).toList();
    } else if (payment == RestaurantPaymentFilter.cash) {
      filtered = filtered.where((s) => s.payments.cashOnDelivery).toList();
    }

    if (delivery == RestaurantDeliveryFilter.pickup) {
      filtered = filtered.where((s) => s.pickupEnabled).toList();
    } else if (delivery == RestaurantDeliveryFilter.delivery) {
      filtered = filtered.where((s) => s.deliveryEnabled).toList();
    }

    state.value = RestaurantsReady(
      stores: _allStores,
      filtered: filtered.map((s) => s.toCardData()).toList(),
      paymentFilter: payment,
      deliveryFilter: delivery,
    );
  }

  void applySearch(String query) {
    if (state.value is! RestaurantsReady) return;
    final current = state.value as RestaurantsReady;

    final q = query.trim().toLowerCase();
    var filtered = _allStores;

    if (q.isNotEmpty) {
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.description.toLowerCase().contains(q) ||
                s.matchingFoods.any((f) => f.toLowerCase().contains(q)),
          )
          .toList();
    }

    if (current.paymentFilter == RestaurantPaymentFilter.yapePlin) {
      filtered = filtered.where((s) => s.payments.prepaid).toList();
    } else if (current.paymentFilter == RestaurantPaymentFilter.cash) {
      filtered = filtered.where((s) => s.payments.cashOnDelivery).toList();
    }

    if (current.deliveryFilter == RestaurantDeliveryFilter.pickup) {
      filtered = filtered.where((s) => s.pickupEnabled).toList();
    } else if (current.deliveryFilter == RestaurantDeliveryFilter.delivery) {
      filtered = filtered.where((s) => s.deliveryEnabled).toList();
    }

    state.value = RestaurantsReady(
      stores: _allStores,
      filtered: filtered.map((s) => s.toCardData()).toList(),
      paymentFilter: current.paymentFilter,
      deliveryFilter: current.deliveryFilter,
    );
  }

  void dispose() {
    state.dispose();
  }
}
