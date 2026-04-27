import 'package:komi_fe/features/seller/configuration/seller_store_model.dart';

sealed class ConfigurationState {}

class ConfigurationInitial extends ConfigurationState {}

class ConfigurationLoading extends ConfigurationState {}

class ConfigurationError extends ConfigurationState {
  ConfigurationError(this.message);
  final String message;
}

class ConfigurationReady extends ConfigurationState {
  ConfigurationReady(this.store);
  final SellerStore store;
}
