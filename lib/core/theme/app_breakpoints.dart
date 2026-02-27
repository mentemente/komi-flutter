import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 768;
  static const double tablet = 992;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
}
