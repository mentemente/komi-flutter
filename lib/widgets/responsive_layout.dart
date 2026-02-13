import 'package:flutter/widgets.dart';
import 'package:komi_fe/theme/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (AppBreakpoints.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
