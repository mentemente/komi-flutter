import 'package:flutter/material.dart';
import 'package:komi_fe/core/formatting/time_format.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';

const Color _kOpenDot = Color(0xFF2D9D5C);
const Color _kOpenBg = Color(0xFFDCF5E3);
const Color _kClosedDot = Color(0xFFD84040);
const Color _kClosedBg = Color(0xFFFBDFDB);

class StoreOpenStatusBanner extends StatelessWidget {
  const StoreOpenStatusBanner({super.key, required this.store});

  final StoreMenuInfo store;

  @override
  Widget build(BuildContext context) {
    final isOpen = store.isOpenNow;
    final bg = isOpen ? _kOpenBg : _kClosedBg;
    final dot = isOpen ? _kOpenDot : _kClosedDot;
    final label = isOpen
        ? 'Abierto ahora · Cierra a las ${formatTime12hFrom24(store.schedule.close)}'
        : 'Cerrado ahora';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                color: dot,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
