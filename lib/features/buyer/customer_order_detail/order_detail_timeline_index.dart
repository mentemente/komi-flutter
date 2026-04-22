import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_timeline.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_model.dart';

/// Builds timeline steps for a cancelled order.
/// Only includes steps that were actually reached (have timestamps),
/// then appends the Cancelado step at the end.
List<OrderDetailTimelineStep> _cancelledSteps(BuyerOrder order) {
  final steps = <OrderDetailTimelineStep>[
    OrderDetailTimelineStep(
      title: 'Pendiente',
      subtitle: 'Espera un momento',
      dateTime: order.createdAt,
    ),
    if (order.confirmedAt != null)
      OrderDetailTimelineStep(
        title: 'Confirmado',
        subtitle: 'Tu pedido fue confirmado',
        dateTime: order.confirmedAt,
      ),
    if (order.readyAt != null)
      OrderDetailTimelineStep(
        title: 'Listo',
        subtitle: order.deliveryType == DeliveryType.pickup
            ? 'Puedes pasar a recoger'
            : 'Tu pedido está listo para entregar',
        dateTime: order.readyAt,
      ),
    if (order.deliveryType == DeliveryType.delivery && order.deliveredAt != null)
      OrderDetailTimelineStep(
        title: 'En camino',
        subtitle: 'Tu pedido está en camino',
        dateTime: order.deliveredAt,
      ),
    OrderDetailTimelineStep(
      title: 'Cancelado',
      subtitle: 'Tu pedido fue cancelado',
      dateTime: order.cancelledAt,
      isCancelled: true,
      cancelledReason: order.cancelledReason,
    ),
  ];
  return steps;
}

/// Timeline steps in detail: **4** for pickup, **5** for delivery.
List<OrderDetailTimelineStep> buyerOrderTimelineSteps(BuyerOrder order) {
  if (order.status == OrderStatus.cancelled) {
    return _cancelledSteps(order);
  }

  if (order.deliveryType == DeliveryType.pickup) {
    return [
      OrderDetailTimelineStep(
        title: 'Pendiente',
        subtitle: 'Espera un momento',
        dateTime: order.createdAt,
      ),
      OrderDetailTimelineStep(
        title: 'Confirmado',
        subtitle: 'Tu pedido fue confirmado',
        dateTime: order.confirmedAt,
      ),
      OrderDetailTimelineStep(
        title: 'Listo',
        subtitle: 'Puedes pasar a recoger',
        dateTime: order.readyAt,
      ),
      OrderDetailTimelineStep(
        title: 'Completado',
        subtitle: 'Disfruta tu comida',
        dateTime: order.completedAt,
      ),
    ];
  }

  return [
    OrderDetailTimelineStep(
      title: 'Pendiente',
      subtitle: 'Espera un momento',
      dateTime: order.createdAt,
    ),
    OrderDetailTimelineStep(
      title: 'Confirmado',
      subtitle: 'Tu pedido fue confirmado',
      dateTime: order.confirmedAt,
    ),
    OrderDetailTimelineStep(
      title: 'Listo',
      subtitle: 'Tu pedido está listo para entregar',
      dateTime: order.readyAt,
    ),
    OrderDetailTimelineStep(
      title: 'En camino',
      subtitle: 'Tu pedido está en camino',
      dateTime: order.deliveredAt,
    ),
    OrderDetailTimelineStep(
      title: 'Completado',
      subtitle: 'Disfruta tu comida',
      dateTime: order.completedAt,
    ),
  ];
}

int buyerOrderTimelineActiveIndex({
  required OrderStatus status,
  required DeliveryType deliveryType,
  required int stepsCount,
}) {
  if (status == OrderStatus.cancelled) return stepsCount - 1;

  if (deliveryType == DeliveryType.pickup) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.ready:
      case OrderStatus.delivered:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return stepsCount - 1;
    }
  }

  switch (status) {
    case OrderStatus.pending:
      return 0;
    case OrderStatus.confirmed:
      return 1;
    case OrderStatus.ready:
      return 2;
    case OrderStatus.delivered:
      return 3;
    case OrderStatus.completed:
      return 4;
    case OrderStatus.cancelled:
      return stepsCount - 1;
  }
}
