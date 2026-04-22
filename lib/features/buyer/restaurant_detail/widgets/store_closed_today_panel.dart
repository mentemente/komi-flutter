import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

const Color kStoreClosedAccent = Color(0xFFD84040);
const Color kStoreClosedBg = Color(0xFFFBDFDB);

String? weekdayKeyToLosForm(String? key) {
  if (key == null || key.isEmpty) return null;
  const map = {
    'monday': 'lunes',
    'tuesday': 'martes',
    'wednesday': 'miércoles',
    'thursday': 'jueves',
    'friday': 'viernes',
    'saturday': 'sábados',
    'sunday': 'domingos',
  };
  return map[key.trim().toLowerCase()];
}

class StoreClosedTodayPanel extends StatelessWidget {
  const StoreClosedTodayPanel({super.key, required this.weekdayKey});

  final String? weekdayKey;

  @override
  Widget build(BuildContext context) {
    final losDia = weekdayKeyToLosForm(weekdayKey);
    final detail = losDia != null
        ? 'Los $losDia, esta tienda no recibe pedidos. Puedes intentarlo otro día.'
        : 'Ahora mismo no hay menú disponible para pedidos en esta tienda.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 40,
                  color: kStoreClosedAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tienda cerrada hoy',
                textAlign: TextAlign.center,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
