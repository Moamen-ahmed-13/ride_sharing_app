import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/models/user_model.dart';
import 'package:ride_sharing_app/services/fcm_service.dart';
import 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FCMService _fcmService = FCMService();
  
  StreamSubscription? _requestsSubscription;
  StreamSubscription? _currentRideSubscription;
  String? _currentRideId;

  DriverCubit() : super(DriverInitial());

  // Toggle driver availability
  Future<void> toggleAvailability(bool isAvailable) async {
    try {
      String userId = _auth.currentUser!.uid;
      
      await _database.ref('users/$userId').update({
        'isAvailable': isAvailable,
      });

      if (isAvailable) {
        // Start listening to ride requests
        _listenToRideRequests();
      } else {
        // Stop listening
        _requestsSubscription?.cancel();
      }

      emit(DriverAvailable(isAvailable));
    } catch (e) {
      emit(DriverError('Failed to update availability: ${e.toString()}'));
    }
  }

  // Listen to incoming ride requests
  void _listenToRideRequests() {
    _requestsSubscription?.cancel();
    
    _requestsSubscription = _database
        .ref('rides')
        .orderByChild('status')
        .equalTo('pending')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map;
        List<RideModel> requests = [];

        for (var entry in ridesMap.entries) {
          Map<String, dynamic> rideData = 
              Map<String, dynamic>.from(entry.value as Map);
          requests.add(RideModel.fromMap(rideData));
        }

        // Sort by timestamp (newest first)
        requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        emit(DriverRideRequests(requests));
      } else {
        emit(DriverRideRequests([]));
      }
    });
  }

  // Accept a ride request
  Future<void> acceptRide(String rideId) async {
    try {
      String driverId = _auth.currentUser!.uid;

      // Update ride with driver ID and status
      await _database.ref('rides/$rideId').update({
        'driverId': driverId,
        'status': 'accepted',
      });

      // Set driver as unavailable
      await _database.ref('users/$driverId').update({
        'isAvailable': false,
      });

      _currentRideId = rideId;

      // Get ride and rider info
      DatabaseEvent rideEvent = await _database.ref('rides/$rideId').once();
      Map<String, dynamic> rideData = 
          Map<String, dynamic>.from(rideEvent.snapshot.value as Map);
      RideModel ride = RideModel.fromMap(rideData);

      UserModel? rider = await _getRiderInfo(ride.riderId);
      
      if (rider != null) {
        // Notify rider
        await _fcmService.sendNotificationToUser(
          ride.riderId,
          'Ride Accepted',
          'A driver has accepted your ride',
          {'type': 'ride_accepted', 'rideId': rideId, 'driverId': driverId},
        );

        // Listen to ride status
        _listenToCurrentRide(rideId);

        emit(DriverRideAccepted(ride, rider));
      }
    } catch (e) {
      emit(DriverError('Failed to accept ride: ${e.toString()}'));
    }
  }

  // Decline a ride request
  Future<void> declineRide(String rideId) async {
    // Simply don't accept it - other drivers can still see it
    print('Ride $rideId declined');
  }

  // Start the ride (when driver arrives at pickup)
  Future<void> startRide(String rideId) async {
    try {
      await _database.ref('rides/$rideId').update({
        'status': 'started',
      });

      // Get ride and rider info
      DatabaseEvent rideEvent = await _database.ref('rides/$rideId').once();
      Map<String, dynamic> rideData = 
          Map<String, dynamic>.from(rideEvent.snapshot.value as Map);
      RideModel ride = RideModel.fromMap(rideData);

      UserModel? rider = await _getRiderInfo(ride.riderId);

      if (rider != null) {
        // Notify rider
        await _fcmService.sendNotificationToUser(
          ride.riderId,
          'Ride Started',
          'Your ride has started',
          {'type': 'ride_started', 'rideId': rideId},
        );

        emit(DriverRideInProgress(ride, rider));
      }
    } catch (e) {
      emit(DriverError('Failed to start ride: ${e.toString()}'));
    }
  }

  // Complete the ride (when arrived at destination)
  Future<void> completeRide(String rideId) async {
    try {
      String driverId = _auth.currentUser!.uid;

      await _database.ref('rides/$rideId').update({
        'status': 'completed',
      });

      // Set driver as available again
      await _database.ref('users/$driverId').update({
        'isAvailable': true,
      });

      // Get ride info
      DatabaseEvent rideEvent = await _database.ref('rides/$rideId').once();
      Map<String, dynamic> rideData = 
          Map<String, dynamic>.from(rideEvent.snapshot.value as Map);
      RideModel ride = RideModel.fromMap(rideData);

      // Notify rider
      await _fcmService.sendNotificationToUser(
        ride.riderId,
        'Ride Completed',
        'Thank you for riding with us!',
        {'type': 'ride_completed', 'rideId': rideId},
      );

      emit(DriverRideCompleted(ride));
      
      _currentRideSubscription?.cancel();
      _currentRideId = null;

      // Start listening to new requests
      _listenToRideRequests();
    } catch (e) {
      emit(DriverError('Failed to complete ride: ${e.toString()}'));
    }
  }

  // Listen to current ride status
  void _listenToCurrentRide(String rideId) {
    _currentRideSubscription?.cancel();
    
    _currentRideSubscription = _database
        .ref('rides/$rideId')
        .onValue
        .listen((event) async {
      if (event.snapshot.value != null) {
        Map<String, dynamic> rideData = 
            Map<String, dynamic>.from(event.snapshot.value as Map);
        RideModel ride = RideModel.fromMap(rideData);

        if (ride.status == 'cancelled') {
          // Ride was cancelled by rider
          String driverId = _auth.currentUser!.uid;
          await _database.ref('users/$driverId').update({
            'isAvailable': true,
          });

          emit(DriverError('Ride was cancelled by rider'));
          _currentRideSubscription?.cancel();
          _currentRideId = null;
          _listenToRideRequests();
        }
      }
    });
  }

  // Get rider information
  Future<UserModel?> _getRiderInfo(String riderId) async {
    try {
      DatabaseEvent event = await _database.ref('users/$riderId').once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> riderData = 
            Map<String, dynamic>.from(event.snapshot.value as Map);
        return UserModel.fromMap(riderData);
      }
      return null;
    } catch (e) {
      print('Error getting rider info: $e');
      return null;
    }
  }

  // Get earnings/ride history for driver
  Future<Map<String, dynamic>> getEarnings() async {
    try {
      String driverId = _auth.currentUser!.uid;
      
      DatabaseEvent event = await _database
          .ref('rides')
          .orderByChild('driverId')
          .equalTo(driverId)
          .once();

      if (event.snapshot.value == null) {
        return {'totalEarnings': 0.0, 'totalRides': 0, 'rides': []};
      }

      Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map;
      List<RideModel> rides = [];
      double totalEarnings = 0.0;

      for (var entry in ridesMap.entries) {
        Map<String, dynamic> rideData = 
            Map<String, dynamic>.from(entry.value as Map);
        RideModel ride = RideModel.fromMap(rideData);
        
        if (ride.status == 'completed' && ride.fare != null) {
          totalEarnings += ride.fare!;
          rides.add(ride);
        }
      }

      // Sort by timestamp (newest first)
      rides.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return {
        'totalEarnings': totalEarnings,
        'totalRides': rides.length,
        'rides': rides,
      };
    } catch (e) {
      print('Error getting earnings: $e');
      return {'totalEarnings': 0.0, 'totalRides': 0, 'rides': []};
    }
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    _currentRideSubscription?.cancel();
    return super.close();
  }
}
