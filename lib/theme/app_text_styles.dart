import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // H1 - 48px / Bold / #2C2C2C
  static const TextStyle h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // H2 - 24px / Regular / #7C7C7C
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textGray,
  );

  // H3 - 20px / SemiBold / #2C2C2C
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Body - 16px / Regular / #7C7C7C
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textGray,
  );

  // Caption - 14px / Regular / #7C7C7C
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textGray,
  );

  // Small - 12px / SemiBold / #D87854
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}
