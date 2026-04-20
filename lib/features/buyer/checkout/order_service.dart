import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_state.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

class OrderResult {
  const OrderResult({required this.id, required this.status});

  final String id;
  final String status;

  factory OrderResult.fromJson(Map<String, dynamic> json) => OrderResult(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? '',
  );
}

class OrderService {
  OrderService(this._client);

  final HttpClient _client;

  Future<OrderResult> createOrder(CheckoutState checkout) {
    return _client.post(
      '/v1/order',
      fromJson: OrderResult.fromJson,
      body: _buildBody(checkout),
    );
  }

  Map<String, dynamic> _buildBody(CheckoutState checkout) {
    final input = checkout.input;
    final combos = <Map<String, dynamic>>[];

    // Cada MenuCartEntry → un combo tipo "menu"
    for (final entry in input.menuCart) {
      final items = <Map<String, dynamic>>[
        _dishItem(entry.mainCourse, 'main_course'),
        if (entry.appetizer != null) _dishItem(entry.appetizer!, 'appetizer'),
        if (entry.beverage != null) _dishItem(entry.beverage!, 'beverage'),
        if (entry.dessert != null) _dishItem(entry.dessert!, 'dessert'),
      ];
      combos.add({'type': 'menu', 'items': items});
    }

    // Platos a la carta → un combo por unidad
    for (final entry in input.execCounts.entries) {
      final count = entry.value;
      if (count <= 0) continue;
      DishItem? dish;
      for (final d in input.dishes.executiveDish) {
        if (d.id == entry.key) {
          dish = d;
          break;
        }
      }
      if (dish == null) continue;
      for (var i = 0; i < count; i++) {
        combos.add({
          'type': 'executive',
          'items': [_dishItem(dish, 'executive_dish')],
        });
      }
    }

    final isYape = checkout.paymentMethod == PaymentMethod.yapePlin;

    final body = <String, dynamic>{
      'storeId': input.storeId,
      'deliveryType': checkout.deliveryType == DeliveryType.delivery
          ? 'delivery'
          : 'pickup',
      'paymentCondition': isYape ? 'prepaid' : 'cash_on_delivery',
      'combos': combos,
      'total': checkout.total,
      'fullName': checkout.fullName,
      'buyerPhone': checkout.phone,
      'coordinates': {'lat': input.userLat, 'lng': input.userLng},
    };

    if (checkout.notes.isNotEmpty) body['notes'] = checkout.notes;
    if (checkout.reference.isNotEmpty) {
      body['addressReference'] = checkout.reference;
    }
    if (isYape && (checkout.voucherUrl?.isNotEmpty ?? false)) {
      body['paymentImageUrl'] = checkout.voucherUrl;
    }

    return body;
  }

  Map<String, dynamic> _dishItem(DishItem dish, String type) => {
    'foodId': dish.id,
    'name': dish.name,
    'price': dish.price,
    'type': type,
  };
}
