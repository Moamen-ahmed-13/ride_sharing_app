// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/models/user_model.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/features/common/presentation/widgets/mode_card.dart';
// import 'package:ride_sharing_app/features/past/driver/presentation/pages/driver_home_screen.dart';
// import 'package:ride_sharing_app/features/past/presentation/pages/rider_home_screen.dart';

// class ModeSelectionScreen extends StatelessWidget {
//   const ModeSelectionScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder(
//       builder: (context, state) {
//         if (state is! Authenticated) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = state.user;
//         final isDriver = user.currentMode == UserMode.driver;

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (isDriver) {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
//             );
//           } else {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
//             );
//           }
//         });

//         return Scaffold(
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Hello, ${user.name}',
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Choose your mode',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.logout),
//                         onPressed: () {
//                           context.read().logout();
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 60),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ModeCard(
//                           title: 'Rider',
//                           subtitle: 'Request rides and travel',
//                           icon: Icons.person,
//                           color: Colors.blue,
//                           isSelected: !isDriver,
//                           onTap: () {
//                             context.read().switchMode(UserMode.rider);
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                         ModeCard(
//                           title: 'Driver',
//                           subtitle: 'Drive and earn money',
//                           icon: Icons.local_taxi,
//                           color: Colors.green,
//                           isSelected: isDriver,
//                           onTap: () {
//                             context.read().switchMode(UserMode.driver);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
