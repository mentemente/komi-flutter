import 'package:flutter/material.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/features/seller/creation/widgets/creation_header.dart';
import 'package:komi_fe/features/seller/creation/widgets/general_info_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/schedule_section.dart';
import 'package:komi_fe/features/seller/creation/places_service.dart';

class CreationStepOneForm extends StatelessWidget {
  const CreationStepOneForm({
    super.key,
    required this.formKey,
    required this.currentStep,
    required this.totalSteps,
    required this.nameController,
    required this.addressController,
    required this.referenceController,
    required this.descriptionController,
    required this.onLocationSelected,
    required this.scheduleMode,
    required this.onScheduleModeChanged,
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
    required this.onNext,
    this.googleApiKey,
  });

  final GlobalKey<FormState> formKey;
  final int currentStep;
  final int totalSteps;

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController referenceController;
  final TextEditingController descriptionController;
  final Function(LocationCoordinates) onLocationSelected;
  final String? googleApiKey;

  final ScheduleMode scheduleMode;
  final ValueChanged<ScheduleMode> onScheduleModeChanged;
  final TimeOfDay allDaysOpen;
  final TimeOfDay allDaysClose;
  final VoidCallback onAllDaysOpenTap;
  final VoidCallback onAllDaysCloseTap;
  final List<bool> enabledDays;
  final void Function(int) onDayToggled;
  final List<TimeOfDay> dayOpenTimes;
  final List<TimeOfDay> dayCloseTimes;
  final void Function(int) onDayOpenTap;
  final void Function(int) onDayCloseTap;

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CreationHeader(currentStep: currentStep, totalSteps: totalSteps),
          const SizedBox(height: 8),
          GeneralInfoSection(
            nameController: nameController,
            addressController: addressController,
            referenceController: referenceController,
            descriptionController: descriptionController,
            onLocationSelected: onLocationSelected,
            googleApiKey: googleApiKey,
          ),
          const SizedBox(height: 16),
          ScheduleSection(
            mode: scheduleMode,
            onModeChanged: onScheduleModeChanged,
            allDaysOpen: allDaysOpen,
            allDaysClose: allDaysClose,
            onAllDaysOpenTap: onAllDaysOpenTap,
            onAllDaysCloseTap: onAllDaysCloseTap,
            enabledDays: enabledDays,
            onDayToggled: onDayToggled,
            dayOpenTimes: dayOpenTimes,
            dayCloseTimes: dayCloseTimes,
            onDayOpenTap: onDayOpenTap,
            onDayCloseTap: onDayCloseTap,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Siguiente'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
