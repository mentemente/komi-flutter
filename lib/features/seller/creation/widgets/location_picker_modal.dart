import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/creation/places_service.dart';

class LocationPickerModal extends StatefulWidget {
  final Function(LocationCoordinates) onLocationSelected;
  final String? googleApiKey;

  const LocationPickerModal({
    super.key,
    required this.onLocationSelected,
    this.googleApiKey,
  });

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  late GoogleMapController _mapController;
  late PlacesService _placesService;
  final _searchController = TextEditingController();

  CameraPosition _currentPosition = const CameraPosition(
    target: LatLng(-12.0464, -77.0428),
    zoom: 13,
  );

  LatLng? _selectedLocation;
  List<PlacePrediction> _predictions = [];
  bool _isLoadingPredictions = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    if (widget.googleApiKey != null && widget.googleApiKey!.isNotEmpty) {
      _placesService = PlacesService(widget.googleApiKey!);
    }
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          );
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isInitializing = false;
        });

        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
      print('Error getting location: $e');
    }
  }

  Future<void> _handlePredictionTap(PlacePrediction prediction) async {
    final details = await _placesService.getPlaceDetails(prediction.placeId);

    if (details != null && mounted) {
      setState(() {
        _selectedLocation = LatLng(details.latitude, details.longitude);
        _currentPosition = CameraPosition(
          target: _selectedLocation!,
          zoom: 15,
        );
        _searchController.text = details.formattedAddress;
        _predictions = [];
      });

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _handleSearchChange(String value) async {
    if (value.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isLoadingPredictions = true);

    if (widget.googleApiKey != null) {
      final preds = await _placesService.getAutocompletePredictions(value);
      if (mounted) {
        setState(() {
          _predictions = preds;
          _isLoadingPredictions = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingPredictions = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google API key no configurada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Buscar ubicación', style: AppTextStyles.h5),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: _handleSearchChange,
                  decoration: InputDecoration(
                    hintText: 'Ingresa dirección o lugar',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_isLoadingPredictions) ...[
                  const SizedBox(height: 12),
                  const SizedBox(
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else if (_predictions.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final pred = _predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, size: 20),
                          title: Text(pred.mainText),
                          subtitle: Text(
                            pred.secondaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _handlePredictionTap(pred),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: _currentPosition,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _selectedLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected'),
                              position: _selectedLocation!,
                            ),
                          }
                        : {},
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                        _currentPosition = CameraPosition(
                          target: location,
                          zoom: _currentPosition.zoom,
                        );
                      });
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedLocation != null
                      ? () {
                          final coords = LocationCoordinates(
                            latitude: _selectedLocation!.latitude,
                            longitude: _selectedLocation!.longitude,
                            formattedAddress:
                                _searchController.text.isNotEmpty
                                    ? _searchController.text
                                    : '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                          );
                          widget.onLocationSelected(coords);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Confirmar ubicación'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
