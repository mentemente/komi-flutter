import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/store_configuration_state.dart';
import 'package:komi_fe/features/seller/creation/store_service.dart';

class StoreConfigurationController {
  StoreConfigurationController(this._storeService);

  final StoreService _storeService;
  final ValueNotifier<StoreConfigurationState> state = ValueNotifier(
    const StoreConfigurationInitial(),
  );

  Future<void> load(String storeId) async {
    if (storeId.isEmpty) {
      state.value = const StoreConfigurationError(
        'No hay una tienda asociada a tu cuenta',
      );
      return;
    }
    state.value = const StoreConfigurationLoading();
    try {
      final s = await _storeService.getStoreById(storeId);
      state.value = StoreConfigurationReady(s);
    } on ApiException catch (e) {
      state.value = StoreConfigurationError(e.message);
    } catch (_) {
      state.value = const StoreConfigurationError(
        'No se pudo cargar la tienda. Intenta de nuevo.',
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
