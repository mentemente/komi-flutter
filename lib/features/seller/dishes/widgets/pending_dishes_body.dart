import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/dishes/widgets/add_dish_modal.dart';
import 'package:komi_fe/features/seller/dishes/widgets/pending_dish_card.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class PendingDishesBody extends ConsumerStatefulWidget {
  const PendingDishesBody({super.key, this.onSaveToDaily});

  final void Function(List<DailyMenuItem> dishes)? onSaveToDaily;

  @override
  ConsumerState<PendingDishesBody> createState() => _PendingDishesBodyState();
}

class _PendingDishesBodyState extends ConsumerState<PendingDishesBody> {
  XFile? _photo;
  List<int>? _photoBytes;
  bool _loading = false;
  List<DailyMenuItem> _detectedDishes = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _loading = true;
      _photo = file;
      _photoBytes = bytes;
      _detectedDishes = [];
    });

    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId = (stores != null && stores.isNotEmpty)
        ? stores.first.id
        : null;
    if (storeId == null || storeId.isEmpty) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la tienda.')),
      );
      return;
    }

    try {
      final detected = await ServiceLocator.foodService.scanFoodsFromImage(
        storeId: storeId,
        fileBytes: bytes,
        filename: file.name,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _detectedDishes = detected;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.displayMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
          GestureDetector(
            onTap: () => _showFullscreenMemoryImage(context, _photoBytes!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.memory(
                  Uint8List.fromList(_photoBytes!),
                  fit: BoxFit.cover,
                ),
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

void _showFullscreenMemoryImage(BuildContext context, List<int> bytes) {
  showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.94),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: _FullscreenMemoryImageView(bytes: bytes),
      );
    },
  );
}

class _FullscreenMemoryImageView extends StatelessWidget {
  const _FullscreenMemoryImageView({required this.bytes});

  final List<int> bytes;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: padding.top + 4,
                bottom: padding.bottom + 4,
                left: 8,
                right: 8,
              ),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                clipBehavior: Clip.none,
                child: Center(
                  child: Image.memory(
                    Uint8List.fromList(bytes),
                    fit: BoxFit.contain,
                    width: size.width - 16,
                    height: size.height - padding.vertical - 8,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: padding.top + 4,
            right: 8,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Cerrar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
