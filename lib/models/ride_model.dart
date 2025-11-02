class Ride {
  final String id;
  final String riderId;
  final String? driverId;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String status;
  final double? fare;
  final double? distance;
  final double? duration;
final double? driverCurrentLat;
  final double? driverCurrentLng;
  final int? lastLocationUpdate;
  Ride({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.status,
    this.fare,
    this.distance,
    this.duration,this.driverCurrentLat,
        this.driverCurrentLng,
        this.lastLocationUpdate,
  });

  factory Ride.fromMap(String id, Map<String, dynamic> data) {
    return Ride(
      id: id,
      riderId: data['riderId'] ?? '',
      driverId: data['driverId'],
      startLat: _toDouble(data['startLat']),
      startLng: _toDouble(data['startLng']),
      endLat: _toDouble(data['endLat']),
      endLng: _toDouble(data['endLng']),
      status: data['status'] ?? 'requested',
      fare: _toDoubleNullable(data['fare']),
      distance: _toDoubleNullable(data['distance']),
      duration: _toDoubleNullable(data['duration']),driverCurrentLat: _toDoubleNullable(data['driverCurrentLat']),
            driverCurrentLng: _toDoubleNullable(data['driverCurrentLng']),
            lastLocationUpdate: data['lastLocationUpdate'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'riderId': riderId,
      'driverId': driverId,
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
      'status': status,
      'fare': fare,
      'distance': distance,
      'duration': duration,'driverCurrentLat': driverCurrentLat,
            'driverCurrentLng': driverCurrentLng,
            'lastLocationUpdate': lastLocationUpdate,
    };
  }
 Ride copyWith({
    String? id,
    String? riderId,
    String? driverId,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    String? status,
    double? fare,
    double? distance,
    double? duration,
    double? driverCurrentLat,
    double? driverCurrentLng,
    int? lastLocationUpdate,
  }) {
    return Ride(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      driverId: driverId ?? this.driverId,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      driverCurrentLat: driverCurrentLat ?? this.driverCurrentLat,
      driverCurrentLng: driverCurrentLng ?? this.driverCurrentLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}