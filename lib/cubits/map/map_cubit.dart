// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/location_datasource.dart';
// import 'package:ride_sharing_app/models/location_model.dart';
// import 'package:ride_sharing_app/cubits/map/map_state.dart';

// class MapCubit extends Cubit<MapState> {
//   final LocationDatasource locationDataSource;
//   LocationModel? currentLocation;

//   MapCubit(this.locationDataSource) : super(MapInitial());

//   Future<void> getCurrentLocation() async {
//     emit(MapLoading());
//     try {
//       currentLocation = await locationDataSource.getCurrentLocation();
//       emit(MapLoaded(currentLocation!));
//     } catch (e) {
//       emit(MapError(e.toString()));
//     }
//   }

//   Future selectedDestination(String address) async {
//     if (currentLocation == null) {
//       emit(MapError('Current location not found'));
//       return;
//     }
//     emit(MapLoading());
//     try {
//       final Destination = await locationDataSource.getLocationFromAddress(
//         address,
//       );
//       final distance = await locationDataSource.calculateDistance(
//         currentLocation!.latitude,
//         currentLocation!.longitude,
//         Destination.latitude,
//         Destination.longitude,
//       );
//       emit(DestinationSelected(Destination, currentLocation!, distance));
//     } catch (e) {
//       emit(MapError('Failed to get Destination: ${e.toString()}'));
//     }
//   }

//   Future selectedDestinationByCoordinates(
//     double latitude,
//     double longitude,
//   ) async {
//     if (currentLocation == null) {
//       emit(MapError('Current location not found'));
//       return;
//     }
//     emit(MapLoading());
//     try {
//       final address = await locationDataSource.getAddressFromCoordinates(
//         latitude,
//         longitude,
//       );
//       final Destination = LocationModel(
//         latitude: latitude,
//         longitude: longitude,
//         address: address,
//       );
//       final distance = locationDataSource.calculateDistance(
//         currentLocation!.latitude,
//         currentLocation!.longitude,
//         latitude,
//         longitude,
//       );
//       emit(DestinationSelected(Destination, currentLocation!, distance));
//     } catch (e) {
//       emit(MapError('Failed to select Destination: ${e.toString()}'));
//     }
//   }

//   void resetState() {
//     if (currentLocation != null) {
//       emit(MapLoaded(currentLocation!));
//     } else {
//       emit(MapInitial());
//     }
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/services/location_service.dart';
import 'package:ride_sharing_app/services/maps_service.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final MapsService _mapsService = MapsService();
  final LocationService _locationService = LocationService();
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  MapCubit() : super(MapInitial());

  // Initialize map with current location
  Future<void> initializeMap(LatLng currentLocation) async {
    try {
      emit(MapLoading());

      CameraPosition initialPosition = CameraPosition(
        target: currentLocation,
        zoom: 15.0,
      );

      // Add marker for current location
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      emit(MapLoaded(
        currentLocation: currentLocation,
        markers: _markers,
        cameraPosition: initialPosition,
      ));
    } catch (e) {
      emit(MapError('Failed to initialize map: ${e.toString()}'));
    }
  }

  // Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // Update current location marker
  void updateCurrentLocationMarker(LatLng location) {
    if (state is! MapLoaded) return;

    _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
    
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    emit((state as MapLoaded).copyWith(
      currentLocation: location,
      markers: _markers,
    ));

    // Move camera to new location
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  // Add marker for pickup location
  void addPickupMarker(LatLng location, String address) {
    if (state is! MapLoaded) return;

    _markers.removeWhere((marker) => marker.markerId.value == 'pickup');
    
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup', snippet: address),
      ),
    );

    emit((state as MapLoaded).copyWith(markers: _markers));
  }

  // Add marker for dropoff location
  void addDropoffMarker(LatLng location, String address) {
    if (state is! MapLoaded) return;

    _markers.removeWhere((marker) => marker.markerId.value == 'dropoff');
    
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Dropoff', snippet: address),
      ),
    );

    emit((state as MapLoaded).copyWith(markers: _markers));
  }

  // Add driver marker (for riders)
  void addDriverMarker(LatLng location, String driverName) {
    if (state is! MapLoaded) return;

    _markers.removeWhere((marker) => marker.markerId.value == 'driver');
    
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(title: driverName, snippet: 'Your Driver'),
      ),
    );

    emit((state as MapLoaded).copyWith(markers: _markers));
  }

  // Update driver location in real-time
  void updateDriverLocation(LatLng location) {
    addDriverMarker(location, 'Your Driver');
  }

  // Add rider marker (for drivers)
  void addRiderMarker(LatLng location, String riderName) {
    if (state is! MapLoaded) return;

    _markers.removeWhere((marker) => marker.markerId.value == 'rider');
    
    _markers.add(
      Marker(
        markerId: const MarkerId('rider'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: riderName, snippet: 'Rider'),
      ),
    );

    emit((state as MapLoaded).copyWith(markers: _markers));
  }

  // Calculate and draw route between two points
  Future<void> calculateAndDrawRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      emit(MapLoading());

      // Get directions
      Map<String, dynamic>? directions = await _mapsService.getDirections(
        origin,
        destination,
      );

      if (directions == null) {
        emit(MapError('Failed to get directions'));
        return;
      }

      // Decode polyline
      List<LatLng> polylinePoints = _mapsService.decodePolyline(
        directions['polyline'],
      );

      // Create polyline
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );

      // Add markers for origin and destination
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: origin,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Dropoff'),
        ),
      );

      double distance = directions['distance'] / 1000; // Convert to km
      int duration = (directions['duration'] / 60).round(); // Convert to minutes
      double fare = _mapsService.calculateFare(distance);

      emit(MapRouteCalculated(
        origin: origin,
        destination: destination,
        markers: _markers,
        polylines: _polylines,
        distance: distance,
        duration: duration,
        fare: fare,
      ));

      // Adjust camera to show entire route
      if (_mapController != null) {
        LatLngBounds bounds = _calculateBounds([origin, destination]);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      emit(MapError('Failed to calculate route: ${e.toString()}'));
    }
  }

  // Calculate bounds for multiple points
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Draw route for active ride
  Future<void> drawActiveRideRoute(
    LatLng driverLocation,
    LatLng pickupLocation,
    LatLng dropoffLocation,
    bool hasPickedUp,
  ) async {
    try {
      _markers.clear();
      _polylines.clear();

      // Add driver marker
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      );

      if (!hasPickedUp) {
        // Driver going to pickup
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Pickup Location'),
          ),
        );

        // Draw route from driver to pickup
        Map<String, dynamic>? directions = await _mapsService.getDirections(
          driverLocation,
          pickupLocation,
        );

        if (directions != null) {
          List<LatLng> polylinePoints = _mapsService.decodePolyline(
            directions['polyline'],
          );

          _polylines.add(
            Polyline(
              polylineId: const PolylineId('to_pickup'),
              points: polylinePoints,
              color: Colors.blue,
              width: 5,
            ),
          );
        }
      } else {
        // Driver going to dropoff
        _markers.add(
          Marker(
            markerId: const MarkerId('dropoff'),
            position: dropoffLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Dropoff Location'),
          ),
        );

        // Draw route from driver to dropoff
        Map<String, dynamic>? directions = await _mapsService.getDirections(
          driverLocation,
          dropoffLocation,
        );

        if (directions != null) {
          List<LatLng> polylinePoints = _mapsService.decodePolyline(
            directions['polyline'],
          );

          _polylines.add(
            Polyline(
              polylineId: const PolylineId('to_dropoff'),
              points: polylinePoints,
              color: Colors.green,
              width: 5,
            ),
          );
        }
      }

      if (state is MapLoaded) {
        emit((state as MapLoaded).copyWith(
          markers: _markers,
          polylines: _polylines,
        ));
      }

      // Adjust camera
      if (_mapController != null) {
        List<LatLng> points = [driverLocation];
        if (!hasPickedUp) {
          points.add(pickupLocation);
        } else {
          points.add(dropoffLocation);
        }
        
        LatLngBounds bounds = _calculateBounds(points);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      emit(MapError('Failed to draw route: ${e.toString()}'));
    }
  }

  // Move camera to location
  void moveCameraToLocation(LatLng location, {double zoom = 15.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  // Clear all markers and polylines
  void clearMap() {
    _markers.clear();
    _polylines.clear();
    
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(
        markers: _markers,
        polylines: _polylines,
      ));
    }
  }

  @override
  Future<void> close() {
    _mapController?.dispose();
    return super.close();
  }
}

