import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_model.dart';

const String _kApiKey =
    '45b9acda89d0119093fd77ff05b98b4696d982f964f2153ee2616a41af056fe0';

class RestaurantsService {
  RestaurantsService(this._client);

  final HttpClient _client;

  /// POST `/v1/store/nearby` — Lista tiendas cercanas a las coordenadas dadas.
  /// No requires session; uses public `x-api-key`.
  Future<List<NearbyStore>> fetchNearby({
    required double latitude,
    required double longitude,
  }) {
    return _client.post<List<NearbyStore>>(
      '/v1/store/nearby',
      headers: {'x-api-key': _kApiKey},
      body: {
        'coordinates': {'longitude': longitude, 'latitude': latitude},
      },
      fromJson: (data) {
        final raw = data['stores'] as List<dynamic>? ?? [];
        return raw
            .map((e) => NearbyStore.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
