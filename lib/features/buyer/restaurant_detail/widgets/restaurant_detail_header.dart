import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/logout_button.dart';

class RestaurantDetailHeader extends StatelessWidget {
  const RestaurantDetailHeader({
    super.key,
    required this.title,
    required this.loggedIn,
  });

  final String title;
  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(RouteNames.restaurants),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textDark,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.25),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (loggedIn) ...[
            const SizedBox(width: 8),
            const LogoutButton(),
          ] else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
