// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/features/common/presentation/pages/login_screen.dart';
// import 'package:ride_sharing_app/features/common/presentation/pages/mode_selection_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State {
//   @override
//   void initState() {
//     super.initState();
//     _navigateBasedOnAuth();
//   }

//   void _navigateBasedOnAuth() {
//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;
      
//       final authState = context.read<AuthCubit>().state;
      
//       if (authState is Authenticated) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const LoginScreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.green[400]!, Colors.green[700]!],
//           ),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.local_taxi,
//                 size: 100,
//                 color: Colors.white,
//               ),
//               SizedBox(height: 24),
//               Text(
//                 'InDrive Clone',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16),
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation(Colors.white),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }