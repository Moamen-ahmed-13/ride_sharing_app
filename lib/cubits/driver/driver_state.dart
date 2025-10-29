import 'package:equatable/equatable.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/models/user_model.dart';

abstract class DriverState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {}

class DriverAvailable extends DriverState {
  final bool isAvailable;
  
  DriverAvailable(this.isAvailable);
  
  @override
  List<Object?> get props => [isAvailable];
}

class DriverRideRequests extends DriverState {
  final List<RideModel> pendingRequests;
  
  DriverRideRequests(this.pendingRequests);
  
  @override
  List<Object?> get props => [pendingRequests];
}

class DriverRideAccepted extends DriverState {
  final RideModel ride;
  final UserModel rider;
  
  DriverRideAccepted(this.ride, this.rider);
  
  @override
  List<Object?> get props => [ride, rider];
}

class DriverRideInProgress extends DriverState {
  final RideModel ride;
  final UserModel rider;
  
  DriverRideInProgress(this.ride, this.rider);
  
  @override
  List<Object?> get props => [ride, rider];
}

class DriverRideCompleted extends DriverState {
  final RideModel ride;
  
  DriverRideCompleted(this.ride);
  
  @override
  List<Object?> get props => [ride];
}

class DriverError extends DriverState {
  final String message;
  
  DriverError(this.message);
  
  @override
  List<Object?> get props => [message];
}