// import 'package:equatable/equatable.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';

// abstract class RideState extends Equatable {
//   const RideState();

//   @override
//   List get props => [];
// }

// class RideInitial extends RideState {}

// class RideLoading extends RideState {}

// class RideCreated extends RideState {
//   final RideModel ride;

//   const RideCreated(this.ride);

//   @override
//   List get props => [ride];
// }

// class RideUpdated extends RideState {
//   final RideModel ride;

//   const RideUpdated(this.ride);

//   @override
//   List get props => [ride];
// }

// class AvailableRidesLoaded extends RideState {
//   final List rides;

//   const AvailableRidesLoaded(this.rides);

//   @override
//   List get props => [rides];
// }

// class ActiveRidesLoaded extends RideState {
//   final RideModel rides;

//   const ActiveRidesLoaded(this.rides);

//   @override
//   List get props => [rides];
// }

// class RideCompleted extends RideState {
//   final RideModel ride;

//   const RideCompleted(this.ride);

//   @override
//   List get props => [ride];
// }

// class RideError extends RideState {
//   final String message;

//   const RideError(this.message);

//   @override
//   List get props => [message];
// }
import 'package:equatable/equatable.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/models/user_model.dart';

abstract class RideState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideSearchingDrivers extends RideState {
  final List<UserModel> nearbyDrivers;
  
  RideSearchingDrivers(this.nearbyDrivers);
  
  @override
  List<Object?> get props => [nearbyDrivers];
}

class RideRequested extends RideState {
  final RideModel ride;
  
  RideRequested(this.ride);
  
  @override
  List<Object?> get props => [ride];
}

class RideAccepted extends RideState {
  final RideModel ride;
  final UserModel driver;
  
  RideAccepted(this.ride, this.driver);
  
  @override
  List<Object?> get props => [ride, driver];
}

class RideStarted extends RideState {
  final RideModel ride;
  final UserModel driver;
  
  RideStarted(this.ride, this.driver);
  
  @override
  List<Object?> get props => [ride, driver];
}

class RideCompleted extends RideState {
  final RideModel ride;
  
  RideCompleted(this.ride);
  
  @override
  List<Object?> get props => [ride];
}

class RideCancelled extends RideState {
  final String reason;
  
  RideCancelled(this.reason);
  
  @override
  List<Object?> get props => [reason];
}

class RideError extends RideState {
  final String message;
  
  RideError(this.message);
  
  @override
  List<Object?> get props => [message];
}
