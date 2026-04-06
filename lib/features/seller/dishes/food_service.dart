import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class FoodService {
  FoodService(this._client);

  final HttpClient _client;

  /// Publish the daily menu (`date` in format `yyyy-MM-dd`).
  /// Response: `data` as a list of created foods.
  Future<List<Map<String, dynamic>>> publishDailyFood({
    required String storeId,
    required String date,
    required List<DailyMenuItem> foods,
  }) {
    return _client.postList(
      '/v1/food',
      headers: {'store-id': storeId},
      body: {
        'date': date,
        'foods': foods.map((e) => e.toPublishFoodJson()).toList(),
      },
    );
  }

  /// Update a food (`PATCH /v1/food/{id}`), e.g. `isActive`.
  Future<DailyMenuItem> patchFood({
    required String storeId,
    required String foodId,
    required bool isActive,
  }) {
    return _client.patch(
      '/v1/food/$foodId',
      fromJson: DailyMenuItem.fromFoodApiMap,
      body: {'isActive': isActive},
      headers: {'store-id': storeId},
    );
  }
}
