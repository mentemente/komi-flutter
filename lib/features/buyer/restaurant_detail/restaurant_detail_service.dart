import 'package:komi_fe/core/config/app_config.dart';
import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

class RestaurantDetailService {
  RestaurantDetailService(this._client);

  final HttpClient _client;

  /// GET `/v1/store/menu?store-id=[storeId]` — Menú del día con platos agrupados.
  Future<StoreMenu> fetchMenu(String storeId) {
    return _client.get<StoreMenu>(
      '/v1/store/menu',
      headers: {'x-api-key': AppConfig.xApiKey},
      queryParams: {'store-id': storeId.trim()},
      fromJson: StoreMenu.fromJson,
    );
  }
}
