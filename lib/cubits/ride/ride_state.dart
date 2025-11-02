
import 'package:ride_sharing_app/models/ride_model.dart';
abstract class RideState {}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideRequesting extends RideState {}

class RideRequested extends RideState {
  final Ride ride;
  RideRequested(this.ride);
}

class RideAccepted extends RideState {
  final Ride ride;
  RideAccepted(this.ride);
}

class RideInProgress extends RideState {
  final Ride ride;
  RideInProgress(this.ride);
}

class RideCompleted extends RideState {
  final Ride ride;
  RideCompleted(this.ride);
}

class RideCancelled extends RideState {
  final Ride ride;
  RideCancelled(this.ride);
}

class RideListLoaded extends RideState {
  final List rides;
  RideListLoaded(this.rides);
}

class RideError extends RideState {
  final String message;
  RideError(this.message);
}