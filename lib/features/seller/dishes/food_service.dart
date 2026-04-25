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

  /// Update several foods in one call (`PATCH /v1/food/many`).
  /// Each map in [foods] must include at least `id` and the fields to modify.
  Future<List<DailyMenuItem>> patchFoodsMany({
    required String storeId,
    required List<Map<String, dynamic>> foods,
  }) async {
    final raw = await _client.patchList(
      '/v1/food/many',
      body: <String, dynamic>{'foods': foods},
      headers: <String, String>{'store-id': storeId},
    );
    return raw.map(DailyMenuItem.fromFoodApiMap).toList();
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

  /// Extract dishes from an image (`POST /v1/food/image-scan`).
  Future<List<DailyMenuItem>> scanFoodsFromImage({
    required String storeId,
    required List<int> fileBytes,
    required String filename,
  }) async {
    final data = await _client.postMultipart(
      '/v1/food/image-scan',
      fields: const {},
      fileFieldName: 'image',
      fileBytes: fileBytes,
      filename: filename,
      headers: {'store-id': storeId},
    );

    final rawFoods = data['foods'];
    if (rawFoods is! List) return [];

    return rawFoods
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final name = m['name'] as String? ?? '';
          final type = menuItemTypeFromApi(m['type'] as String?);
          final priceVal = m['price'];
          final price = priceVal is num ? priceVal.toDouble() : null;
          return DailyMenuItem(
            name: name,
            price: price,
            stock: 0,
            isActive: true,
            type: type,
          );
        })
        .where((d) => d.name.trim().isNotEmpty)
        .toList();
  }
}
