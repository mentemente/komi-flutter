import 'package:komi_fe/core/widgets/order_card.dart';

class SellerOrderItem {
  final String name;
  final double price;
  final String type;

  const SellerOrderItem({
    required this.name,
    required this.price,
    required this.type,
  });

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    return SellerOrderItem(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? '',
    );
  }
}

class SellerOrderCombo {
  final String type;
  final List<SellerOrderItem> items;

  const SellerOrderCombo({required this.type, required this.items});

  factory SellerOrderCombo.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SellerOrderCombo(
      type: json['type'] as String? ?? '',
      items: rawItems
          .map((e) => SellerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SellerOrder {
  final String id;
  final OrderStatus status;
  final DeliveryType deliveryType;
  final String paymentCondition;
  final double total;
  final String fullName;
  final List<SellerOrderCombo> combos;
  final String buyerPhone;
  final String? paymentImageUrl;
  final DateTime createdAt;

  const SellerOrder({
    required this.id,
    required this.status,
    required this.deliveryType,
    required this.paymentCondition,
    required this.total,
    required this.fullName,
    required this.combos,
    required this.buyerPhone,
    this.paymentImageUrl,
    required this.createdAt,
  });

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final rawCombos = json['combos'] as List<dynamic>? ?? [];
    return SellerOrder(
      id: json['id'] as String? ?? '',
      status: OrderStatus.fromApi(json['status'] as String?),
      deliveryType: _deliveryTypeFromApi(json['deliveryType'] as String?),
      paymentCondition: json['paymentCondition'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      fullName: json['fullName'] as String? ?? '',
      combos: rawCombos
          .map((e) => SellerOrderCombo.fromJson(e as Map<String, dynamic>))
          .toList(),
      buyerPhone: json['buyerPhone'] as String? ?? '',
      paymentImageUrl: json['paymentImageUrl'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  OrderCardData toCardData() {
    return OrderCardData(
      customerName: fullName,
      deliveryType: deliveryType,
      paymentMethods: _paymentMethods(),
      amount: total,
      timeAgo: _timeAgo(),
      status: status,
      orderNumber: id.length > 8
          ? id.substring(id.length - 8).toUpperCase()
          : id.toUpperCase(),
      dishes: _dishes(),
    );
  }

  List<String> _paymentMethods() {
    switch (paymentCondition) {
      case 'prepaid':
        return ['yape_plin'];
      case 'cash_on_delivery':
        return ['cash'];
      default:
        return [];
    }
  }

  List<OrderDish> _dishes() {
    final result = <OrderDish>[];
    for (final combo in combos) {
      for (final item in combo.items) {
        result.add(OrderDish(name: item.name, quantity: 1));
      }
    }
    return result;
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }
}

DeliveryType _deliveryTypeFromApi(String? raw) {
  switch (raw) {
    case 'delivery':
      return DeliveryType.delivery;
    case 'pickup':
    default:
      return DeliveryType.pickup;
  }
}
