import 'package:flutter/material.dart';
import 'package:komi_fe/features/buyer/location/location_state.dart';

class LocationPermissionIllustration extends StatelessWidget {
  const LocationPermissionIllustration({
    super.key,
    required this.state,
    this.showDenyButton = true,
  });

  final LocationPermissionState state;
  final bool showDenyButton;

  @override
  Widget build(BuildContext context) {
    final isWaiting =
        (state is LocationPermissionInitial ||
            state is LocationPermissionLoading) &&
        showDenyButton;
    final asset = isWaiting
        ? 'assets/images/ollin_esperando.webp'
        : 'assets/images/ollin_ubicacion.webp';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Image.asset(
        asset,
        key: ValueKey('$showDenyButton-${state.runtimeType}'),
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }
}
