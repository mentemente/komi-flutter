import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/dishes/widgets/add_dish_modal.dart';
import 'package:komi_fe/features/seller/dishes/widgets/pending_dish_card.dart';

class PendingDishesBody extends StatefulWidget {
  const PendingDishesBody({super.key, this.onSaveToDaily});

  final void Function(List<DailyMenuItem> dishes)? onSaveToDaily;

  @override
  State<PendingDishesBody> createState() => _PendingDishesBodyState();
}

class _PendingDishesBodyState extends State<PendingDishesBody> {
  XFile? _photo;
  List<int>? _photoBytes;
  bool _loading = false;
  List<DailyMenuItem> _detectedDishes = [];

  // TODO: remove this
  static final List<DailyMenuItem> _mockDetected = [
    DailyMenuItem(
      name: 'Tequeños',
      stock: 0,
      isActive: true,
      type: MenuItemType.appetizer,
    ),
    DailyMenuItem(
      name: 'Papa a la huancaina',
      stock: 0,
      isActive: true,
      type: MenuItemType.appetizer,
    ),
    DailyMenuItem(
      name: 'Arroz con pollo',
      price: 12,
      stock: 15,
      isActive: true,
      type: MenuItemType.main_course,
    ),
    DailyMenuItem(
      name: 'Seco de frejoles',
      price: 13,
      stock: 12,
      isActive: true,
      type: MenuItemType.main_course,
    ),
    DailyMenuItem(
      name: 'Lomo saltado',
      price: 17,
      stock: 20,
      isActive: true,
      type: MenuItemType.executive_dish,
    ),
    DailyMenuItem(
      name: 'Tallarines verdes con corazon frito',
      price: 20,
      stock: 17,
      isActive: true,
      type: MenuItemType.executive_dish,
    ),
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _loading = true;
      _photo = file;
      _photoBytes = bytes;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _loading = false;
        _detectedDishes = List.from(_mockDetected);
      });
    }
  }

  void _reset() => setState(() {
    _photo = null;
    _photoBytes = null;
    _loading = false;
    _detectedDishes = [];
  });

  void _openEditModal(BuildContext context, int index, DailyMenuItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => EditDishModal(
        item: item,
        onSave: (updated) {
          setState(() {
            _detectedDishes = List.from(_detectedDishes);
            _detectedDishes[index] = updated;
          });
        },
      ),
    );
  }

  void _removeDetectedAt(int index) {
    setState(() {
      _detectedDishes = List.from(_detectedDishes)..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _loading
            ? _buildLoading()
            : _photo == null
            ? _buildUploadZone()
            : _buildDetectedDishes(),
      ),
    );
  }

  Widget _buildUploadZone() {
    const radius = 16.0;
    return Material(
      key: const ValueKey('upload'),
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.accentLight.withValues(alpha: 0.25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Empieza subiendo\nuna foto de tu menú',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.photo_camera_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      key: const ValueKey('loading'),
      width: double.infinity,
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Detectando platos…',
              style: AppTextStyles.body.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedDishes() {
    return Column(
      key: const ValueKey('detected'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _reset,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFB8F0B0),
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Volver a subir foto',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_photoBytes != null && _photoBytes!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.memory(
                Uint8List.fromList(_photoBytes!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (_photoBytes != null && _photoBytes!.isNotEmpty)
          const SizedBox(height: 12),
        ..._detectedDishes.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return PendingDishCard(
            item: d,
            onEdit: (item) => _openEditModal(context, i, item),
            onDelete: (_) => _removeDetectedAt(i),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () {
              widget.onSaveToDaily?.call(List<DailyMenuItem>.from(_detectedDishes));
              if (mounted) _reset();
            },
            child: const Text('Guardar en "Platos del día"'),
          ),
        ),
      ],
    );
  }
}
