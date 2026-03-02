import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onTap,
    this.readOnly = true,
  });

  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly,
      onTap: onTap,
      decoration: const InputDecoration(
        hintText: 'Buscar',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
