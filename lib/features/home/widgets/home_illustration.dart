import 'package:flutter/material.dart';

class HomeIllustration extends StatelessWidget {
  const HomeIllustration({super.key, this.width = 200, this.height = 200});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ollin.webp',
      width: width,
      height: height,
    );
  }
}
