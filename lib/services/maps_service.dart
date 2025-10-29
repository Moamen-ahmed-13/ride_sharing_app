import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapsService {
  // Replace with your Google Maps API Key
  static const String _apiKey = 'AIzaSyBhDflq5iJrXIcKpeq0IzLQPQpOboX91lY';

  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: _apiKey);

  // Get directions between two points
  Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          return {
            'polyline': route['overview_polyline']['points'],
            'distance': leg['distance']['value'], // in meters
            'duration': leg['duration']['value'], // in seconds
            'distanceText': leg['distance']['text'],
            'durationText': leg['duration']['text'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  // Decode polyline to list of LatLng points
  List<LatLng> decodePolyline(String encoded) {
    List<PointLatLng> points = PolylinePoints.decodePolyline(encoded);
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  // Calculate fare based on distance
  double calculateFare(double distanceInKm) {
    const double baseFare = 30.0; // Base fare
    const double perKmRate = 15.0; // Rate per kilometer

    double fare = baseFare + (distanceInKm * perKmRate);
    return double.parse(fare.toStringAsFixed(2));
  }

  // Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?'
      'latlng=${position.latitude},${position.longitude}&'
      'key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Search places using Google Places API
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
      'input=$query&'
      'key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(
            data['predictions'].map(
              (prediction) => {
                'description': prediction['description'],
                'placeId': prediction['place_id'],
              },
            ),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Get place details from place ID
  Future<LatLng?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?'
      'place_id=$placeId&'
      'fields=geometry&'
      'key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }
}
