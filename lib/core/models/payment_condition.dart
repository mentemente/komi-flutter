import 'package:flutter/material.dart';

/// Values of `paymentCondition` in the orders API (`prepaid`, `cash_on_delivery`).
abstract final class OrderPaymentCondition {
  OrderPaymentCondition._();
  static const prepaid = 'prepaid';
  static const cashOnDelivery = 'cash_on_delivery';
}

String _normalizePaymentCondition(String? raw) =>
    raw?.trim().toLowerCase() ?? '';

IconData orderDetailPaymentIcon(String condition) {
  switch (_normalizePaymentCondition(condition)) {
    case OrderPaymentCondition.prepaid:
      return Icons.phone_android_rounded;
    case OrderPaymentCondition.cashOnDelivery:
      return Icons.payments_outlined;
    default:
      return Icons.payment_rounded;
  }
}

String orderDetailPaymentLabel(String condition) {
  switch (_normalizePaymentCondition(condition)) {
    case OrderPaymentCondition.prepaid:
      return 'Yape / Plin';
    case OrderPaymentCondition.cashOnDelivery:
      return 'Contra entrega';
    default:
      return condition.trim().isEmpty ? 'Pago' : condition;
  }
}
