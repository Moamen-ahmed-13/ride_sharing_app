import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/models/user_model.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> updateUserRole(String uid, String role) async {
    await _db.child('users/$uid/role').set(role);
  }

  Future<void> updateUserLocation(String uid, double lat, double lng) async {
    await _db.child('users/$uid').update({
      'lat': lat,
      'lng': lng,
      'lastUpdated': ServerValue.timestamp,
    });
  }

  Future<User?> getUser(String uid) async {
    try {
      final snapshot = await _db.child('users').child(uid).get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is Map) {
          return User.fromMap(Map<String, dynamic>.from(data));
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

Stream<User?> getUserStream(String uid) {
  return _db.child('users/$uid').onValue.map((event) {
    if (event.snapshot.value != null) {
      Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
      
      data['id'] = uid;
              print('📊 User data from Firebase: $data');
      
      return User.fromMap(data);
    }
    return null;
  });
}
  Future<void> saveUser(String uid, User user) async {
    try {
      await _db.child('users').child(uid).set(user.toMap());
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _db.child('users').child(uid).update(updates);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _db.child('users').child(uid).remove();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  Future<bool> userExists(String uid) async {
    try {
      final snapshot = await _db.child('users').child(uid).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }
  Future<void> createRide(Ride ride) async {
    await _db.child('rides/${ride.id}').set(ride.toMap());
  }

 Stream<Ride?> getRideStream(String rideId) {
  return _db.child('rides/$rideId').onValue
    .map((event) {
      try {
        if (event.snapshot.value != null) {
          Map<String, dynamic> data = 
              Map<String, dynamic>.from(event.snapshot.value as Map);
          print('🔄 Ride stream update: $rideId - ${data['status']}');
          return Ride.fromMap(rideId, data);
        }
        print('⚠️ Ride stream: null data for $rideId');
        return null;
      } catch (e) {
        print('❌ Error parsing ride data: $e');
        return null;
      }
    })
    .handleError((error) {
      print('❌ Stream error: $error');
    });
}

  Stream<List<Ride>> getNearbyRides(double lat, double lng, double radiusKm) {
    return _db.child('rides').onValue.map((event) {
      List<Ride> rides = [];
      try {
        if (event.snapshot.value != null) {
          Map<String, dynamic> data = 
              Map<String, dynamic>.from(event.snapshot.value as Map);
          
          data.forEach((key, value) {
            try {
              Ride ride = Ride.fromMap(
                key,
                Map<String, dynamic>.from(value),
              );
              
              double distance = _calculateDistance(
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
        }
      } catch (e) {
        print('Error parsing rides data: $e');
      }
      return rides;
    });
  }

  Future<void> updateRideStatus(
    String rideId,
    String status, {
    String? driverId,
  }) async {
    try {
      Map<String, dynamic> update = {'status': status,'lastUpdated': ServerValue.timestamp,};
      if (driverId != null) update['driverId'] = driverId;
      await _db.child('rides/$rideId').update(update);
    } catch (e) {
      print('Error updating ride status: $e');
      rethrow;
    }
  }

  Future<List<Ride>> getUserRideHistory(String userId, String role) async {
    try {
      String field = role == 'rider' ? 'riderId' : 'driverId';
      final snapshot = await _db
          .child('rides')
          .orderByChild(field)
          .equalTo(userId)
          .get();
      
      List<Ride> rides = [];
      if (snapshot.value != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          try {
            rides.add(Ride.fromMap(key, Map<String, dynamic>.from(value)));
          } catch (e) {
            print('Error parsing ride in history: $e');
          }
        });
      }
      return rides;
    } catch (e) {
      print('Error getting user ride history: $e');
      return [];
    }
  }
Future<void> createUser(String uid, String email, String role) async {
  await _db.child('users/$uid').set({
    'id': uid,
    'email': email,
    'role': role,
    'lat': null,
    'lng': null,
    'createdAt': ServerValue.timestamp,
  });
}


double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const double earthRadius = 6371; 
  
  final dLat = (lat2 - lat1) * (pi / 180);
  final dLng = (lng2 - lng1) * (pi / 180);
  
  final a = pow(sin(dLat / 2), 2) +
      cos(lat1 * pi / 180) * 
      cos(lat2 * pi / 180) * 
      pow(sin(dLng / 2), 2);
  
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return earthRadius * c;
}
}