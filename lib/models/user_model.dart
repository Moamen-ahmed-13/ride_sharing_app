
// lib/models/user_model.dart
class User {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? phone;
  final double? lat;
  final double? lng;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.lat,
    this.lng,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'rider',
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      lat: _toDoubleNullable(data['lat']),
      lng: _toDoubleNullable(data['lng']),
      vehicleType: data['vehicleType'] as String?,
      vehicleNumber: data['vehicleNumber'] as String?,
      licenseNumber: data['licenseNumber'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : null,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'lat': lat,
      'lng': lng,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    
    return null;
  }
}