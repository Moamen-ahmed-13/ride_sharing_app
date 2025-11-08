class DatabasePaths {
  static const String users = 'users';
  static String user(String userId) => '$users/$userId';
  static String userRole(String userId) => '$users/$userId/role';
  static String userFcmToken(String userId) => '$users/$userId/fcmToken';
  static String userLastTokenUpdate(String userId) => '$users/$userId/lastTokenUpdate';
  
  static const String rides = 'rides';
  static String ride(String rideId) => '$rides/$rideId';
  static String rideStatus(String rideId) => '$rides/$rideId/status';
  static String rideDriverId(String rideId) => '$rides/$rideId/driverId';
  static String rideDriverLocation(String rideId) => '$rides/$rideId/driverCurrentLat';
  
  static const String notifications = 'notifications';
  static String userNotifications(String userId) => '$notifications/$userId';
  static String notification(String userId, String notificationId) => 
      '$notifications/$userId/$notificationId';
  static String notificationRead(String userId, String notificationId) => 
      '$notifications/$userId/$notificationId/read';

  DatabasePaths._(); 
}