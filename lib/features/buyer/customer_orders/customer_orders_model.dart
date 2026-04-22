import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/features/seller/orders/orders_model.dart';
import 'package:komi_fe/features/buyer/customer_orders/widgets/customer_order_card.dart';

DeliveryType _deliveryTypeFromApi(String? raw) {
  switch (raw) {
    case 'delivery':
      return DeliveryType.delivery;
    case 'pickup':
    default:
      return DeliveryType.pickup;
  }
}

String _formatOrderDateTime(DateTime at) {
  final local = at.toLocal();
  final now = DateTime.now();
  var diff = now.difference(local);
  if (diff.isNegative) diff = Duration.zero;

  final minutes = diff.inMinutes;
  if (minutes < 60) {
    final m = minutes <= 0 ? 1 : minutes;
    return 'Hace $m min';
  }

  final hours = diff.inHours;
  if (hours < 24) {
    return hours == 1 ? 'Hace 1 hora' : 'Hace $hours horas';
  }

  final days = diff.inDays;
  return days == 1 ? 'Hace 1 día' : 'Hace $days días';
}

class BuyerOrder {
  const BuyerOrder({
    required this.id,
    required this.status,
    required this.deliveryType,
    required this.paymentCondition,
    required this.total,
    required this.fullName,
    required this.storeName,
    required this.combos,
    required this.createdAt,
    this.notes,
    this.addressReference,
    this.buyerPhone,
    this.paymentImageUrl,
    this.coordLat,
    this.coordLng,
    this.confirmedAt,
    this.readyAt,
    this.deliveredAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledReason,
  });

  final String id;
  final OrderStatus status;
  final DeliveryType deliveryType;
  final String paymentCondition;
  final double total;
  final String fullName;
  final String storeName;
  final List<SellerOrderCombo> combos;
  final DateTime createdAt;

  final String? notes;
  final String? addressReference;
  final String? buyerPhone;
  final String? paymentImageUrl;
  final double? coordLat;
  final double? coordLng;
  final DateTime? confirmedAt;
  final DateTime? readyAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelledReason;

  factory BuyerOrder.fromJson(Map<String, dynamic> json) {
    final rawCombos = json['combos'] as List<dynamic>? ?? [];
    final coords = json['coordinates'] as Map<String, dynamic>?;
    return BuyerOrder(
      id: json['id'] as String? ?? '',
      status: OrderStatus.fromApi(json['status'] as String?),
      deliveryType: _deliveryTypeFromApi(json['deliveryType'] as String?),
      paymentCondition: (json['paymentCondition'] as String? ?? '').trim(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      fullName: json['fullName'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      combos: rawCombos
          .map((e) => SellerOrderCombo.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String?,
      addressReference: json['addressReference'] as String?,
      buyerPhone: json['buyerPhone'] as String?,
      paymentImageUrl: json['paymentImageUrl'] as String?,
      coordLat: (coords?['lat'] as num?)?.toDouble(),
      coordLng: (coords?['lng'] as num?)?.toDouble(),
      confirmedAt: _parseDate(json['confirmedAt'] as String?),
      readyAt: _parseDate(json['readyAt'] as String?),
      deliveredAt: _parseDate(json['deliveredAt'] as String?),
      completedAt: _parseDate(json['completedAt'] as String?),
      cancelledAt: _parseDate(json['cancelledAt'] as String?),
      cancelledReason: json['cancelledReason'] as String?,
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  CustomerOrderCardData toCardData() {
    final subtitle = fullName.trim().isNotEmpty ? 'A nombre de: $fullName' : '';
    return CustomerOrderCardData(
      orderId: id,
      title: storeName.trim().isNotEmpty ? storeName : 'Restaurante',
      address: subtitle,
      deliveryType: deliveryType,
      paymentCondition: paymentCondition,
      status: status,
      dateTimeLabel: _formatOrderDateTime(createdAt),
      priceLabel: 's/${total.toStringAsFixed(0)}',
    );
  }
}

extension BuyerOrderPricing on BuyerOrder {
  double get combosItemsSubtotal {
    var sum = 0.0;
    for (final combo in combos) {
      for (final item in combo.items) {
        sum += item.price;
      }
    }
    return sum;
  }

  double? get inferredDeliveryFee {
    if (deliveryType != DeliveryType.delivery) return null;
    final sub = combosItemsSubtotal;
    final diff = total - sub;
    if (diff < -0.05) return null;
    return diff < 0 ? 0.0 : diff;
  }
}
