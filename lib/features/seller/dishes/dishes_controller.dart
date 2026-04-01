import 'package:flutter/foundation.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class DishesController {
  DishesController() {
    _dailyExpanded = ValueNotifier<bool>(true);
    _dailyDishes = ValueNotifier<List<DailyMenuItem>>([]);
  }

  late final ValueNotifier<bool> _dailyExpanded;
  late final ValueNotifier<List<DailyMenuItem>> _dailyDishes;

  ValueNotifier<bool> get dailyExpanded => _dailyExpanded;
  ValueNotifier<List<DailyMenuItem>> get dailyDishes => _dailyDishes;

  void toggleDailyExpanded() {
    _dailyExpanded.value = !_dailyExpanded.value;
  }

  void addDishesToDaily(List<DailyMenuItem> dishes) {
    _dailyDishes.value = [..._dailyDishes.value, ...dishes];
  }

  void updateDishAt(int index, DailyMenuItem updated) {
    final list = List<DailyMenuItem>.from(_dailyDishes.value);
    if (index >= 0 && index < list.length) {
      list[index] = updated;
      _dailyDishes.value = list;
    }
  }

  void removeDishAt(int index) {
    final list = List<DailyMenuItem>.from(_dailyDishes.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      _dailyDishes.value = list;
    }
  }

  void dispose() {
    _dailyExpanded.dispose();
    _dailyDishes.dispose();
  }
}
