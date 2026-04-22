import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_service.dart';
import 'package:komi_fe/features/seller/dishes/food_service.dart';

/// Access to overview data: list of daily menu and update of dishes.
class OverviewService {
  OverviewService(this._dailyMenu, this._food);

  final DailyMenuService _dailyMenu;
  final FoodService _food;

  Future<List<DailyMenuItem>> listMenuFoods({required String storeId}) {
    return _dailyMenu.listFoods(storeId: storeId);
  }

  Future<DailyMenuItem> patchFoodActive({
    required String storeId,
    required String foodId,
    required bool isActive,
  }) {
    return _food.patchFood(
      storeId: storeId,
      foodId: foodId,
      isActive: isActive,
    );
  }
}
