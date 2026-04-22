import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/features/seller/creation/places_service.dart';

class GeneralInfoSection extends StatefulWidget {
  const GeneralInfoSection({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.referenceController,
    required this.descriptionController,
    required this.onLocationSelected,
    this.googleApiKey,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController referenceController;
  final TextEditingController descriptionController;
  final Function(LocationCoordinates) onLocationSelected;
  final String? googleApiKey;

  @override
  State<GeneralInfoSection> createState() => _GeneralInfoSectionState();
}

class _GeneralInfoSectionState extends State<GeneralInfoSection> {
  LatLng? _selectedLatLng;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Información general', style: AppTextStyles.h5),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.nameController,
          style: const TextStyle(color: AppColors.textDark, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.pin_drop_outlined, color: AppColors.textGray),
            const SizedBox(width: 8),
            Text('Ubicación de la tienda', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedLatLng == null
              ? 'Selecciona en el mapa la ubicación exacta de tu tienda.'
              : 'Puedes ajustar la ubicación cuando lo necesites.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
        ),
        const SizedBox(height: 12),
        if (_selectedLatLng != null) _buildSelectedLocationCard(),
        if (_selectedLatLng != null) const SizedBox(height: 12),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openLocationPicker,
            icon: Icon(
              _selectedLatLng == null
                  ? Icons.map_outlined
                  : Icons.edit_location_alt_outlined,
              color: AppColors.primary,
            ),
            label: Text(
              _selectedLatLng == null
                  ? 'Seleccionar ubicación'
                  : 'Cambiar ubicación',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.referenceController,
          style: const TextStyle(color: AppColors.textDark, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Referencias (opcional)',
            prefixIcon: Icon(Icons.flag_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.descriptionController,
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

  Widget _buildSelectedLocationCard() {
    final lat = _selectedLatLng!.latitude.toStringAsFixed(6);
    final lng = _selectedLatLng!.longitude.toStringAsFixed(6);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación seleccionada',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    final result = await showDialog<LatLng>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final maxH = MediaQuery.sizeOf(dialogContext).height * 0.85;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560, maxHeight: maxH),
            child: _LocationPickerDialog(initialLocation: _selectedLatLng),
          ),
        );
      },
    );

    if (result == null || !mounted) return;

    final coords = LocationCoordinates(
      latitude: result.latitude,
      longitude: result.longitude,
      formattedAddress:
          '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}',
    );

    setState(() => _selectedLatLng = result);
    widget.addressController.text = coords.formattedAddress;
    widget.onLocationSelected(coords);
  }
}

class _LocationPickerDialog extends StatefulWidget {
  const _LocationPickerDialog({this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  static const LatLng _fallbackCenter = LatLng(-12.0464, -77.0428);
  static const double _defaultZoom = 15;

  final Completer<GoogleMapController> _mapCompleter =
      Completer<GoogleMapController>();

  LatLng? _initialCenter;
  LatLng? _selected;
  bool _loadingInitialLocation = true;
  bool _userLocationAvailable = false;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    _resolveInitialCenter();
  }

  @override
  void dispose() {
    _mapCompleter.future
        .then((controller) => controller.dispose())
        .catchError((_) {});
    super.dispose();
  }

  Future<void> _resolveInitialCenter() async {
    if (widget.initialLocation != null) {
      if (!mounted) return;
      setState(() {
        _initialCenter = widget.initialLocation;
        _loadingInitialLocation = false;
      });
      unawaited(_prefetchUserLocation());
      return;
    }

    final current = await _getCurrentUserLocation();
    if (!mounted) return;
    setState(() {
      _initialCenter = current ?? _fallbackCenter;
      _userLocationAvailable = current != null;
      _loadingInitialLocation = false;
    });
  }

  Future<void> _prefetchUserLocation() async {
    final current = await _getCurrentUserLocation();
    if (!mounted) return;
    if (current != null) {
      setState(() => _userLocationAvailable = true);
    }
  }

  Future<LatLng?> _getCurrentUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _infoMessage =
            'El servicio de ubicación está desactivado. Usamos Lima como referencia.';
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _infoMessage =
            'Permiso de ubicación denegado. Usamos Lima como referencia.';
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        _infoMessage =
            'El permiso de ubicación está bloqueado. Actívalo desde la configuración del dispositivo.';
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(const Duration(seconds: 10));

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      _infoMessage =
          'No pudimos obtener tu ubicación actual. Usamos Lima como referencia.';
      return null;
    }
  }

  void _handleMapTap(LatLng position) {
    setState(() => _selected = position);
  }

  void _confirmSelection() {
    if (_selected == null) return;
    Navigator.of(context).pop<LatLng>(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Selecciona la ubicación',
                        style: AppTextStyles.h5,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              if (_infoMessage != null && !_loadingInitialLocation)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.textGray,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _infoMessage!,
                            style: AppTextStyles.small,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(child: _buildMap()),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCoordinatesPreview(),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _selected == null
                              ? null
                              : _confirmSelection,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Confirmar ubicación'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    if (_loadingInitialLocation || _initialCenter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCenter!,
        zoom: _defaultZoom,
      ),
      onMapCreated: (controller) {
        if (!_mapCompleter.isCompleted) {
          _mapCompleter.complete(controller);
        }
      },
      onTap: _handleMapTap,
      markers: _selected == null
          ? const <Marker>{}
          : {
              Marker(
                markerId: const MarkerId('picked_location'),
                position: _selected!,
              ),
            },
      myLocationEnabled: _userLocationAvailable,
      myLocationButtonEnabled: _userLocationAvailable,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }

  Widget _buildCoordinatesPreview() {
    if (_selected == null) {
      return Text(
        'Toca el mapa para marcar la ubicación.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
        textAlign: TextAlign.center,
      );
    }
    final lat = _selected!.latitude.toStringAsFixed(6);
    final lng = _selected!.longitude.toStringAsFixed(6);
    return Row(
      children: [
        const Icon(Icons.place, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$lat, $lng',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
