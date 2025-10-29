import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationPermissionDenied extends LocationState {}

class LocationServiceDisabled extends LocationState {}

class LocationLoaded extends LocationState {
  final Position position;
  final String? address;
  
  LocationLoaded(this.position, {this.address});
  
  @override
  List<Object?> get props => [position, address];
}

class LocationUpdating extends LocationState {
  final Position position;
  
  LocationUpdating(this.position);
  
  @override
  List<Object?> get props => [position];
}

class LocationError extends LocationState {
  final String message;
  
  LocationError(this.message);
  
  @override
  List<Object?> get props => [message];
}
