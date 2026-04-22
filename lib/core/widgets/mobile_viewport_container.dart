import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';

const double kMobileViewportMaxWidth = 640;

class SellerMobileShell extends StatelessWidget {
  const SellerMobileShell({
    super.key,
    required this.child,
    required this.bottomBar,
    this.maxWidth = kMobileViewportMaxWidth,
    this.gutterColor = AppColors.background,
    this.panelColor = AppColors.background,
  });

  final Widget child;
  final Widget bottomBar;
  final double maxWidth;
  final Color gutterColor;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: gutterColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final outerW = constraints.maxWidth;
          final contentW = outerW > maxWidth ? maxWidth : outerW;
          final maxH = constraints.maxHeight;
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: contentW,
              height: maxH,
              decoration: BoxDecoration(
                color: panelColor,
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: child),
                  bottomBar,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MobileViewportContainer extends StatelessWidget {
  const MobileViewportContainer({
    super.key,
    required this.child,
    this.maxWidth = kMobileViewportMaxWidth,
    this.backgroundColor = AppColors.primary,
    this.alignment = Alignment.topCenter,
    this.panelColor = AppColors.background,
  });

  final Widget child;

  final double maxWidth;

  final Color backgroundColor;

  final Alignment alignment;

  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final outerW = constraints.maxWidth;
          final contentW = outerW > maxWidth ? maxWidth : outerW;
          final maxH = constraints.maxHeight;

          final boxed = maxH.isFinite
              ? SizedBox(width: contentW, height: maxH, child: child)
              : ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentW),
                  child: child,
                );

          return Align(
            alignment: alignment,
            child: Container(
              decoration: BoxDecoration(
                color: panelColor,
                border: Border.all(color: AppColors.accentLight, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: boxed,
            ),
          );
        },
      ),
    );
  }
}
