import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/services/location_service.dart';
import 'package:ride_sharing_app/services/maps_service.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationService _locationService = LocationService();
  final MapsService _mapsService = MapsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<Position>? _locationSubscription;
  Position? _currentPosition;

  LocationCubit() : super(LocationInitial());

  // Get current location once
  Future<void> getCurrentLocation() async {
    try {
      emit(LocationLoading());

      bool hasPermission = await _locationService.handleLocationPermission();
      
      if (!hasPermission) {
        emit(LocationPermissionDenied());
        return;
      }

      Position? position = await _locationService.getCurrentLocation();
      
      if (position == null) {
        emit(LocationServiceDisabled());
        return;
      }

      _currentPosition = position;

      // Get address from coordinates
      String? address = await _mapsService.getAddressFromCoordinates(
        LatLng(position.latitude, position.longitude),
      );

      emit(LocationLoaded(position, address: address));

      // Update location in Firebase
      if (_auth.currentUser != null) {
        await _locationService.updateLocationInFirebase(
          _auth.currentUser!.uid,
          position,
        );
      }
    } catch (e) {
      emit(LocationError('Failed to get location: ${e.toString()}'));
 }
  }

  // Start real-time location tracking
  Future<void> startLocationTracking() async {
    try {
      bool hasPermission = await _locationService.handleLocationPermission();
      
      if (!hasPermission) {
        emit(LocationPermissionDenied());
        return;
      }

      _locationSubscription = _locationService
          .getLocationStream()
          .listen((Position position) {
        _currentPosition = position;
        emit(LocationUpdating(position));

        // Update location in Firebase
        if (_auth.currentUser != null) {
          _locationService.updateLocationInFirebase(
            _auth.currentUser!.uid,
            position,
          );
        }
      });
    } catch (e) {
      emit(LocationError('Failed to start tracking: ${e.toString()}'));
    }
  }

  // Stop location tracking
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // Get current position (cached)
  Position? get currentPosition => _currentPosition;

  @override
  Future<void> close() {
    stopLocationTracking();
    return super.close();
  }
}