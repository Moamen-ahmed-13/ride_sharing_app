import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/location/location_cubit.dart';
import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
import 'package:ride_sharing_app/cubits/notification/notification_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
import 'package:ride_sharing_app/screens/auth/role_selection_screen.dart';
import 'package:ride_sharing_app/screens/driver/driver_home_screen.dart';
import 'package:ride_sharing_app/screens/rider/rider_screen.dart';
import 'package:ride_sharing_app/screens/shared/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RideSharingApp());
}

class RideSharingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NotificationCubit()),
        BlocProvider(create: (_) => LocationCubit()),
        BlocProvider(
          create: (context) =>
              RideCubitWithNotifications(context.read<NotificationCubit>()),
        ),
        BlocProvider(create: (_) => MapCubit()),
      ],
      child: MaterialApp(
        title: 'Ride Sharing App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.blue,
            secondary: Colors.green,
          ),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<NotificationCubit>().initialize(state.user.id);
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
