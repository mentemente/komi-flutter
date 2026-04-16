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
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final h = local.hour;
  final m = local.minute;
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  final hm = '$h12:${m.toString().padLeft(2, '0')} $period';
  if (day == today) return 'Hoy, $hm';
  final yesterday = today.subtract(const Duration(days: 1));
  if (day == yesterday) return 'Ayer, $hm';
  return '${local.day}/${local.month}/${local.year}, $hm';
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
