import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_service.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_state.dart';

class RestaurantDetailController {
  RestaurantDetailController(this._service);

  final RestaurantDetailService _service;

  final ValueNotifier<RestaurantDetailState> state =
      ValueNotifier<RestaurantDetailState>(const RestaurantDetailLoading());

  Future<void> load(String storeId) async {
    state.value = const RestaurantDetailLoading();
    try {
      final menu = await _service.fetchMenu(storeId);
      state.value = RestaurantDetailReady(menu);
    } on ApiException catch (e) {
      if (e.code == 'STORE_CLOSED_TODAY') {
        String? weekdayKey;
        final d = e.details;
        if (d is Map) {
          final w = d['weekday'];
          if (w is String) weekdayKey = w;
        }
        state.value = RestaurantDetailStoreClosedToday(weekdayKey: weekdayKey);
        return;
      }
      state.value = RestaurantDetailError(e.displayMessage);
    } catch (e) {
      state.value = RestaurantDetailError('Error al cargar el menú.');
    }
  }

  void dispose() {
    state.dispose();
  }
}
