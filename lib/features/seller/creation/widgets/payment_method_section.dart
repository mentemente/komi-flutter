import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum PaymentMethod { yapePlin, cash }

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    super.key,
    required this.selectedMethods,
    required this.onMethodToggled,
    this.onPaymentQrUrlChanged,
    this.qrRequiredMessage,
  });

  final Set<PaymentMethod> selectedMethods;
  final void Function(PaymentMethod method) onMethodToggled;
  final ValueChanged<String?>? onPaymentQrUrlChanged;
  final String? qrRequiredMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Método de pago', style: AppTextStyles.h5),
        const SizedBox(height: 16),
        _PaymentOptionCard(
          method: PaymentMethod.yapePlin,
          label: 'Yape / Plin',
          checked: selectedMethods.contains(PaymentMethod.yapePlin),
          onTap: () => onMethodToggled(PaymentMethod.yapePlin),
        ),
        const SizedBox(height: 12),
        _PaymentOptionCard(
          method: PaymentMethod.cash,
          label: 'Efectivo',
          checked: selectedMethods.contains(PaymentMethod.cash),
          onTap: () => onMethodToggled(PaymentMethod.cash),
        ),
        if (selectedMethods.contains(PaymentMethod.yapePlin)) ...[
          const SizedBox(height: 16),
          _PaymentQrUploader(
            onUrlChanged: onPaymentQrUrlChanged,
          ),
          if (qrRequiredMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              qrRequiredMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

String? _imageUrlFromUploadData(Map<String, dynamic> data) {
  for (final key in [
    'url',
    'imageUrl',
    'image_url',
    'path',
    'fileUrl',
    'file_url',
  ]) {
    final v = data[key];
    if (v is String && v.isNotEmpty) {
      return v;
    }
  }
  return null;
}

class _PaymentQrUploader extends StatefulWidget {
  const _PaymentQrUploader({this.onUrlChanged});

  final ValueChanged<String?>? onUrlChanged;

  @override
  State<_PaymentQrUploader> createState() => _PaymentQrUploaderState();
}

class _PaymentQrUploaderState extends State<_PaymentQrUploader> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  String? _remoteUrl;
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null || !mounted) return;

    late final Uint8List bytes;
    try {
      bytes = await xfile.readAsBytes();
    } catch (e, st) {
      debugPrint('readAsBytes: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo leer la imagen: $e')),
      );
      return;
    }

    setState(() {
      _previewBytes = bytes;
      _remoteUrl = null;
      _uploading = true;
    });
    widget.onUrlChanged?.call(null);

    try {
      final data = await ServiceLocator.uploadService.uploadPaymentQrBytes(
        bytes,
        filename: xfile.name,
      );
      final url = _imageUrlFromUploadData(data);
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _remoteUrl = url;
      });
      widget.onUrlChanged?.call(url);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _previewBytes = null;
      });
      widget.onUrlChanged?.call(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.displayMessage)),
      );
    } catch (e, st) {
      debugPrint('upload: $e\n$st');
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _previewBytes = null;
      });
      widget.onUrlChanged?.call(null);
      final msg = e is Exception ? e.toString() : 'Error: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg.length > 200 ? '${msg.substring(0, 200)}…' : msg,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código QR Yape / Plin',
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _uploading ? null : _pickAndUpload,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textGray.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _uploading
                    ? const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : _remoteUrl != null
                        ? Image.network(
                            _remoteUrl!,
                            fit: BoxFit.cover,
                            width: 180,
                            height: 180,
                            errorBuilder: (_, _, _) => _previewBytes != null
                                ? Image.memory(
                                    _previewBytes!,
                                    fit: BoxFit.cover,
                                    width: 180,
                                    height: 180,
                                  )
                                : _emptyPlaceholder(),
                          )
                        : _previewBytes != null
                            ? Image.memory(
                                _previewBytes!,
                                fit: BoxFit.cover,
                                width: 180,
                                height: 180,
                              )
                            : _emptyPlaceholder(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para elegir una imagen desde la galería',
          style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _emptyPlaceholder() {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 56,
        color: AppColors.textGray.withValues(alpha: 0.5),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.method,
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final PaymentMethod method;
  final String label;
  final bool checked;
  final VoidCallback onTap;

  IconData get _icon => method == PaymentMethod.yapePlin
      ? Icons.phone_android
      : Icons.payments_outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: checked
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
              width: checked ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(_icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textDark,
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: checked
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
