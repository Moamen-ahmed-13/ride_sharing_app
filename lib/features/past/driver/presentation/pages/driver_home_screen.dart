// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
// import 'package:ride_sharing_app/cubits/map/map_state.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
// import 'package:ride_sharing_app/features/common/presentation/pages/mode_selection_screen.dart';
// import 'package:ride_sharing_app/features/past/driver/presentation/pages/active_ride_screen.dart';
// import 'package:ride_sharing_app/features/past/driver/presentation/pages/available_rides_screen.dart';

// class DriverHomeScreen extends StatefulWidget {
//   const DriverHomeScreen({super.key});

//   @override
//   State createState() => _DriverHomeScreenState();
// }

// class _DriverHomeScreenState extends State {
//   bool _isOnline = false;

//   @override
//   void initState() {
//     super.initState();
//     context.read<MapCubit>().getCurrentLocation();
    
//     final authState = context.read<AuthCubit>().state;
//     if (authState is Authenticated) {
//       context.read<RideCubit>().listenToDriverActiveRides(authState.user.id);
//     }
//   }

//   void _toggleOnline() {
//     setState(() {
//       _isOnline = !_isOnline;
//     });

//     if (_isOnline) {
//       context.read <RideCubit>().listenToAvailableRides();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener(
//         listener: (context, state) {
//           if (state is ActiveRidesLoaded) {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => ActiveRideScreen(ride: state.rides),
//               ),
//             );
//           }
//         },
//         child: Stack(
//           children: [
//             BlocBuilder(
//               builder: (context, state) {
//                 if (state is MapLoaded) {
//                   return GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(
//                         state.currentLocation.latitude,
//                         state.currentLocation.longitude,
//                       ),
//                       zoom: 15,
//                     ),
//                     myLocationEnabled: true,
//                     myLocationButtonEnabled: false,
//                     zoomControlsEnabled: false,
//                   );
//                 }
//                 return const Center(child: CircularProgressIndicator());
//               },
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: _buildTopBar(),
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: _buildBottomSheet(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar() {
//     return BlocBuilder(
//       builder: (context, state) {
//         if (state is! Authenticated) return const SizedBox();

//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: AppColors.success,
//                       child: Text(
//                         state.user.name[0].toUpperCase(),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           state.user.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const Text(
//                           'Driver Mode',
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.swap_horiz),
//                       onPressed: () {
//                         Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(
//                             builder: (_) => const ModeSelectionScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.menu),
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBottomSheet() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _isOnline ? 'You\'re Online' : 'You\'re Offline',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _isOnline
//                         ? 'Looking for rides nearby'
//                         : 'Go online to accept rides',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//               Switch(
//                 value: _isOnline,
//                 onChanged: (_) => _toggleOnline(),
//                 activeColor: AppColors.success,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           if (_isOnline) ...[
//             BlocBuilder(
//               builder: (context, state) {
//                 if (state is AvailableRidesLoaded) {
//                   return Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Available Rides (${state.rides.length})',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (_) => AvailableRidesScreen(
//                                     rides: state.rides,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: const Text('View All'),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       if (state.rides.isEmpty)
//                         Container(
//                           padding: const EdgeInsets.all(24),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.search_off,
//                                 size: 48,
//                                 color: Colors.grey[400],
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 'No rides available right now',
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                             ],
//                           ),
//                         )
//                       else
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: AppColors.secondary),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.local_taxi,
//                                 size: 40,
//                                 color: AppColors.secondary,
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${state.rides.first.estimatedDistance.toStringAsFixed(2)} km away',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Rider: ${state.rides.first.riderName}',
//                                       style: TextStyle(color: Colors.grey[700]),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Text(
//                                 '\${state.rides.first.suggestedPrice.toStringAsFixed(2)}',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.success,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   );
//                 }
//                 return const Center(child: CircularProgressIndicator());
//               },
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }