import 'package:flutter/material.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/profile_menu_button.dart';

class TitleProfileHeader extends StatelessWidget {
  const TitleProfileHeader({super.key, required this.title, this.titleStyle});

  final String title;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: ProfileMenuButton.size),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle ?? AppTextStyles.h4,
          ),
        ),
        const ProfileMenuButton(),
      ],
    );
  }
}
