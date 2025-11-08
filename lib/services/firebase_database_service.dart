import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/models/user_model.dart';

class DatabaseService {
  final DatabaseReference _database;

  DatabaseService({required DatabaseReference database})
      : _database = database;

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _database.child('users/$uid/role').set(role);
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  Future<void> updateUserLocation(String uid, double lat, double lng) async {
    try {
      await _database.child('users/$uid').update({
        'lat': lat,
        'lng': lng,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      final snapshot = await _database.child('users/$uid').get();

      if (!snapshot.exists || snapshot.value == null) {
        return null;
      }

      final data = _parseMap(snapshot.value);
      if (data == null) {
        print('Error: Invalid user data format');
        return null;
      }

      data['id'] = uid;
      return User.fromMap(data);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Stream<User?> getUserStream(String uid) {
    return _database.child('users/$uid').onValue.map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return null;
        }

        final data = _parseMap(event.snapshot.value);
        if (data == null) {
          print('Error: Invalid data format in user stream');
          return null;
        }

        data['id'] = uid;
        print('📊 User data from Firebase: $data');
        return User.fromMap(data);
      } catch (e) {
        print('Error parsing user stream data: $e');
        return null;
      }
    }).handleError((error) {
      print('User stream error: $error');
    });
  }

  Future<void> createRide(Ride ride) async {
    try {
      await _database.child('rides/${ride.id}').set(ride.toMap());
    } catch (e) {
      print('Error creating ride: $e');
      rethrow;
    }
  }

  Stream<Ride?> getRideStream(String rideId) {
    return _database.child('rides/$rideId').onValue.map((event) {
      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          print('⚠️ Ride stream: null data for $rideId');
          return null;
        }

        final data = _parseMap(event.snapshot.value);
        if (data == null) {
          print('Error: Invalid ride data format');
          return null;
        }

        print('🔄 Ride stream update: $rideId - ${data['status']}');
        return Ride.fromMap(rideId, data);
      } catch (e) {
        print('❌ Error parsing ride data: $e');
        return null;
      }
    }).handleError((error) {
      print('❌ Ride stream error: $error');
    });
  }

  Stream<List<Ride>> getNearbyRides(
    double lat,
    double lng,
    double radiusKm,
  ) {
    return _database.child('rides').onValue.map((event) {
      final List<Ride> rides = [];

      try {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return rides;
        }

        final data = _parseMap(event.snapshot.value);
        if (data == null) {
          return rides;
        }

        data.forEach((key, value) {
          try {
            final rideData = _parseMap(value);
            if (rideData == null) return;

            final ride = Ride.fromMap(key, rideData);

            final distance = _calculateDistance(
              lat,
              lng,
              ride.startLat,
              ride.startLng,
            );

            if (distance <= radiusKm && ride.status == 'requested') {
              rides.add(ride);
            }
          } catch (e) {
            print('Error parsing individual ride: $e');
          }
        });
      } catch (e) {
        print('Error parsing rides data: $e');
      }

      return rides;
    }).handleError((error) {
      print('Nearby rides stream error: $error');
    });
  }

  Future<void> updateRideStatus(
    String rideId,
    String status, {
    String? driverId,
  }) async {
    try {
      final Map<String, dynamic> update = {
        'status': status,
        'lastUpdated': ServerValue.timestamp,
      };

      if (driverId != null) {
        update['driverId'] = driverId;
      }

      await _database.child('rides/$rideId').update(update);
    } catch (e) {
      print('Error updating ride status: $e');
      rethrow;
    }
  }

  Future<void> updateDriverLocationInRide(
    String rideId,
    double lat,
    double lng,
  ) async {
    try {
      await _database.child('rides/$rideId').update({
        'driverCurrentLat': lat,
        'driverCurrentLng': lng,
        'lastLocationUpdate': ServerValue.timestamp,
      });
      print('📍 Driver location updated in ride: $lat, $lng');
    } catch (e) {
      print('❌ Error updating driver location in ride: $e');
      rethrow;
    }
  }

  Future<List<Ride>> getUserRideHistory(String userId, String role) async {
    try {
      final String field = role == 'rider' ? 'riderId' : 'driverId';
      final snapshot = await _database
          .child('rides')
          .orderByChild(field)
          .equalTo(userId)
          .get();

      final List<Ride> rides = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = _parseMap(snapshot.value);
        if (data != null) {
          data.forEach((key, value) {
            try {
              final rideData = _parseMap(value);
              if (rideData != null) {
                rides.add(Ride.fromMap(key, rideData));
              }
            } catch (e) {
              print('Error parsing ride in history: $e');
            }
          });
        }
      }

      return rides;
    } catch (e) {
      print('Error getting user ride history: $e');
      return [];
    }
  }


  Map<String, dynamic>? _parseMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; 

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            pow(sin(dLng / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}