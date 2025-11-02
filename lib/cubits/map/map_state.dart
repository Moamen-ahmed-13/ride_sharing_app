import 'package:latlong2/latlong.dart';

class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapDirectionsLoaded extends MapState {
  final List<LatLng> polyline;
  final double distance;
  final double duration;
  final String distanceText;
  final String durationText;
  final double fare;
  MapDirectionsLoaded(this.polyline, this.distance, this.duration, this.distanceText, this.durationText, this.fare);
}

class MapPlacesLoaded extends MapState {
  final List<Map<String, dynamic>> places;
  MapPlacesLoaded(this.places);
}

class MapAddressLoaded extends MapState {
  final String address;
  MapAddressLoaded(this.address);
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}
