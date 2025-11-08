import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenStreetMapService {
  final String _apiKey = dotenv.env['OPENSTREETMAP_API_KEY'] ?? '';
  OpenStreetMapService(){
    if (_apiKey.isEmpty) {
      throw Exception('OPENSTREETMAP_API_KEY not found in environment');
    }
  }
  Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?'
      'api_key=$_apiKey&'
      'start=${origin.longitude},${origin.latitude}&'
      'end=${destination.longitude},${destination.latitude}',
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['features'][0];
        final geometry = route['geometry'];
        final properties = route['properties'];
        final segments = properties['segments'][0];
        
        final List<dynamic> coords = geometry['coordinates'];
        final List<LatLng> polylinePoints = coords
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();
        
        return {
          'polyline': polylinePoints,
          'distance': segments['distance'], 
          'duration': segments['duration'], 
          'distanceText': '${(segments['distance'] / 1000).toStringAsFixed(1)} km',
          'durationText': '${(segments['duration'] / 60).toStringAsFixed(0)} min',
        };
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  double calculateFare(double distanceInMeters) {
    const double baseFare = 30.0;
    const double perKmRate = 15.0;
    
    double distanceInKm = distanceInMeters / 1000;
    double fare = baseFare + (distanceInKm * perKmRate);
    return double.parse(fare.toStringAsFixed(2));
  }

  Future<String?> getAddressFromCoordinates(LatLng position) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?'
      'lat=${position.latitude}&'
      'lon=${position.longitude}&'
      'format=json',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'RideSharingApp/1.0'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?'
      'q=$query&'
      'format=json&'
      'limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'RideSharingApp/1.0'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((place) => {
          'description': place['display_name'],
          'placeId': place['place_id'].toString(),
          'lat': double.parse(place['lat']),
          'lon': double.parse(place['lon']),
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }
}
