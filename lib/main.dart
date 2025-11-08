import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/location/location_cubit.dart';
import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
import 'package:ride_sharing_app/cubits/notification/notification_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
import 'package:ride_sharing_app/firebase_options.dart';
import 'package:ride_sharing_app/screens/auth/role_selection_screen.dart';
import 'package:ride_sharing_app/screens/driver/driver_home_screen.dart';
import 'package:ride_sharing_app/screens/rider/rider_home_screen.dart';
import 'package:ride_sharing_app/screens/shared/splash_screen.dart';
import 'package:ride_sharing_app/utils/service_locator.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
  };
  runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
  
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        print('Warning: .env file not found. Using default configuration.');
      }
  
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e, stackTrace) {
        print('Firebase initialization failed: $e');
        print('Stack trace: $stackTrace');
        
        runApp(ErrorApp(
          error: 'Failed to initialize app services',
          details: e.toString(),
        ));
        return;
      }
  
      setupDependencies();
  
      runApp(RideSharingApp());
    }, (error, stack) {
      print('Uncaught error: $error');
      print('Stack trace: $stack');
    });
  }
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   await _initializeFirebase();
//   setupDependencies();
//   runApp(RideSharingApp());
// }
// Future<void> _initializeFirebase() async {
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (e, stackTrace) {
//     print('Firebase initialization failed: $e');
//     print('Stack trace: $stackTrace');
    
//     runApp(MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Failed to initialize app. Please try again.'),
//         ),
//       ),
//     ));
//     return;
//   }
// }
class RideSharingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<NotificationCubit>()),
        BlocProvider(create: (_) => getIt<LocationCubit>()),
        BlocProvider(
          create: (context) => getIt<RideCubitWithNotifications>(),
        ),
        BlocProvider(create: (_) => getIt<MapCubit>()),
      ],
      child: MaterialApp(
        title: 'Ride Sharing App',
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSwatch().copyWith(
        //     primary: Colors.blue,
        //     secondary: Colors.green,
        //   ),
        //   primarySwatch: Colors.blue,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        // ),
        home: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {final userId = state.user.id;
                          
                          if (userId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Session error. Please sign in again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            context.read<AuthCubit>().signOut();
                            return;
                          }
            
                          context.read<NotificationCubit>().initialize(userId);
                        } else if (state is AuthUnauthenticated) {
                          context.read<NotificationCubit>().dispose();
                        }
                      },
              
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return SplashScreen();
              } else if (state is AuthAuthenticated) {
                if (state.user.role == 'rider') {
                  return RiderHomeScreen();
                } else if (state.user.role == 'driver') {
                  return DriverHomeScreen();
                }
              }
              return RoleSelectionScreen();
            },
          ),
        ),
      ),
    );
  }
}
class ErrorApp extends StatelessWidget {
  final String error;
  final String details;

  const ErrorApp({
    required this.error,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  details,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}