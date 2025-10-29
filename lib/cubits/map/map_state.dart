// import 'package:equatable/equatable.dart';
// import 'package:ride_sharing_app/models/location_model.dart';

// abstract class MapState extends Equatable {
//   const MapState();

//   @override
//   List<Object> get props => [];
// }

// class MapInitial extends MapState {}

// class MapLoading extends MapState {}

// class MapLoaded extends MapState {
//   final LocationModel currentLocation;

//   const MapLoaded(this.currentLocation);

//   @override
//   List<Object> get props => [currentLocation];
// }

// class DestinationSelected extends MapState {
//   final LocationModel destinationLocation;
//   final LocationModel currentLocation;
//   final double distance;

//   const DestinationSelected(
//     this.destinationLocation,
//     this.currentLocation,
//     this.distance,
//   );

//   @override
//   List<Object> get props => [destinationLocation, currentLocation, distance];
// }

// class MapError extends MapState {
//   final String message;

//   const MapError(this.message);

//   @override
//   List<Object> get props => [message];
// }
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final LatLng currentLocation;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final CameraPosition cameraPosition;
  
  MapLoaded({
    required this.currentLocation,
    this.markers = const {},
    this.polylines = const {},
    required this.cameraPosition,
  });
  
  @override
  List<Object?> get props => [currentLocation, markers, polylines, cameraPosition];
  
  MapLoaded copyWith({
    LatLng? currentLocation,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    CameraPosition? cameraPosition,
  }) {
    return MapLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      cameraPosition: cameraPosition ?? this.cameraPosition,
    );
  }
}

class MapRouteCalculated extends MapState {
  final LatLng origin;
  final LatLng destination;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final double distance;
  final int duration;
  final double fare;
  
  MapRouteCalculated({
    required this.origin,
    required this.destination,
    required this.markers,
    required this.polylines,
    required this.distance,
    required this.duration,
    required this.fare,
  });
  
  @override
  List<Object?> get props => [
    origin,
    destination,
    markers,
    polylines,
    distance,
    duration,
    fare,
  ];
}

class MapError extends MapState {
  final String message;
  
  MapError(this.message);
  
  @override
  List<Object?> get props => [message];
}
