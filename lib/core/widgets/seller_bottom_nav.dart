import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SellerBottomNav extends StatelessWidget {
  const SellerBottomNav({
    super.key,
    required this.currentIndex,
    required this.tabs,
  });

  final int currentIndex;
  final List<String> tabs;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.assignment, label: 'Ordenes activas'),
    _NavItem(icon: Icons.restaurant_menu, label: 'Carta del día'),
    _NavItem(icon: Icons.star_outline, label: '¿Cómo va el día?'),
    _NavItem(icon: Icons.description, label: 'Mis platos'),
    _NavItem(icon: Icons.store, label: 'Mi tienda'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navTheme = theme.bottomNavigationBarTheme;
    final selectedColor = navTheme.selectedItemColor ?? colorScheme.primary;
    final unselectedColor =
        navTheme.unselectedItemColor ??
        colorScheme.onSurface.withValues(alpha: 0.6);
    final labelStyle =
        navTheme.selectedLabelStyle ?? theme.textTheme.labelSmall;
    final unselectedLabelStyle =
        navTheme.unselectedLabelStyle ?? theme.textTheme.labelSmall;

    return Material(
      color: navTheme.backgroundColor ?? theme.colorScheme.surface,
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = (currentIndex < 0 ? 0 : currentIndex) == index;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(tabs[index]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: selected ? selectedColor : unselectedColor,
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            item.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (selected ? labelStyle : unselectedLabelStyle)
                                    ?.copyWith(
                                      color: selected
                                          ? selectedColor
                                          : unselectedColor,
                                      fontSize: 12,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
