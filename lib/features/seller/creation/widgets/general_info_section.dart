import 'package:flutter/material.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/constants/app_colors.dart';

class GeneralInfoSection extends StatelessWidget {
  const GeneralInfoSection({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.referenceController,
    required this.descriptionController,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController referenceController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Información general', style: AppTextStyles.h5),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textDark, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: addressController,
          style: const TextStyle(color: AppColors.textDark, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Dirección',
            prefixIcon: Icon(Icons.pin_drop_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa una dirección' : null,
        ),
        const SizedBox(height: 16),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textGray.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.map_outlined,
              size: 48,
              color: AppColors.textGray.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: referenceController,
          style: const TextStyle(color: AppColors.textDark, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Referencias (opcional)',
            prefixIcon: Icon(Icons.flag_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          style: const TextStyle(color: AppColors.textDark, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Cuéntanos un poco de tu cocina (opcional)',
            alignLabelWithHint: true,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
