import 'package:ride_sharing_app/models/location_model.dart';

class RideModel {
  final String rideId;
  final String riderId;
  final String? driverId;
  final LocationModel pickupLocation;
  final LocationModel dropoffLocation;
  final String status; 
  final double? fare;
  final DateTime timestamp;
  final List<Map<String, double>>? routePolyline;
  final double? distance;
  final int? estimatedTime;

  RideModel({
    required this.rideId,
    required this.riderId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.status,
    this.fare,
    required this.timestamp,
    this.routePolyline,
    this.distance,
    this.estimatedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'riderId': riderId,
      'driverId': driverId,
      'pickupLocation': pickupLocation.toMap(),
      'dropoffLocation': dropoffLocation.toMap(),
      'status': status,
      'fare': fare,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'routePolyline': routePolyline,
      'distance': distance,
      'estimatedTime': estimatedTime,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    return RideModel(
      rideId: map['rideId'] ?? '',
      riderId: map['riderId'] ?? '',
      driverId: map['driverId'],
      pickupLocation: LocationModel.fromMap(map['pickupLocation']),
      dropoffLocation: LocationModel.fromMap(map['dropoffLocation']),
      status: map['status'] ?? 'pending',
      fare: map['fare']?.toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      routePolyline: map['routePolyline'] != null 
          ? List<Map<String, double>>.from(map['routePolyline'])
          : null,
      distance: map['distance']?.toDouble(),
      estimatedTime: map['estimatedTime'],
    );
  }
}
