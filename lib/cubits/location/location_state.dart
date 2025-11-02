class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoaded extends LocationState {
  final double lat;
  final double lng;
  LocationLoaded(this.lat, this.lng);
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}
