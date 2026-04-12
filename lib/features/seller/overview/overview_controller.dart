import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/overview/overview_service.dart';
import 'package:komi_fe/features/seller/overview/overview_state.dart';

class OverviewController {
  OverviewController(this._service);

  final OverviewService _service;

  final ValueNotifier<OverviewMenuState> menuState =
      ValueNotifier<OverviewMenuState>(const OverviewMenuLoading());

  Future<void> loadMenu({String? storeId}) async {
    if (storeId == null || storeId.isEmpty) {
      menuState.value = const OverviewMenuError('No se encontró la tienda.');
      return;
    }

    menuState.value = const OverviewMenuLoading();

    try {
      final list = await _service.listMenuFoods(storeId: storeId);
      if (list.isEmpty) {
        menuState.value = const OverviewMenuEmpty();
      } else {
        menuState.value = OverviewMenuReady(list);
      }
    } on ApiException catch (e) {
      menuState.value = OverviewMenuError(e.displayMessage);
    } catch (e) {
      menuState.value = OverviewMenuError('$e');
    }
  }

  Future<void> setItemActive(
    DailyMenuItem item,
    bool value, {
    required String? storeId,
  }) async {
    final id = item.id;
    if (storeId == null || storeId.isEmpty || id == null || id.isEmpty) {
      item.isActive = value;
      _refreshReadyList();
      return;
    }

    final previous = item.isActive;
    item.isActive = value;
    _refreshReadyList();

    try {
      final updated = await _service.patchFoodActive(
        storeId: storeId,
        foodId: id,
        isActive: value,
      );
      item.name = updated.name;
      item.price = updated.price;
      item.stock = updated.stock;
      item.isActive = updated.isActive;
      _refreshReadyList();
    } on ApiException {
      item.isActive = previous;
      _refreshReadyList();
      rethrow;
    } catch (_) {
      item.isActive = previous;
      _refreshReadyList();
      rethrow;
    }
  }

  void saveItemFields(
    DailyMenuItem item,
    String name,
    double? price,
    int stock,
  ) {
    item.name = name;
    item.price = price;
    item.stock = stock;
    _refreshReadyList();
  }

  void _refreshReadyList() {
    final s = menuState.value;
    if (s is OverviewMenuReady) {
      menuState.value = OverviewMenuReady(List<DailyMenuItem>.from(s.items));
    }
  }

  void dispose() {
    menuState.dispose();
  }
}
