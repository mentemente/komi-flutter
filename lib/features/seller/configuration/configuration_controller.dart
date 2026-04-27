import 'package:flutter/foundation.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/seller/configuration/configuration_state.dart';
import 'package:komi_fe/features/seller/creation/store_service.dart';

class StoreConfigurationController {
  StoreConfigurationController(this._storeService);

  final StoreService _storeService;
  final ValueNotifier<ConfigurationState> state = ValueNotifier(
    ConfigurationInitial(),
  );

  Future<void> load(String storeId) async {
    if (storeId.isEmpty) {
      state.value = ConfigurationError('No hay una tienda asociada a tu cuenta');
      return;
    }
    state.value = ConfigurationLoading();
    try {
      final s = await _storeService.getStoreById(storeId);
      state.value = ConfigurationReady(s);
    } on ApiException catch (e) {
      state.value = ConfigurationError(e.message);
    } catch (_) {
      state.value = ConfigurationError('No se pudo cargar la tienda. Intenta de nuevo.');
    }
  }

  void dispose() {
    state.dispose();
  }
}
