import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/widgets/logo.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';

class LocationPermissionHeader extends StatelessWidget {
  const LocationPermissionHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  void _goBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _goBack(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textDark,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.25),
              ),
            ),
          ),
          const Expanded(child: Logo(fontSize: 36)),
        ],
      ),
    );
  }
}
