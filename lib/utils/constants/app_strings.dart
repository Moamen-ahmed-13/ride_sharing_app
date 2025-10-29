class AppStrings {
  static const String appName = 'RideSharing';

  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Full Name';
  static const String phone = 'Phone Number';
  static const String logout = 'Logout';

  static const String riderMode = 'Rider Mode';
  static const String driverMode = 'Driver Mode';
  static const String switchToDriver = 'Switch to Driver';
  static const String switchToRider = 'Switch to Rider';

  static const String whereToGo = 'Where do you want to go?';
  static const String pickupLocation = 'Pickup Location';
  static const String destination = 'Destination';
  static const String requestRide = 'Request Ride';
  static const String suggestedPrice = 'Suggested Price';
  static const String distance = 'Distance';
  static const String waitingForDrivers = 'Waiting for drivers...';
  static const String acceptBid = 'Accept Bid';

  static const String placeBid = 'Place Bid';
  static const String yourOffer = 'Your Offer';
  static const String message = 'Message (Optional)';

  static const String waitingForBids = 'Waiting for bids';
  static const String driverArriving = 'Driver is arriving';
  static const String rideStarted = 'Ride started';
  static const String rideCompleted = 'Ride completed';
}

class AppConstants {
  // Firebase paths
  static const String usersPath = 'users';
  static const String ridesPath = 'rides';
  static const String locationsPath = 'locations';

  // Ride statuses
  static const String ridePending = 'pending';
  static const String rideAccepted = 'accepted';
  static const String rideStarted = 'started';
  static const String rideCompleted = 'completed';
  static const String rideCancelled = 'cancelled';

  // User roles
  static const String roleRider = 'rider';
  static const String roleDriver = 'driver';

  // Notification types
  static const String notifRideRequest = 'ride_request';
  static const String notifRideAccepted = 'ride_accepted';
  static const String notifDriverArrived = 'driver_arrived';
  static const String notifRideStarted = 'ride_started';
  static const String notifRideCompleted = 'ride_completed';
  static const String notifRideCancelled = 'ride_cancelled';
}
