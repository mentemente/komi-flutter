import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

const String _kApiKey =
    '45b9acda89d0119093fd77ff05b98b4696d982f964f2153ee2616a41af056fe0';

class RestaurantDetailService {
  RestaurantDetailService(this._client);

  final HttpClient _client;

  /// GET `/v1/store/menu?store-id=[storeId]` — Menú del día con platos agrupados.
  Future<StoreMenu> fetchMenu(String storeId) {
    return _client.get<StoreMenu>(
      '/v1/store/menu',
      headers: {'x-api-key': _kApiKey},
      queryParams: {'store-id': storeId.trim()},
      fromJson: StoreMenu.fromJson,
    );
  }
}
