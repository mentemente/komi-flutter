import 'package:komi_fe/core/network/http_client.dart';

class StoreService {
  StoreService(this._client);

  final HttpClient _client;

  Future<Map<String, dynamic>> createStore({
    required String name,
    required String description,
    required String paymentQr,
    required List<Map<String, dynamic>> schedules,
    required bool pickupEnabled,
    required bool deliveryEnabled,
    required double deliveryCost,
    required Map<String, bool> payments,
    required double latitude,
    required double longitude,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/v1/store',
      fromJson: (json) => json,
      body: {
        'name': name,
        'description': description,
        'paymentQr': paymentQr,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'schedules': schedules,
        'pickupEnabled': pickupEnabled,
        'deliveryEnabled': deliveryEnabled,
        'deliveryCost': deliveryCost,
        'payments': payments,
      },
    );
  }
}
