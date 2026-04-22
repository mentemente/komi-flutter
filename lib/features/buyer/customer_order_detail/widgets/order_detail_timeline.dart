import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

String _formatStepDateTime(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  final y = local.year;
  final h = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
  final min = local.minute.toString().padLeft(2, '0');
  final ampm = local.hour >= 12 ? 'PM' : 'AM';
  return '$d/$m/$y $h:$min $ampm';
}

class OrderDetailTimelineStep {
  const OrderDetailTimelineStep({
    required this.title,
    required this.subtitle,
    this.dateTime,
    this.isCancelled = false,
    this.cancelledReason,
  });

  final String title;
  final String subtitle;
  final DateTime? dateTime;
  final bool isCancelled;
  final String? cancelledReason;
}

class OrderDetailTimeline extends StatelessWidget {
  const OrderDetailTimeline({
    super.key,
    required this.steps,
    required this.activeIndex,
  });

  final List<OrderDetailTimelineStep> steps;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _TimelineRow(
            step: steps[i],
            isDone: i < activeIndex,
            isCurrent: i == activeIndex,
            isLast: i == steps.length - 1,
          ),
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final OrderDetailTimelineStep step;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  static const _kCancelRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final isCancelledStep = step.isCancelled && isCurrent;

    final dotColor = isCancelledStep
        ? _kCancelRed
        : (isDone ? AppColors.primary : AppColors.white);

    final dotBorderColor = isCancelledStep
        ? _kCancelRed
        : (isDone
            ? AppColors.primary
            : (isCurrent
                ? AppColors.primary
                : AppColors.textGray.withValues(alpha: 0.38)));

    final lineColor = isDone
        ? AppColors.primary.withValues(alpha: 0.42)
        : AppColors.textGray.withValues(alpha: 0.22);

    final cardBgColor = isCancelledStep
        ? _kCancelRed.withValues(alpha: 0.07)
        : (isCurrent ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent);

    final cardBorderColor = isCancelledStep
        ? _kCancelRed.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.22);

    final titleColor = isCancelledStep
        ? _kCancelRed
        : (isCurrent
            ? AppColors.textDark
            : (isDone
                ? AppColors.textDark.withValues(alpha: 0.72)
                : AppColors.textGray));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isCurrent ? 18 : 16,
                height: isCurrent ? 18 : 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: Border.all(
                    color: dotBorderColor,
                    width: isCurrent && !isDone ? 2.5 : 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: (isCancelledStep ? _kCancelRed : AppColors.primary)
                                .withValues(alpha: 0.28),
                            blurRadius: 5,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 11, color: AppColors.white)
                    : isCancelledStep
                        ? const Icon(Icons.close_rounded, size: 11, color: AppColors.white)
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(10),
                border: isCurrent
                    ? Border.all(color: cardBorderColor)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.title,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        height: 1.25,
                        color: isCurrent
                            ? AppColors.textGray
                            : AppColors.textGray.withValues(alpha: 0.9),
                        fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    if (step.dateTime != null && (isDone || isCurrent)) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatStepDateTime(step.dateTime!),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          height: 1.2,
                          color: AppColors.textGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (isCancelledStep &&
                        step.cancelledReason != null &&
                        step.cancelledReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Motivo: ${step.cancelledReason}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          height: 1.3,
                          color: _kCancelRed.withValues(alpha: 0.85),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
