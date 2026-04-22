import 'package:komi_fe/core/widgets/order_card.dart';

/// Progress of the bar (0–1) according to [deliveryType] and [OrderStatus].
///
/// **Pickup:** PENDING 25% → CONFIRMED 50% → READY 75% → COMPLETED 100%
///
/// **Delivery:** PENDING 20% → CONFIRMED 40% → READY 60% → DELIVERED 80% → COMPLETED 100%
///
/// If `delivered` appears in pickup, it is treated as 75% (same stage as ready).
double customerOrderProgress({
  required DeliveryType deliveryType,
  required OrderStatus status,
}) {
  if (status == OrderStatus.cancelled) return 0;

  if (deliveryType == DeliveryType.pickup) {
    switch (status) {
      case OrderStatus.pending:
        return 0.25;
      case OrderStatus.confirmed:
        return 0.50;
      case OrderStatus.ready:
      case OrderStatus.delivered:
        return 0.75;
      case OrderStatus.completed:
        return 1.0;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  switch (status) {
    case OrderStatus.pending:
      return 0.20;
    case OrderStatus.confirmed:
      return 0.40;
    case OrderStatus.ready:
      return 0.60;
    case OrderStatus.delivered:
      return 0.80;
    case OrderStatus.completed:
      return 1.0;
    case OrderStatus.cancelled:
      return 0;
  }
}
