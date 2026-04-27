import 'package:flutter/foundation.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

enum DeliveryType { pickup, delivery }

enum PaymentMethod { yapePlin, cash }

@immutable
class CheckoutInput {
  const CheckoutInput({
    required this.menuCart,
    required this.execCounts,
    required this.dishes,
    required this.storeInfo,
    required this.storeId,
    this.userLat = 0.0,
    this.userLng = 0.0,
  });

  final List<MenuCartEntry> menuCart;
  final Map<String, int> execCounts;
  final MenuDishes dishes;
  final StoreMenuInfo storeInfo;
  final String storeId;
  final double userLat;
  final double userLng;

  CheckoutInput copyWith({
    List<MenuCartEntry>? menuCart,
    Map<String, int>? execCounts,
  }) {
    return CheckoutInput(
      menuCart: menuCart ?? this.menuCart,
      execCounts: execCounts ?? this.execCounts,
      dishes: dishes,
      storeInfo: storeInfo,
      storeId: storeId,
      userLat: userLat,
      userLng: userLng,
    );
  }
}

@immutable
class CheckoutState {
  const CheckoutState({
    required this.input,
    required this.deliveryType,
    required this.paymentMethod,
    this.fullName = '',
    this.phone = '',
    this.reference = '',
    this.notes = '',
    this.voucherBytes,
    this.voucherUrl,
    this.isUploadingVoucher = false,
    this.isSubmittingOrder = false,
  });

  factory CheckoutState.initial(CheckoutInput input) {
    final defaultDelivery =
        input.storeInfo.deliveryEnabled && !input.storeInfo.pickupEnabled
            ? DeliveryType.delivery
            : input.storeInfo.pickupEnabled
            ? DeliveryType.pickup
            : DeliveryType.delivery;
    final s = input.storeInfo;
    final defaultPayment = _defaultPaymentMethod(s);
    return CheckoutState(
      input: input,
      deliveryType: defaultDelivery,
      paymentMethod: defaultPayment,
    );
  }

  static PaymentMethod _defaultPaymentMethod(StoreMenuInfo s) {
    if (s.prepaid && s.cashOnDelivery) {
      return PaymentMethod.yapePlin;
    }
    if (s.prepaid) return PaymentMethod.yapePlin;
    if (s.cashOnDelivery) return PaymentMethod.cash;
    return PaymentMethod.yapePlin;
  }

  final CheckoutInput input;
  final DeliveryType deliveryType;
  final PaymentMethod paymentMethod;
  final String fullName;
  final String phone;
  final String reference;
  final String notes;
  final Uint8List? voucherBytes;
  final String? voucherUrl;
  final bool isUploadingVoucher;
  final bool isSubmittingOrder;

  double get subtotal {
    double total = 0;
    for (final e in input.menuCart) {
      total += e.mainCourse.price;
    }
    for (final entry in input.execCounts.entries) {
      DishItem? dish;
      for (final d in input.dishes.executiveDish) {
        if (d.id == entry.key) {
          dish = d;
          break;
        }
      }
      if (dish != null) total += dish.price * entry.value;
    }
    return total;
  }

  double get deliveryCost =>
      deliveryType == DeliveryType.delivery
          ? input.storeInfo.deliveryCost
          : 0;

  double get total => subtotal + deliveryCost;

  bool get hasItems =>
      input.menuCart.isNotEmpty ||
      input.execCounts.values.any((c) => c > 0);

  CheckoutState copyWith({
    CheckoutInput? input,
    DeliveryType? deliveryType,
    PaymentMethod? paymentMethod,
    String? fullName,
    String? phone,
    String? reference,
    String? notes,
    Uint8List? voucherBytes,
    String? voucherUrl,
    bool? isUploadingVoucher,
    bool? isSubmittingOrder,
  }) {
    return CheckoutState(
      input: input ?? this.input,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      voucherBytes: voucherBytes ?? this.voucherBytes,
      voucherUrl: voucherUrl ?? this.voucherUrl,
      isUploadingVoucher: isUploadingVoucher ?? this.isUploadingVoucher,
      isSubmittingOrder: isSubmittingOrder ?? this.isSubmittingOrder,
    );
  }
}
