import 'package:flutter/material.dart';

import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';

class UserTypeSelector extends StatelessWidget {
  const UserTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserType value;
  final ValueChanged<UserType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _TypeChip(
                label: 'Vendedor/a',
                selected: value == UserType.seller,
                onTap: () => onChanged(UserType.seller),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _TypeChip(
                label: 'Cliente',
                selected: value == UserType.buyer,
                onTap: () => onChanged(UserType.buyer),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accentLight : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.textDark,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
