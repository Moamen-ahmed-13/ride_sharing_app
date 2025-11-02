
class User {
  final String id;
  final String email;
  final String role;
  final double? lat;
  final double? lng;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.lat,
    this.lng,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '', 
      email: data['email'] ?? '',  
      role: data['role'] ?? 'rider',  
      lat: _toDoubleNullable(data['lat']),
      lng: _toDoubleNullable(data['lng']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'lat': lat,
      'lng': lng,
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