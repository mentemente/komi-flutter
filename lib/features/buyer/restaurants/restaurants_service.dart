import 'package:komi_fe/core/config/app_config.dart';
import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_model.dart';

class RestaurantsService {
  RestaurantsService(this._client);

  final HttpClient _client;

  /// POST `/v1/store/nearby` — Lista tiendas cercanas a las coordenadas dadas.
  /// No requires session; uses public `x-api-key`.
  Future<List<NearbyStore>> fetchNearby({
    required double latitude,
    required double longitude,
    String? searchText,
  }) {
    final body = <String, dynamic>{
      'coordinates': {'longitude': longitude, 'latitude': latitude},
    };
    final t = searchText?.trim();
    if (t != null && t.isNotEmpty) {
      body['searchText'] = t;
    }
    return _client.post<List<NearbyStore>>(
      '/v1/store/nearby',
      headers: {'x-api-key': AppConfig.xApiKey},
      body: body,
      fromJson: (data) {
        final raw = data['stores'] as List<dynamic>? ?? [];
        return raw
            .map((e) => NearbyStore.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
