import 'package:flutter/material.dart';
import 'package:komi_fe/features/home/widgets/home_guest_cta.dart';
import 'package:komi_fe/features/home/widgets/home_hero.dart';
import 'package:komi_fe/features/home/widgets/home_illustration.dart';
import 'package:komi_fe/features/home/widgets/home_search_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, this.onSearch, this.onRegisterPressed});

  final void Function(String query)? onSearch;
  final VoidCallback? onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeHero(),
        const SizedBox(height: 16),
        HomeSearchSection(onSearch: onSearch),
        const SizedBox(height: 16),
        const HomeIllustration(),
        const SizedBox(height: 16),
        HomeGuestCta(onRegisterPressed: onRegisterPressed),
      ],
    );
  }
}
