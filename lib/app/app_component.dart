import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/theme/app_theme.dart';

class AppComponent extends StatelessWidget {
  const AppComponent({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Komi',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
