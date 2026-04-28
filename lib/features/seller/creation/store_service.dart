import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/seller/configuration/models/seller_store_model.dart';

class StoreService {
  StoreService(this._client);

  final HttpClient _client;

  /// GET `/v1/store/:id` — store detail (seller authenticated).
  Future<SellerStore> getStoreById(String storeId) {
    final id = storeId.trim();
    return _client.get<SellerStore>(
      '/v1/store/${Uri.encodeComponent(id)}',
      fromJson: SellerStore.fromJson,
    );
  }

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
        'location': {'latitude': latitude, 'longitude': longitude},
        'schedules': schedules,
        'pickupEnabled': pickupEnabled,
        'deliveryEnabled': deliveryEnabled,
        'deliveryCost': deliveryCost,
        'payments': payments,
      },
    );
  }

  /// PATCH `/v1/store/:id` — update store configuration (seller authenticated).
  Future<SellerStore> patchStore({
    required String storeId,
    required List<Map<String, dynamic>> schedules,
    required bool pickupEnabled,
    required bool deliveryEnabled,
    required double deliveryCost,
    required bool cashOnDelivery,
    required bool prepaid,
    required double latitude,
    required double longitude,
    String? paymentQr,
  }) {
    final id = storeId.trim();
    final body = <String, dynamic>{
      'schedules': schedules,
      'payments': {'cashOnDelivery': cashOnDelivery, 'prepaid': prepaid},
      'deliveryCost': deliveryCost,
      'pickupEnabled': pickupEnabled,
      'deliveryEnabled': deliveryEnabled,
      'location': {
        'type': 'Point',
        'coordinates': {'lat': latitude, 'lng': longitude},
      },
    };
    final qr = paymentQr?.trim();
    if (qr != null && qr.isNotEmpty) {
      body['paymentQr'] = qr;
    }
    return _client.patch<SellerStore>(
      '/v1/store/${Uri.encodeComponent(id)}',
      fromJson: SellerStore.fromJson,
      body: body,
    );
  }
}
