import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class ProfileMenuButton extends ConsumerStatefulWidget {
  const ProfileMenuButton({super.key});

  static const double size = 48;

  @override
  ConsumerState<ProfileMenuButton> createState() => _ProfileMenuButtonState();
}

class _ProfileMenuButtonState extends ConsumerState<ProfileMenuButton> {
  final GlobalKey _buttonKey = GlobalKey();
  static const double _menuWidth = 220;
  static const double _tailWidth = 14;
  static const double _tailHeight = 8;
  static const double _gapBelowButton = 6;

  Future<void> _openMenu() async {
    final ctx = context;
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final topLeft = box.localToGlobal(Offset.zero);
    final btnSize = box.size;
    final screenW = MediaQuery.sizeOf(ctx).width;

    final buttonCenterX = topLeft.dx + btnSize.width / 2;
    var menuLeft = buttonCenterX - _menuWidth / 2;
    menuLeft = menuLeft.clamp(8.0, screenW - _menuWidth - 8.0);
    final tailLeftInMenu = (buttonCenterX - menuLeft - _tailWidth / 2).clamp(
      10.0,
      _menuWidth - _tailWidth - 10,
    );

    final menuTop = topLeft.dy + btnSize.height + _gapBelowButton;

    await showGeneralDialog<void>(
      context: ctx,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(ctx).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
                child: const ColoredBox(color: Color(0x33000000)),
              ),
            ),
            Positioned(
              left: menuLeft,
              top: menuTop,
              width: _menuWidth,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: tailLeftInMenu),
                      child: CustomPaint(
                        size: const Size(_tailWidth, _tailHeight),
                        painter: _MenuTailPainter(
                          fill: AppColors.white,
                          stroke: AppColors.primary.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -1),
                      child: Container(
                        width: _menuWidth,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textDark.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MenuRow(
                              icon: Icons.settings_outlined,
                              label: 'Config. Tienda',
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                ctx.go(
                                  '${RouteNames.seller}/${RouteNames.storeConfiguration}',
                                );
                              },
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.textGray.withValues(alpha: 0.2),
                            ),
                            _MenuRow(
                              icon: Icons.logout,
                              label: 'Cerrar sesión',
                              onTap: () async {
                                Navigator.of(dialogContext).pop();
                                await ref
                                    .read(authSessionProvider.notifier)
                                    .clear();
                                if (!mounted) return;
                                context.go(RouteNames.login);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _buttonKey,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openMenu,
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.accentLight.withValues(alpha: 0.25),
        child: SizedBox(
          width: ProfileMenuButton.size,
          height: ProfileMenuButton.size,
          child: Icon(
            Icons.person_outline_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _MenuTailPainter extends CustomPainter {
  _MenuTailPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MenuTailPainter oldDelegate) {
    return oldDelegate.fill != fill || oldDelegate.stroke != stroke;
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
