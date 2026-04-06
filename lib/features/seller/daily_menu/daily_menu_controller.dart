import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_service.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_state.dart';
import 'package:komi_fe/features/seller/dishes/food_service.dart';

class DailyMenuController {
  DailyMenuController(this._service, this._foodService);

  final DailyMenuService _service;
  final FoodService _foodService;

  final ValueNotifier<DailyMenuState> state = ValueNotifier<DailyMenuState>(
    const DailyMenuLoading(),
  );

  String? _storeId;

  Future<void> loadFoods({String? storeId}) async {
    if (storeId == null || storeId.isEmpty) {
      _storeId = null;
      state.value = const DailyMenuError('No se encontró la tienda.');
      return;
    }

    _storeId = storeId;
    state.value = const DailyMenuLoading();

    try {
      final list = await _service.listFoods(storeId: storeId);
      state.value = DailyMenuReady(list);
    } on ApiException catch (e) {
      state.value = DailyMenuError(e.displayMessage);
    } catch (e) {
      state.value = DailyMenuError('$e');
    }
  }

  Future<void> setItemActive(DailyMenuItem item, bool value) async {
    final s = state.value;
    if (s is! DailyMenuReady) return;

    final storeId = _storeId;
    final id = item.id;
    if (id == null || id.isEmpty || storeId == null || storeId.isEmpty) {
      item.isActive = value;
      state.value = DailyMenuReady(List<DailyMenuItem>.from(s.items));
      return;
    }

    final previous = item.isActive;
    item.isActive = value;
    state.value = DailyMenuReady(List<DailyMenuItem>.from(s.items));

    try {
      final updated = await _foodService.patchFood(
        storeId: storeId,
        foodId: id,
        isActive: value,
      );
      item.name = updated.name;
      item.price = updated.price;
      item.stock = updated.stock;
      item.isActive = updated.isActive;
      state.value = DailyMenuReady(List<DailyMenuItem>.from(s.items));
    } on ApiException catch (e) {
      item.isActive = previous;
      state.value = DailyMenuReady(List<DailyMenuItem>.from(s.items));
      rethrow;
    } catch (e) {
      item.isActive = previous;
      state.value = DailyMenuReady(List<DailyMenuItem>.from(s.items));
      rethrow;
    }
  }

  void saveItem(DailyMenuItem item, String name, double? price, int stock) {
    final s = state.value;
    if (s is! DailyMenuReady) return;
    item.name = name;
    item.price = price;
    item.stock = stock;
    state.value = DailyMenuReady(List<DailyMenuItem>.from(s.items));
  }

  void dispose() {
    state.dispose();
  }
}
