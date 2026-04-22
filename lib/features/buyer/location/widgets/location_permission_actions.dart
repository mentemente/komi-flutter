import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/location/location_state.dart';

class LocationPermissionActions extends StatelessWidget {
  const LocationPermissionActions({
    super.key,
    required this.state,
    required this.onGrantPermission,
    required this.onDenyPermission,
    this.showDenyButton = true,
  });

  final LocationPermissionState state;
  final VoidCallback onGrantPermission;
  final VoidCallback onDenyPermission;
  final bool showDenyButton;

  bool get _showDenyButton =>
      showDenyButton && state is LocationPermissionInitial;

  bool get _isLoading => state is LocationPermissionLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : onGrantPermission,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Dar permiso'),
            ),
          ),
          if (_showDenyButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoading ? null : onDenyPermission,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGray,
                  side: BorderSide(
                    color: AppColors.textGray.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'No dar permiso',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
