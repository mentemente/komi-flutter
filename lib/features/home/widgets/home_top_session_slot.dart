import 'package:flutter/material.dart';

class HomeTopSessionSlot extends StatelessWidget {
  const HomeTopSessionSlot({
    super.key,
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets padding;

  static const EdgeInsets paddingMobile = EdgeInsets.fromLTRB(32, 14, 32, 10);
  static const EdgeInsets paddingDesktop = EdgeInsets.fromLTRB(48, 18, 48, 10);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Align(alignment: Alignment.centerRight, child: child),
        ),
      ),
    );
  }
}
