import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/location/location_state.dart';

class LocationPermissionMessage extends StatelessWidget {
  const LocationPermissionMessage({
    super.key,
    required this.state,
  });

  final LocationPermissionState state;

  String _message() {
    return switch (state) {
      LocationPermissionInitial() ||
      LocationPermissionLoading() =>
        'Para poder ayudarte a encontrar tu almuerzo, necesitamos que nos des permiso de ubicación.',
      LocationPermissionDenied(:final message) => message.isNotEmpty
          ? message
          : 'Usamos tu ubicación solo para mostrarte opciones cercanas. Sin este permiso, KOMI no puede funcionar correctamente.',
      LocationPermissionGranted() =>
        'Ubicación obtenida correctamente. Revisa la consola para ver los datos.',
      LocationPermissionError(:final message) => message,
    };
  }

  bool get _hasError => state is LocationPermissionError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        _message(),
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: _hasError ? Colors.red.shade700 : AppColors.textDark,
          height: 1.55,
        ),
      ),
    );
  }
}
