import 'package:flutter/material.dart';
import 'package:komi_fe/core/theme/app_theme.dart';

import '../config/router.dart';

class AppComponent extends StatelessWidget {
  const AppComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Komi',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
