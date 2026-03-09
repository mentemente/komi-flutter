import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/features/buyer/location/location_controller.dart';
import 'package:komi_fe/features/buyer/location/location_service.dart';
import 'package:komi_fe/features/buyer/location/location_state.dart';
import 'package:komi_fe/features/buyer/location/widgets/location_permission_actions.dart';
import 'package:komi_fe/features/buyer/location/widgets/location_permission_header.dart';
import 'package:komi_fe/features/buyer/location/widgets/location_permission_illustration.dart';
import 'package:komi_fe/features/buyer/location/widgets/location_permission_message.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() =>
      _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  late final LocationPermissionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocationPermissionController(
      service: LocationService(),
      onNavigateToRestaurants: () {
        if (mounted) context.go(RouteNames.restaurants);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBack() {
    final state = _controller.state.value;
    if (state is LocationPermissionDenied) {
      _controller.resetToInitial();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocationPermissionState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LocationPermissionHeader(onBack: _onBack),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LocationPermissionIllustration(state: state),
                          const SizedBox(height: 24),
                          LocationPermissionMessage(state: state),
                        ],
                      ),
                    ),
                  ),
                ),
                LocationPermissionActions(
                  state: state,
                  onGrantPermission: _controller.requestPermission,
                  onDenyPermission: _controller.denyPermission,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
