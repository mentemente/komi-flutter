import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';

class CustomerOrdersService {
  CustomerOrdersService(this._client);

  final HttpClient _client;

  /// Default active statuses (orders in progress).
  static const String defaultStatusQuery = 'pending,ready,delivered,confirmed';

  /// GET [GET /v1/order/buyer](?status=...). Requires buyer session (`Authorization`).
  Future<List<BuyerOrder>> fetchOrders({String? status}) {
    if (!_client.hasBearerToken) {
      throw const ApiException(
        code: 'NO_SESSION',
        status: 401,
        message: 'Inicia sesión para ver tus pedidos.',
      );
    }
    return _client.get<List<BuyerOrder>>(
      '/v1/order/buyer',
      queryParams: {
        'status': status?.trim().isNotEmpty == true
            ? status!.trim()
            : defaultStatusQuery,
      },
      fromJson: (data) {
        final raw = data['orders'] as List<dynamic>? ?? [];
        return raw
            .map((e) => BuyerOrder.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// GET `/v1/order/buyer/:id` — order detail. Requires buyer session.
  Future<BuyerOrder> fetchOrderById(String orderId) {
    if (!_client.hasBearerToken) {
      throw const ApiException(
        code: 'NO_SESSION',
        status: 401,
        message: 'Inicia sesión para ver el detalle del pedido.',
      );
    }
    final id = orderId.trim();
    return _client.get<BuyerOrder>(
      '/v1/order/buyer/$id',
      fromJson: BuyerOrder.fromJson,
    );
  }
}
