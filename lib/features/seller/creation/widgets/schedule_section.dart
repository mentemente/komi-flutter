import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum ScheduleMode { allDays, custom }

const List<String> _dayLabels = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.allDaysOpen,
    required this.allDaysClose,
    required this.onAllDaysOpenTap,
    required this.onAllDaysCloseTap,
    required this.enabledDays,
    required this.onDayToggled,
    required this.dayOpenTimes,
    required this.dayCloseTimes,
    required this.onDayOpenTap,
    required this.onDayCloseTap,
  });

  final ScheduleMode mode;
  final ValueChanged<ScheduleMode> onModeChanged;

  final TimeOfDay allDaysOpen;
  final TimeOfDay allDaysClose;
  final VoidCallback onAllDaysOpenTap;
  final VoidCallback onAllDaysCloseTap;

  final List<bool> enabledDays;
  final void Function(int index) onDayToggled;
  final List<TimeOfDay> dayOpenTimes;
  final List<TimeOfDay> dayCloseTimes;
  final void Function(int index) onDayOpenTap;
  final void Function(int index) onDayCloseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Horarios de atención', style: AppTextStyles.h5),
        const SizedBox(height: 16),
        _ModeToggle(mode: mode, onChanged: onModeChanged),
        const SizedBox(height: 16),
        if (mode == ScheduleMode.allDays)
          _AllDaysBlock(
            open: allDaysOpen,
            close: allDaysClose,
            onOpenTap: onAllDaysOpenTap,
            onCloseTap: onAllDaysCloseTap,
          )
        else
          _CustomSchedule(
            enabledDays: enabledDays,
            onDayToggled: onDayToggled,
            dayOpenTimes: dayOpenTimes,
            dayCloseTimes: dayCloseTimes,
            onDayOpenTap: onDayOpenTap,
            onDayCloseTap: onDayCloseTap,
          ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final ScheduleMode mode;
  final ValueChanged<ScheduleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Todos los días',
              selected: mode == ScheduleMode.allDays,
              onTap: () => onChanged(ScheduleMode.allDays),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleOption(
              label: 'Personalizado',
              selected: mode == ScheduleMode.custom,
              onTap: () => onChanged(ScheduleMode.custom),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: selected ? AppColors.white : AppColors.textGray,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: selected ? AppColors.white : AppColors.textDark,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDaysBlock extends StatelessWidget {
  const _AllDaysBlock({
    required this.open,
    required this.close,
    required this.onOpenTap,
    required this.onCloseTap,
  });

  final TimeOfDay open;
  final TimeOfDay close;
  final VoidCallback onOpenTap;
  final VoidCallback onCloseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              'Lunes – Domingo',
              style: AppTextStyles.small.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TimePill(time: open, onTap: onOpenTap, compact: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '–',
              style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
            ),
          ),
          Expanded(
            child: _TimePill(time: close, onTap: onCloseTap, compact: true),
          ),
        ],
      ),
    );
  }
}

class _CustomSchedule extends StatelessWidget {
  const _CustomSchedule({
    required this.enabledDays,
    required this.onDayToggled,
    required this.dayOpenTimes,
    required this.dayCloseTimes,
    required this.onDayOpenTap,
    required this.onDayCloseTap,
  });

  final List<bool> enabledDays;
  final void Function(int) onDayToggled;
  final List<TimeOfDay> dayOpenTimes;
  final List<TimeOfDay> dayCloseTimes;
  final void Function(int) onDayOpenTap;
  final void Function(int) onDayCloseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_dayLabels.length, (i) {
          final isLast = i == _dayLabels.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppColors.textGray.withValues(alpha: 0.2),
                      ),
                    ),
            ),
            child: _buildWideRow(i),
          );
        }),
      ),
    );
  }

  Widget _buildWideRow(int i) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: enabledDays[i],
            onChanged: (_) => onDayToggled(i),
            activeColor: AppColors.primary,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            side: BorderSide(
              color: enabledDays[i]
                  ? AppColors.primary
                  : AppColors.textGray.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 88,
          child: Text(
            _dayLabels[i],
            style: AppTextStyles.small.copyWith(
              color: enabledDays[i] ? AppColors.textDark : AppColors.textGray,
              fontWeight: enabledDays[i] ? FontWeight.w500 : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TimePill(
            time: dayOpenTimes[i],
            onTap: enabledDays[i] ? () => onDayOpenTap(i) : null,
            enabled: enabledDays[i],
            compact: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '–',
            style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
          ),
        ),
        Expanded(
          child: _TimePill(
            time: dayCloseTimes[i],
            onTap: enabledDays[i] ? () => onDayCloseTap(i) : null,
            enabled: enabledDays[i],
            compact: true,
          ),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.time,
    required this.onTap,
    this.enabled = true,
    this.compact = false,
  });

  final TimeOfDay time;
  final VoidCallback? onTap;
  final bool enabled;
  final bool compact;

  String _format(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'am' : 'pm';
    return '$hour:$minute$period';
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = compact ? 8.0 : 14.0;
    final verticalPadding = compact ? 8.0 : 10.0;
    final innerSpacing = compact ? 2.0 : 6.0;
    final borderRadius = compact ? 8.0 : 10.0;
    final fontSize = compact ? 12.0 : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: enabled
                  ? AppColors.textGray.withValues(alpha: 0.4)
                  : AppColors.textGray.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: innerSpacing),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _format(time),
                    style: AppTextStyles.subtitle2.copyWith(
                      color: enabled ? AppColors.textDark : AppColors.textGray,
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
