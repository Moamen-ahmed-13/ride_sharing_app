// import 'dart:async';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/ride_remote_datasource.dart';
// import 'package:ride_sharing_app/models/location_model.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';

// class RideCubit extends Cubit<RideState> {
//   final RideRemoteDatasource _rideRemoteDatasource;
//   StreamSubscription? _rideSubscription;
//   StreamSubscription? _availableRidesSubscription;

//   RideCubit(this._rideRemoteDatasource) : super(RideInitial());

//   Future createRide({
//     required String riderId,
//     required String riderName,
//     required LocationModel pickupLocation,
//     required LocationModel destinationLocation,
//     required double distance,
//     required double suggestedPrice,
//   }) async {
//     emit(RideLoading());
//     try {
//       final ride = RideModel(
//         id: '',
//         riderId: riderId,
//         riderName: riderName,
//         pickupLocation: pickupLocation,
//         destinationLocation: destinationLocation,
//         estimatedDistance: distance,
//         suggestedPrice: suggestedPrice,
//         status: RideStatus.waitingForBids,
//         createdAt: DateTime.now(),
//       );
//       final createdRide = await _rideRemoteDatasource.createRide(ride);
//       emit(RideCreated(createdRide));
//       listenToRideUpdates(createdRide.id);
//     } catch (e) {
//       emit(RideError("Failed to create ride: ${e.toString()}"));
//     }
//   }

//   void listenToRideUpdates(String rideId) {
//     _rideSubscription?.cancel();
//     _rideSubscription = _rideRemoteDatasource.getRideById(rideId).listen((ride) {
//       if (ride != null) {
//         if (ride.status==RideStatus.completed||ride.status==RideStatus.cancelled) {
//           emit(RideCompleted(ride));
//           _rideSubscription?.cancel();
//         } else {
//           emit(RideUpdated(ride));
//         }
//       }
//     }, onError: (e) {
//       emit(RideError("Failed to listen to ride updates: ${e.toString()}"));
//     },
//     );
//   }

//   void listenToAvailableRides() {
//     _availableRidesSubscription?.cancel();
//     _availableRidesSubscription =
//         _rideRemoteDatasource.getRides().listen((rides) {
//       emit(AvailableRidesLoaded(rides));
//     }, onError: (e) {
//       emit(RideError("Failed to listen to available rides: ${e.toString()}"));
//     });
//   }

//   Future acceptBid(String rideId, String driverId) async {
//     try {
//       await _rideRemoteDatasource.acceptBid(rideId, driverId);
//     } catch (e) {
//       emit(RideError("Failed to accept bid: ${e.toString()}"));
//     }
//   }

//   Future updateRideStatus(String rideId, RideStatus status) async {
//     try {
//       await _rideRemoteDatasource.updateRideStatus(rideId, status);
//     } catch (e) {
//       emit(RideError("Failed to update ride status: ${e.toString()}"));
//     }
//   }

//   Future cancelRide(String rideId) async {
//     try {
//       await _rideRemoteDatasource.updateRideStatus(rideId, RideStatus.cancelled);
//     } catch (e) {
//       emit(RideError("Failed to cancel ride: ${e.toString()}"));
//     }
//   }

//   void listenToDriverActiveRides(String driverId) {
//     _rideSubscription?.cancel();
//     _rideSubscription =
//         _rideRemoteDatasource.getDriverActiveRides(driverId).listen((rides) {
//       if (rides.isNotEmpty) {
//         emit(ActiveRidesLoaded(rides.first));
//       }else{
//         emit(RideInitial());
//       }
//     }, onError: (e) {
//       emit(RideError("Failed to listen to driver active rides: ${e.toString()}"));
//     });
//   }

//   void listenToRiderActiveRides(String riderId) {
//     _rideSubscription?.cancel();
//     _rideSubscription =
//         _rideRemoteDatasource.getRiderActiveRides(riderId).listen((rides) {
//       if (rides.isNotEmpty) {
//         emit(ActiveRidesLoaded(rides.first));
//       }else{
//         emit(RideInitial());
//       }
//     }, onError: (e) {
//       emit(RideError("Failed to listen to rider active rides: ${e.toString()}"));
//     });
//   }

//   @override
//   Future<void> close() {
//     _rideSubscription?.cancel();
//     _availableRidesSubscription?.cancel();
//     return super.close();
//   }
// }
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/models/location_model.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/models/user_model.dart';
import 'package:ride_sharing_app/services/fcm_service.dart';
import 'package:ride_sharing_app/services/location_service.dart';
import 'package:ride_sharing_app/services/maps_service.dart';
import 'ride_state.dart';

class RideCubit extends Cubit<RideState> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();
  final MapsService _mapsService = MapsService();
  final FCMService _fcmService = FCMService();
  
  StreamSubscription? _rideSubscription;
  String? _currentRideId;

  RideCubit() : super(RideInitial());

  // Search for nearby available drivers
  Future<void> searchNearbyDrivers(LatLng userLocation) async {
    try {
      emit(RideLoading());

      // Get all available drivers
      DatabaseEvent event = await _database
          .ref('users')
          .orderByChild('role')
          .equalTo('driver')
          .once();

      if (event.snapshot.value == null) {
        emit(RideSearchingDrivers([]));
        return;
      }

      Map<dynamic, dynamic> driversMap = event.snapshot.value as Map;
      List<UserModel> nearbyDrivers = [];

      // Filter drivers who are available and nearby (within 5km)
      for (var entry in driversMap.entries) {
        Map<String, dynamic> driverData = 
            Map<String, dynamic>.from(entry.value as Map);
        
        if (driverData['isAvailable'] == true) {
          // Get driver's location
          DatabaseEvent locEvent = await _database
              .ref('locations/${entry.key}')
              .once();
          
          if (locEvent.snapshot.value != null) {
            Map<String, dynamic> locationData = 
                Map<String, dynamic>.from(locEvent.snapshot.value as Map);
            
            double distance = _locationService.calculateDistance(
              userLocation.latitude,
              userLocation.longitude,
              locationData['latitude'],
              locationData['longitude'],
            );

            // If driver is within 5km
            if (distance <= 5.0) {
              nearbyDrivers.add(UserModel.fromMap(driverData));
            }
          }
        }
      }

      emit(RideSearchingDrivers(nearbyDrivers));
    } catch (e) {
      emit(RideError('Failed to search drivers: ${e.toString()}'));
    }
  }

  // Request a ride
  Future<void> requestRide({
    required LatLng pickupLocation,
    required String pickupAddress,
    required LatLng dropoffLocation,
    required String dropoffAddress,
  }) async {
    try {
      emit(RideLoading());

      String userId = _auth.currentUser!.uid;
      
      // Get directions and calculate fare
      Map<String, dynamic>? directions = await _mapsService.getDirections(
        pickupLocation,
        dropoffLocation,
      );

      if (directions == null) {
        emit(RideError('Failed to get directions'));
        return;
      }

      double distanceInKm = directions['distance'] / 1000;
      double fare = _mapsService.calculateFare(distanceInKm);
      int estimatedTime = (directions['duration'] / 60).round(); // in minutes

      // Create ride request
      DatabaseReference rideRef = _database.ref('rides').push();
      String rideId = rideRef.key!;

      RideModel ride = RideModel(
        rideId: rideId,
        riderId: userId,
        pickupLocation: LocationModel(
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
          address: pickupAddress,
        ),
        dropoffLocation: LocationModel(
          latitude: dropoffLocation.latitude,
          longitude: dropoffLocation.longitude,
          address: dropoffAddress,
        ),
        status: 'pending',
        fare: fare,
        timestamp: DateTime.now(),
        distance: distanceInKm,
        estimatedTime: estimatedTime,
      );

      await rideRef.set(ride.toMap());
      
      _currentRideId = rideId;
      
      // Listen to ride status changes
      _listenToRideStatus(rideId);

      // Notify nearby drivers
      await _notifyNearbyDrivers(rideId, pickupLocation);

      emit(RideRequested(ride));
    } catch (e) {
      emit(RideError('Failed to request ride: ${e.toString()}'));
    }
  }

  // Listen to ride status changes
  void _listenToRideStatus(String rideId) {
    _rideSubscription?.cancel();
    
    _rideSubscription = _database
        .ref('rides/$rideId')
        .onValue
        .listen((event) async {
      if (event.snapshot.value != null) {
        Map<String, dynamic> rideData = 
            Map<String, dynamic>.from(event.snapshot.value as Map);
        RideModel ride = RideModel.fromMap(rideData);

        switch (ride.status) {
          case 'accepted':
            // Get driver info
            UserModel? driver = await _getDriverInfo(ride.driverId!);
            if (driver != null) {
              emit(RideAccepted(ride, driver));
            }
            break;
          case 'started':
            UserModel? driver = await _getDriverInfo(ride.driverId!);
            if (driver != null) {
              emit(RideStarted(ride, driver));
            }
            break;
          case 'completed':
            emit(RideCompleted(ride));
            _rideSubscription?.cancel();
            _currentRideId = null;
            break;
          case 'cancelled':
            emit(RideCancelled('Ride was cancelled'));
            _rideSubscription?.cancel();
            _currentRideId = null;
            break;
        }
      }
    });
  }

  // Get driver information
  Future<UserModel?> _getDriverInfo(String driverId) async {
    try {
      DatabaseEvent event = await _database.ref('users/$driverId').once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> driverData = 
            Map<String, dynamic>.from(event.snapshot.value as Map);
        return UserModel.fromMap(driverData);
      }
      return null;
    } catch (e) {
      print('Error getting driver info: $e');
      return null;
    }
  }

  // Notify nearby drivers about ride request
  Future<void> _notifyNearbyDrivers(String rideId, LatLng pickupLocation) async {
    try {
      // Get nearby drivers
      DatabaseEvent event = await _database
          .ref('users')
          .orderByChild('role')
          .equalTo('driver')
          .once();

      if (event.snapshot.value == null) return;

      Map<dynamic, dynamic> driversMap = event.snapshot.value as Map;

      for (var entry in driversMap.entries) {
        Map<String, dynamic> driverData = 
            Map<String, dynamic>.from(entry.value as Map);
        
        if (driverData['isAvailable'] == true) {
          String driverId = entry.key;
          
          // Send notification
          await _fcmService.sendNotificationToUser(
            driverId,
            'New Ride Request',
            'A rider is requesting a ride near you',
            {
              'type': 'ride_request',
              'rideId': rideId,
            },
          );
        }
      }
    } catch (e) {
      print('Error notifying drivers: $e');
    }
  }

  // Cancel ride
  Future<void> cancelRide(String rideId) async {
    try {
      await _database.ref('rides/$rideId').update({
        'status': 'cancelled',
      });

      // Get ride data to notify driver if accepted
      DatabaseEvent event = await _database.ref('rides/$rideId').once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> rideData = 
            Map<String, dynamic>.from(event.snapshot.value as Map);
        
        if (rideData['driverId'] != null) {
          await _fcmService.sendNotificationToUser(
            rideData['driverId'],
            'Ride Cancelled',
            'The rider has cancelled the ride',
            {'type': 'ride_cancelled', 'rideId': rideId},
          );
        }
      }

      emit(RideCancelled('You cancelled the ride'));
      _rideSubscription?.cancel();
      _currentRideId = null;
    } catch (e) {
      emit(RideError('Failed to cancel ride: ${e.toString()}'));
    }
  }

  // Get ride history
  Future<List<RideModel>> getRideHistory() async {
    try {
      String userId = _auth.currentUser!.uid;
      
      DatabaseEvent event = await _database
          .ref('rides')
          .orderByChild('riderId')
          .equalTo(userId)
          .once();

      if (event.snapshot.value == null) {
        return [];
      }

      Map<dynamic, dynamic> ridesMap = event.snapshot.value as Map;
      List<RideModel> rides = [];

      for (var entry in ridesMap.entries) {
        Map<String, dynamic> rideData = 
            Map<String, dynamic>.from(entry.value as Map);
        rides.add(RideModel.fromMap(rideData));
      }

      // Sort by timestamp (newest first)
      rides.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return rides;
    } catch (e) {
      print('Error getting ride history: $e');
      return [];
    }
  }

  @override
  Future<void> close() {
    _rideSubscription?.cancel();
    return super.close();
  }
}
