// import 'package:flutter/material.dart';
// import 'package:ride_sharing_app/screens/driver/active_ride_driver_screen.dart';
// import 'package:ride_sharing_app/screens/driver/driver_home_screen.dart';
// import 'package:ride_sharing_app/screens/driver/earnings_screen.dart';
// import 'package:ride_sharing_app/screens/driver/ride_requests_screen.dart';
// import 'package:ride_sharing_app/screens/rider/active_ride_screen.dart';
// import 'package:ride_sharing_app/screens/rider/ride_history_screen.dart';
// import 'package:ride_sharing_app/screens/rider/rider_screen.dart';
// import 'package:ride_sharing_app/screens/shared/profile_screen.dart';
// import 'package:ride_sharing_app/screens/shared/settings_screen.dart';
// import 'package:ride_sharing_app/screens/shared/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/signup_screen.dart';
// import '../screens/auth/role_selection_screen.dart';
// import '../screens/rider/search_destination_screen.dart';
// import '../screens/rider/ride_request_screen.dart';
// class AppRouter {
//   // Route names
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String signup = '/signup';
//   static const String roleSelection = '/role-selection';
  
//   // Rider routes
//   static const String riderHome = '/rider/home';
//   static const String searchDestination = '/rider/search-destination';
//   static const String rideRequest = '/rider/ride-request';
//   static const String activeRide = '/rider/active-ride';
//   static const String rideHistory = '/rider/ride-history';
  
//   // Driver routes
//   static const String driverHome = '/driver/home';
//   static const String rideRequests = '/driver/ride-requests';
//   static const String activeRideDriver = '/driver/active-ride';
//   static const String earnings = '/driver/earnings';
  
//   // Shared routes
//   static const String profile = '/profile';
//   static const String settings = '/settings';
  
//   // Generate route
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
      
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
      
//       case signup:
//         return MaterialPageRoute(builder: (_) => const SignupScreen());
      
//       case roleSelection:
//         return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      
//       // Rider routes
//       case riderHome:
//         return MaterialPageRoute(builder: (_) => const RiderHomeScreen());
      
//       case searchDestination:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => SearchDestinationScreen(
//             currentLocation: args?['currentLocation'],
//           ),
//         );
      
//       case rideRequest:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => RideRequestScreen(
//             pickupLocation: args['pickupLocation'],
//             pickupAddress: args['pickupAddress'],
//             dropoffLocation: args['dropoffLocation'],
//             dropoffAddress: args['dropoffAddress'],
//           ),
//         );
      
//       case activeRide:
//         return MaterialPageRoute(builder: (_) => const ActiveRideScreen());
      
//       case rideHistory:
//         return MaterialPageRoute(builder: (_) => const RideHistoryScreen());
      
//       // Driver routes
//       case driverHome:
//         return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      
//       case rideRequests:
//         final args = settings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (_) => RideRequestsScreen(
//             requests: args['requests'],
//           ),
//         );
      
//       case activeRideDriver:
//         return MaterialPageRoute(builder: (_) => const ActiveRideDriverScreen());
      
//       case earnings:
//         return MaterialPageRoute(builder: (_) => const EarningsScreen());
      
//       // Shared routes
//       case profile:
//         return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
//       case settings:
//         return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
  
//   // Navigation helpers
//   static void navigateToLogin(BuildContext context) {
//     Navigator.pushReplacementNamed(context, login);
//   }
  
//   static void navigateToSignup(BuildContext context) {
//     Navigator.pushNamed(context, signup);
//   }
  
//   static void navigateToRiderHome(BuildContext context) {
//     Navigator.pushReplacementNamed(context, riderHome);
//   }
  
//   static void navigateToDriverHome(BuildContext context) {
//     Navigator.pushReplacementNamed(context, driverHome);
//   }
  
//   static void navigateToProfile(BuildContext context) {
//     Navigator.pushNamed(context, profile);
//   }
  
//   static void navigateToSettings(BuildContext context) {
//     Navigator.pushNamed(context, settings);
//   }
  
//   static void navigateToRideHistory(BuildContext context) {
//     Navigator.pushNamed(context, rideHistory);
//   }
  
//   static void navigateToEarnings(BuildContext context) {
//     Navigator.pushNamed(context, earnings);
//   }
  
//   static void pop(BuildContext context) {
//     Navigator.pop(context);
//   }
  
//   static void popUntil(BuildContext context, String routeName) {
//     Navigator.popUntil(context, ModalRoute.withName(routeName));
//   }
// }