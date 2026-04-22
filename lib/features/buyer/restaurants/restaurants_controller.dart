import 'dart:async';

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

  final ValueNotifier<bool> searchInProgress = ValueNotifier(false);

  List<NearbyStore> _allStores = [];

  double? _lastLatitude;
  double? _lastLongitude;

  Timer? _searchDebounceTimer;

  int _fetchGeneration = 0;

  static const Duration _searchDebounceDuration = Duration(milliseconds: 400);

  Future<void> load({String? searchText}) async {
    _searchDebounceTimer?.cancel();
    final id = ++_fetchGeneration;
    searchInProgress.value = false;
    state.value = const RestaurantsLoading();
    try {
      final position = await _locationService.getCurrentPosition();
      if (id != _fetchGeneration) return;

      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;

      final stores = await _restaurantsService.fetchNearby(
        latitude: position.latitude,
        longitude: position.longitude,
        searchText: searchText,
      );
      if (id != _fetchGeneration) return;

      _allStores = stores;
      state.value = RestaurantsReady(
        stores: stores,
        filtered: stores.map((s) => s.toCardData()).toList(),
      );
    } on ApiException catch (e) {
      if (id != _fetchGeneration) return;
      if (e.code == 'NO_NEARBY_STORES') {
        state.value = RestaurantsNoNearbyStores(searchText: searchText);
        return;
      }
      state.value = RestaurantsError(e.displayMessage);
    } catch (e) {
      if (id != _fetchGeneration) return;
      state.value = RestaurantsError('$e');
    }
  }

  void scheduleDebouncedNearbySearch(String rawQuery) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceDuration, () {
      final trimmed = rawQuery.trim();
      unawaited(_runNearbySearchWithApi(
        trimmed.isEmpty ? null : trimmed,
      ));
    });
  }

  Future<void> _runNearbySearchWithApi(String? searchText) async {
    final id = ++_fetchGeneration;
    searchInProgress.value = true;
    try {
      await _ensureLastCoordinates();
      if (id != _fetchGeneration) return;

      final lat = _lastLatitude!;
      final lng = _lastLongitude!;

      final stores = await _restaurantsService.fetchNearby(
        latitude: lat,
        longitude: lng,
        searchText: searchText,
      );
      if (id != _fetchGeneration) return;

      _allStores = stores;
      final filters = _activeFilters();
      final filtered = _applyStoreFilters(
        _allStores,
        payment: filters.$1,
        delivery: filters.$2,
      );
      state.value = RestaurantsReady(
        stores: _allStores,
        filtered: filtered.map((s) => s.toCardData()).toList(),
        paymentFilter: filters.$1,
        deliveryFilter: filters.$2,
      );
    } on ApiException catch (e) {
      if (id != _fetchGeneration) return;
      if (e.code == 'NO_NEARBY_STORES') {
        state.value = RestaurantsNoNearbyStores(searchText: searchText);
        return;
      }
      state.value = RestaurantsError(e.displayMessage);
    } catch (e) {
      if (id != _fetchGeneration) return;
      state.value = RestaurantsError('$e');
    } finally {
      if (id == _fetchGeneration) {
        searchInProgress.value = false;
      }
    }
  }

  Future<void> _ensureLastCoordinates() async {
    if (_lastLatitude != null && _lastLongitude != null) return;
    final position = await _locationService.getCurrentPosition();
    _lastLatitude = position.latitude;
    _lastLongitude = position.longitude;
  }

  (RestaurantPaymentFilter?, RestaurantDeliveryFilter?) _activeFilters() {
    final s = state.value;
    if (s is! RestaurantsReady) return (null, null);
    return (s.paymentFilter, s.deliveryFilter);
  }

  List<NearbyStore> _applyStoreFilters(
    List<NearbyStore> source, {
    RestaurantPaymentFilter? payment,
    RestaurantDeliveryFilter? delivery,
  }) {
    var filtered = source;

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

    return filtered;
  }

  void applyFilters({
    RestaurantPaymentFilter? payment,
    RestaurantDeliveryFilter? delivery,
  }) {
    if (state.value is! RestaurantsReady) return;

    final filtered = _applyStoreFilters(
      _allStores,
      payment: payment,
      delivery: delivery,
    );

    state.value = RestaurantsReady(
      stores: _allStores,
      filtered: filtered.map((s) => s.toCardData()).toList(),
      paymentFilter: payment,
      deliveryFilter: delivery,
    );
  }

  void dispose() {
    _searchDebounceTimer?.cancel();
    searchInProgress.dispose();
    state.dispose();
  }
}
