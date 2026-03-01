import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komi_fe/core/constants/app_colors.dart';

abstract final class AppTextStyles {
  AppTextStyles._();

  /// Fuente principal del proyecto (Poppins: limpia, moderna, buena legibilidad)
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textDark,
    double? height,
    LetterSpacing? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing?.value,
    );
  }

  // --- Títulos (Display / Headings) ---
  static TextStyle get h1 => _base(
        fontSize: 48,
        fontWeight: FontWeight.bold,
      );
  static TextStyle get h2 => _base(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get h3 => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get h4 => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get h5 => _base(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get h6 => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // --- Subtítulos ---
  static TextStyle get subtitle1 => _base(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get subtitle2 => _base(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  // --- Cuerpo ---
  static TextStyle get body => _base(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );
  static TextStyle get bodySmall => _base(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  // --- Caption / Secundario ---
  static TextStyle get caption => _base(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textGray,
      );
  static TextStyle get small => _base(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textGray,
      );

  // --- Etiquetas / Overline ---
  static TextStyle get overline => _base(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textGray,
        letterSpacing: LetterSpacing.medium,
      );
  static TextStyle get button => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
}

enum LetterSpacing {
  tight(-0.5),
  normal(0),
  medium(0.5),
  wide(1);

  const LetterSpacing(this.value);
  final double value;
}
