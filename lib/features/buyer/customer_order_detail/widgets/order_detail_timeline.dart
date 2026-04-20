import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class OrderDetailTimelineStep {
  const OrderDetailTimelineStep({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
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

  @override
  Widget build(BuildContext context) {
    final segmentAfterDone = isDone;
    final lineColor = segmentAfterDone
        ? AppColors.primary.withValues(alpha: 0.42)
        : AppColors.textGray.withValues(alpha: 0.22);

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
                  color: isDone ? AppColors.primary : AppColors.white,
                  border: Border.all(
                    color: isDone
                        ? AppColors.primary
                        : (isCurrent
                              ? AppColors.primary
                              : AppColors.textGray.withValues(alpha: 0.38)),
                    width: isCurrent && !isDone ? 2.5 : 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 5,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: AppColors.white,
                      )
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
                color: isCurrent
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isCurrent
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.22),
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.title,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: isCurrent
                            ? AppColors.textDark
                            : (isDone
                                  ? AppColors.textDark.withValues(alpha: 0.72)
                                  : AppColors.textGray),
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
                        fontWeight: isCurrent
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
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
