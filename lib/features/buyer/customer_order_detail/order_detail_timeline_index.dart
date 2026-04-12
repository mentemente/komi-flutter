import 'package:komi_fe/core/widgets/order_card.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_timeline.dart';

/// Timeline steps in detail: **4** for pickup, **5** for delivery.
List<OrderDetailTimelineStep> buyerOrderTimelineSteps(
  DeliveryType deliveryType,
) {
  if (deliveryType == DeliveryType.pickup) {
    return const [
      OrderDetailTimelineStep(
        title: 'Pendiente',
        subtitle: 'Espera un momento',
      ),
      OrderDetailTimelineStep(
        title: 'Confirmado',
        subtitle: 'Tu pedido fue confirmado',
      ),
      OrderDetailTimelineStep(
        title: 'Listo',
        subtitle: 'Puedes pasar a recoger',
      ),
      OrderDetailTimelineStep(
        title: 'Completado',
        subtitle: 'Disfruta tu comida',
      ),
    ];
  }

  return const [
    OrderDetailTimelineStep(title: 'Pendiente', subtitle: 'Espera un momento'),
    OrderDetailTimelineStep(
      title: 'Pagado',
      subtitle: 'Tu pago ha sido confirmado!',
    ),
    OrderDetailTimelineStep(
      title: 'Listo',
      subtitle: 'Tu pedido salió de cocina',
    ),
    OrderDetailTimelineStep(
      title: 'En camino',
      subtitle: 'Tu pedido está en camino',
    ),
    OrderDetailTimelineStep(
      title: 'Completado',
      subtitle: 'Disfruta tu comida',
    ),
  ];
}

/// Índice del paso activo según estado y tipo de entrega (alineado con [customerOrderProgress]).
int buyerOrderTimelineActiveIndex({
  required OrderStatus status,
  required DeliveryType deliveryType,
}) {
  if (status == OrderStatus.cancelled) return 0;

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
        return 0;
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
      return 0;
  }
}
