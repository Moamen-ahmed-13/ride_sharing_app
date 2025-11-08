import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/notification/notification_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';

class RideCubitWithNotifications extends Cubit<RideState> {
  final DatabaseService _dbService;
  final NotificationCubit _notificationCubit;

  StreamSubscription<List<Ride>>? _ridesSubscription;
  StreamSubscription<Ride?>? _currentRideSubscription;
  String? _watchingRideId;
  RideCubitWithNotifications({
    required DatabaseService databaseService,
    required NotificationCubit notificationCubit,
  }) : _dbService = databaseService,
       _notificationCubit = notificationCubit,
       super(RideInitial());

  void loadNearbyRides(double lat, double lng, {double radiusKm = 5.0}) {
    print('📍 Loading nearby rides...');
    emit(RideLoading());
    _ridesSubscription?.cancel();
    _ridesSubscription = _dbService
        .getNearbyRides(lat, lng, radiusKm)
        .listen(
          (rides) {
            emit(RideListLoaded(rides));
            print('Found ${rides.length} nearby rides.');
          },
          onError: (error) {
            print('❌ Error loading nearby rides: $error');

            emit(RideError(error.toString()));
          },
          cancelOnError: false,
        );
  }

  Future<void> requestRide(Ride ride, String driverName) async {
    try {
      emit(RideRequesting());
      await _dbService.createRide(ride);
      print('✅ Ride created with ID: ${ride.id}');
      await _notificationCubit.sendRideRequestNotification(
        driverId: 'broadcast',
        rideId: ride.id,
        pickupLocation:
            '${ride.startLat.toStringAsFixed(4)}, ${ride.startLng.toStringAsFixed(4)}',
        fare: ride.fare?.toStringAsFixed(2) ?? '0.00',
      );

      watchRide(ride.id);
      emit(RideRequested(ride));
    } catch (e) {
      emit(RideError(e.toString()));
      print('❌Error creating ride: $e');
    }
  }

  void watchRide(String rideId) {
    if (_watchingRideId == rideId && _currentRideSubscription != null) {
      print('⚠️ Already watching ride: $rideId');
      return;
    }
    print('👀 Watching ride with ID: $rideId');
    _currentRideSubscription?.cancel();
    _currentRideSubscription = _dbService
        .getRideStream(rideId)
        .listen(
          (ride) {
            if (ride != null) {
              print('🔄Ride updated: ${ride.id} - ${ride.status}');
              switch (ride.status) {
                case 'requested':
                  emit(RideRequested(ride));
                  break;
                case 'accepted':
                  emit(RideAccepted(ride));
                  break;
                case 'in_progress':
                  emit(RideInProgress(ride));
                  break;
                case 'completed':
                  emit(RideCompleted(ride));
                  _currentRideSubscription?.cancel();
                  break;
                case 'cancelled':
                  emit(RideCancelled(ride));
                  _currentRideSubscription?.cancel();
                  break;
              }
            }
          },
          onError: (error) {
            emit(RideError(error.toString()));
            print('❌Error watching ride: $error');
          },
          cancelOnError: false,
        );
  }

  Future<void> acceptRide(
    String rideId,
    String driverId,
    String riderId,
    String driverName,
  ) async {
    try {
      print('✅ Driver $driverId accepting ride $rideId');
      await _dbService.updateRideStatus(rideId, 'accepted', driverId: driverId);
      print('✅Ride $rideId accepted by driver $driverId');
      await _notificationCubit.sendRideAcceptedNotification(
        riderId: riderId,
        rideId: rideId,
        driverName: driverName,
      );
    } catch (e) {
      print('❌Error accepting ride: $e');
      emit(RideError(e.toString()));
    }
  }

  Future<void> startRide(String rideId, String riderId) async {
    try {
      print('🚀 Starting ride: $rideId');

      await _dbService.updateRideStatus(rideId, 'in_progress');

      await _notificationCubit.sendRideStartedNotification(
        riderId: riderId,
        rideId: rideId,
      );
    } catch (e) {
      print('❌ Error starting ride: $e');
      emit(RideError(e.toString()));
    }
  }

  Future<void> completeRide(
    String rideId,
    String riderId,
    String driverId,
    double fare,
  ) async {
    try {
      print('✅ Completing ride: $rideId');

      await _dbService.updateRideStatus(rideId, 'completed');

      await _notificationCubit.sendRideCompletedNotification(
        userId: riderId,
        rideId: rideId,
        fare: fare.toStringAsFixed(2),
      );

      await _notificationCubit.sendRideCompletedNotification(
        userId: driverId,
        rideId: rideId,
        fare: fare.toStringAsFixed(2),
      );
    } catch (e) {
      print('❌ Error completing ride: $e');

      emit(RideError(e.toString()));
    }
  }

  Future<void> cancelRide(
    String rideId,
    String userId,
    String otherUserId,
    String cancelledBy,
  ) async {
    try {
      print('❌ Cancelling ride: $rideId');

      await _dbService.updateRideStatus(rideId, 'cancelled');
      stopWatchingRide();

      await _notificationCubit.sendRideCancelledNotification(
        userId: otherUserId,
        rideId: rideId,
        cancelledBy: cancelledBy,
      );
    } catch (e) {
      print('❌ Error cancelling ride: $e');

      emit(RideError(e.toString()));
    }
  }

  void stopWatchingRide() {
    print('🛑 Stopped watching ride: $_watchingRideId');
    _currentRideSubscription?.cancel();
    _currentRideSubscription = null;
    _watchingRideId = null;
  }

  @override
  Future<void> close() {
    print('🔴 Closing RideCubit - cancelling all subscriptions');

    _ridesSubscription?.cancel();
    _currentRideSubscription?.cancel();
    return super.close();
  }
}
