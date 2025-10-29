// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/auth_remote_datasource.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/location_datasource.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/ride_remote_datasource.dart';
// import 'package:ride_sharing_app/features/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/features/cubits/map/map_cubit.dart';
// import 'package:ride_sharing_app/features/cubits/ride/ride_cubit.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final dio = Dio();
//     final authDataSource = AuthRemoteDatasource();
//     final rideDataSource = RideRemoteDatasource();
//     final locationDataSource = LocationDatasource();

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => AuthCubit(authDataSource)),
//         BlocProvider(create: (_) => RideCubit(rideDataSource)),
//         BlocProvider(create: (_) => MapCubit(locationDataSource)),
//       ],
//       child: MaterialApp(
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: const Color.fromARGB(255, 58, 169, 183),
//           ),
//         ),
//         home: const MyHomePage(title: 'Flutter Demo Home Page'),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: const Center(child: Text('Hello World')),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/location/location_cubit.dart';
import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
import 'package:ride_sharing_app/screens/auth/login_screen.dart';
import 'package:ride_sharing_app/screens/driver/driver_home_screen.dart';
import 'package:ride_sharing_app/screens/rider/rider_screen.dart';
import 'package:ride_sharing_app/screens/shared/splash_screen.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';

class RideSharingApp extends StatelessWidget {
  const RideSharingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()..checkAuthStatus()),
        BlocProvider(create: (_) => LocationCubit()),
        BlocProvider(create: (_) => RideCubit()),
        BlocProvider(create: (_) => MapCubit()),      ],
      child: MaterialApp(
      title: 'Ride Sharing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),

      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const SplashScreen();
          } else if (state is AuthAuthenticated) {
            // Route based on user role
            if (state.userRole == 'rider') {
              return const RiderHomeScreen();
            } else if (state.userRole == 'driver') {
              return const DriverHomeScreen();
            }
          }
          return const LoginScreen();
        },
      ),
    ),
    );


  }
}
