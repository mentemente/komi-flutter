import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/komi_brand_panel.dart';
import 'package:komi_fe/core/widgets/responsive_layout.dart';
import 'package:komi_fe/features/home/widgets/home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _onSearch(BuildContext context, String query) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    final hasPermission = serviceEnabled &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always);
    if (!context.mounted) return;
    if (hasPermission) {
      context.go(RouteNames.restaurants);
    } else {
      context.go(RouteNames.locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ResponsiveLayout(
              mobile: _buildMobileLayout(context),
              desktop: _buildDesktopLayout(context),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => context.go(RouteNames.login),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: AppTextStyles.caption,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Iniciar sesión'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: HomeContent(
            onSearch: (query) => _onSearch(context, query),
            onRegisterPressed: () => context.go(RouteNames.register),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: KomiBrandPanel()),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: HomeContent(
                  onSearch: (query) => _onSearch(context, query),
                  onRegisterPressed: () => context.go(RouteNames.register),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
