import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_sharing_app/cubits/location/location_state.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';

class LocationCubit extends Cubit<LocationState> {
  final DatabaseService _dbService;
  StreamSubscription<Position>? _positionSubscription;

  LocationCubit({required DatabaseService dbService})
      : _dbService = dbService,
        super(LocationInitial());

  Future<void> getCurrentLocation(String uid) async {
    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await _dbService.updateUserLocation(
          uid,
          position.latitude,
          position.longitude,
        );
        emit(LocationLoaded(position.latitude, position.longitude));
      } else {
        emit(LocationError('Location permission denied'));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
  void startLocationTracking(String uid) {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _dbService.updateUserLocation(
        uid,
        position.latitude,
        position.longitude,
      );
      emit(LocationLoaded(position.latitude, position.longitude));
    }, onError: (error) {
      print('❌ Error tracking location: $error');
      emit(LocationError(error.toString()));
    },cancelOnError: false,
    );
  }
void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
  
  @override
    Future close() {
      stopLocationTracking();
      return super.close();
    }
  }