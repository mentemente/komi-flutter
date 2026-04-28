import 'package:komi_fe/features/seller/configuration/models/seller_store_model.dart';

sealed class StoreConfigurationState {
  const StoreConfigurationState();
}

final class StoreConfigurationInitial extends StoreConfigurationState {
  const StoreConfigurationInitial();
}

final class StoreConfigurationLoading extends StoreConfigurationState {
  const StoreConfigurationLoading();
}

final class StoreConfigurationError extends StoreConfigurationState {
  const StoreConfigurationError(this.message);
  final String message;
}

final class StoreConfigurationReady extends StoreConfigurationState {
  const StoreConfigurationReady(this.store);
  final SellerStore store;
}
