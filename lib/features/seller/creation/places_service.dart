import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] as String,
      mainText: json['structured_formatting']?['main_text'] as String? ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] as String? ?? '',
    );
  }
}

class LocationCoordinates {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });
}

class PlacesService {
  final String _googleApiKey;

  PlacesService(this._googleApiKey);

  Future<List<PlacePrediction>> getAutocompletePredictions(String input) async {
    if (input.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$input'
          '&components=country:pe'
          '&key=$_googleApiKey',
        ),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final predictions = (json['predictions'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map((p) => PlacePrediction.fromJson(p))
                .toList() ??
            [];
        return predictions;
      }
      return [];
    } catch (e) {
      print('Error fetching autocomplete predictions: $e');
      return [];
    }
  }

  Future<LocationCoordinates?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address'
          '&key=$_googleApiKey',
        ),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = json['result'] as Map<String, dynamic>?;

        if (result != null) {
          final location = result['geometry']?['location'] as Map<String, dynamic>?;
          final address = result['formatted_address'] as String?;

          if (location != null && address != null) {
            return LocationCoordinates(
              latitude: (location['lat'] as num).toDouble(),
              longitude: (location['lng'] as num).toDouble(),
              formattedAddress: address,
            );
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
  }
}
