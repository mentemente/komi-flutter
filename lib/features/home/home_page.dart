import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/komi_brand_panel.dart';
import 'package:komi_fe/core/widgets/logout_button.dart';
import 'package:komi_fe/core/widgets/responsive_layout.dart';
import 'package:komi_fe/features/buyer/location/location_flow.dart';
import 'package:komi_fe/features/home/widgets/home_content.dart';
import 'package:komi_fe/features/home/widgets/home_top_session_slot.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _onSearch(BuildContext context, String query) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const CircularProgressIndicator(color: AppColors.primary)],
        ),
      ),
    );

    var ok = false;
    try {
      ok = await ensureLocationPermissionForRestaurants();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (!context.mounted) return;

    if (ok) {
      context.go(RouteNames.restaurants);
    } else {
      context.go(RouteNames.locationPermission);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(authSessionProvider) == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context, isGuest),
          desktop: _buildDesktopLayout(context, isGuest),
        ),
      ),
    );
  }

  Widget _buildLoginBar(BuildContext context, EdgeInsets padding) {
    return HomeTopSessionSlot(
      padding: padding,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.caption,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onPressed: () => context.go(RouteNames.login),
        child: const Text('Iniciar sesión'),
      ),
    );
  }

  Widget _buildLogoutBar(EdgeInsets padding) {
    return HomeTopSessionSlot(
      padding: padding,
      child: const LogoutButton(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isGuest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isGuest)
          _buildLoginBar(context, HomeTopSessionSlot.paddingMobile)
        else
          _buildLogoutBar(HomeTopSessionSlot.paddingMobile),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: HomeContent(
                  onSearch: (query) => _onSearch(context, query),
                  onRegisterPressed: () => context.go(RouteNames.register),
                  showGuestCta: isGuest,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isGuest) {
    return Row(
      children: [
        Expanded(child: KomiBrandPanel()),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isGuest)
                _buildLoginBar(context, HomeTopSessionSlot.paddingDesktop)
              else
                _buildLogoutBar(HomeTopSessionSlot.paddingDesktop),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: HomeContent(
                        onSearch: (query) => _onSearch(context, query),
                        onRegisterPressed: () =>
                            context.go(RouteNames.register),
                        showGuestCta: isGuest,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
