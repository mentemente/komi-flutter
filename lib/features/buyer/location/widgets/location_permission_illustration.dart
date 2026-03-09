import 'package:flutter/material.dart';
import 'package:komi_fe/features/buyer/location/location_state.dart';

class LocationPermissionIllustration extends StatelessWidget {
  const LocationPermissionIllustration({
    super.key,
    required this.state,
  });

  final LocationPermissionState state;

  @override
  Widget build(BuildContext context) {
    final isInitial = state is LocationPermissionInitial ||
        state is LocationPermissionLoading;
    final asset = isInitial
        ? 'assets/images/ollin_esperando.webp'
        : 'assets/images/ollin_ubicacion.webp';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Image.asset(
        asset,
        key: ValueKey(state.runtimeType),
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }
}
