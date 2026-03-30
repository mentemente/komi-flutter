import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/widgets/logo.dart';

class LocationPermissionHeader extends StatelessWidget {
  const LocationPermissionHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
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
