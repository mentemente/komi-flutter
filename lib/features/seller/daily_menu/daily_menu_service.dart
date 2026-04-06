import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class DailyMenuService {
  DailyMenuService(this._client);

  final HttpClient _client;

  /// List food items (`GET /v1/food`).
  Future<List<DailyMenuItem>> listFoods({required String storeId}) async {
    final raw = await _client.getList(
      '/v1/food',
      headers: {'store-id': storeId},
    );
    return raw.map(DailyMenuItem.fromFoodApiMap).toList();
  }

  /// Unique foods from previous menus (`GET /v1/food/prev/unique`).
  Future<List<Map<String, dynamic>>> listPreviousUniqueFoods({
    required String storeId,
  }) {
    return _client.getList(
      '/v1/food/prev/unique',
      headers: {'store-id': storeId},
    );
  }
}
