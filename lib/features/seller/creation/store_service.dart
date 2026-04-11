import 'package:komi_fe/core/network/http_client.dart';

class StoreService {
  StoreService(this._client);

  final HttpClient _client;

  static const Map<String, double> testLocation = {
    'latitude': -12.0454,
    'longitude': -77.0428,
  };

  Future<Map<String, dynamic>> createStore({
    required String name,
    required String description,
    required String paymentQr,
    required List<Map<String, dynamic>> schedules,
    required bool pickupEnabled,
    required bool deliveryEnabled,
    required double deliveryCost,
    required Map<String, bool> payments,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/v1/store',
      fromJson: (json) => json,
      body: {
        'name': name,
        'description': description,
        'paymentQr': paymentQr,
        'location': testLocation,
        'schedules': schedules,
        'pickupEnabled': pickupEnabled,
        'deliveryEnabled': deliveryEnabled,
        'deliveryCost': deliveryCost,
        'payments': payments,
      },
    );
  }
}
