import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/seller/orders/orders_model.dart';

class OrdersService {
  OrdersService(this._client);

  final HttpClient _client;

  /// [status] values separated by comma, e.g. `pending,ready,delivered,confirmed`.
  Future<List<SellerOrder>> fetchOrders({
    required String storeId,
    String? status,
  }) {
    return _client.get<List<SellerOrder>>(
      '/v1/order/seller',
      queryParams: (status != null && status.isNotEmpty)
          ? {'status': status}
          : null,
      headers: {'store-id': storeId},
      fromJson: (data) {
        final raw = data['orders'] as List<dynamic>? ?? [];
        return raw
            .map((e) => SellerOrder.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
