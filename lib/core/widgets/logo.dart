import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:komi_fe/core/constants/app_colors.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    this.fontSize = 56,
    this.color = AppColors.textDark,
    this.shadowColor = AppColors.primary,
    this.shadowOffset = const Offset(4, 4),
    this.letterSpacing = 3,
    this.height = 1.1,
  });

  final double fontSize;
  final Color color;
  final Color shadowColor;
  final Offset shadowOffset;
  final double letterSpacing;
  final double height;

  static const String _text = 'KOMI';

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.nunitoSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      shadows: [
        Shadow(
          color: shadowColor.withValues(alpha: 0.5),
          offset: shadowOffset,
          blurRadius: 0,
        ),
        Shadow(
          color: shadowColor.withValues(alpha: 0.25),
          offset: Offset(shadowOffset.dx * 1.5, shadowOffset.dy * 1.5),
          blurRadius: 8,
        ),
      ],
    );

    return Align(
      alignment: Alignment.center,
      child: Text(_text, style: style),
    );
  }
}
