

//enum UserMode { rider, driver }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; 
  final String? fcmToken;
  final double? rating;
  final String? profileImage;
  
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final bool? isAvailable;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.fcmToken,
    this.rating,
    this.profileImage,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcmToken': fcmToken,
      'rating': rating,
      'profileImage': profileImage,
      if (role == 'driver') ...{
        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,
        'licenseNumber': licenseNumber,
        'isAvailable': isAvailable,
      },
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'rider',
      fcmToken: map['fcmToken'],
      rating: map['rating']?.toDouble(),
      profileImage: map['profileImage'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      licenseNumber: map['licenseNumber'],
      isAvailable: map['isAvailable'],
    );
  }
}