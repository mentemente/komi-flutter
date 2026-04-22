import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_state.dart';
import 'package:komi_fe/features/buyer/checkout/order_service.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState?>(
  CheckoutNotifier.new,
);

class CheckoutNotifier extends Notifier<CheckoutState?> {
  @override
  CheckoutState? build() => null;

  void initialize(CheckoutInput input) {
    state = CheckoutState.initial(input);
  }

  void setDeliveryType(DeliveryType type) {
    state = state?.copyWith(deliveryType: type);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state?.copyWith(paymentMethod: method);
  }

  void updateFormField({
    String? fullName,
    String? phone,
    String? reference,
    String? notes,
  }) {
    state = state?.copyWith(
      fullName: fullName,
      phone: phone,
      reference: reference,
      notes: notes,
    );
  }

  void setVoucherLocalBytes(Uint8List bytes) {
    state = state?.copyWith(voucherBytes: bytes);
  }

  void setVoucherUploading(bool uploading) {
    state = state?.copyWith(isUploadingVoucher: uploading);
  }

  void setVoucherUploadedUrl(String url) {
    state = state?.copyWith(voucherUrl: url, isUploadingVoucher: false);
  }

  void clearVoucher() {
    state = state?.copyWith(
      voucherBytes: null,
      voucherUrl: null,
      isUploadingVoucher: false,
    );
  }

  void removeMenuEntry(String mainCourseId) {
    final current = state;
    if (current == null) return;
    final menuCart = List<MenuCartEntry>.from(current.input.menuCart);
    final idx = menuCart.lastIndexWhere((e) => e.mainCourse.id == mainCourseId);
    if (idx != -1) menuCart.removeAt(idx);
    state = current.copyWith(input: current.input.copyWith(menuCart: menuCart));
  }

  void decrementExecDish(String dishId) {
    final current = state;
    if (current == null) return;
    final counts = Map<String, int>.from(current.input.execCounts);
    final cur = counts[dishId] ?? 0;
    if (cur > 1) {
      counts[dishId] = cur - 1;
    } else {
      counts.remove(dishId);
    }
    state = current.copyWith(input: current.input.copyWith(execCounts: counts));
  }

  void setSubmittingOrder(bool value) {
    state = state?.copyWith(isSubmittingOrder: value);
  }

  Future<OrderResult> submitOrder() async {
    final current = state;
    if (current == null) throw Exception('Estado de checkout inválido');
    state = current.copyWith(isSubmittingOrder: true);
    try {
      final result = await ServiceLocator.orderService.createOrder(current);
      state = state?.copyWith(isSubmittingOrder: false);
      return result;
    } catch (_) {
      state = state?.copyWith(isSubmittingOrder: false);
      rethrow;
    }
  }

  void reset() => state = null;
}
