// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
// import 'package:ride_sharing_app/cubits/map/map_state.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
// import 'package:ride_sharing_app/features/common/presentation/pages/mode_selection_screen.dart';
// import 'package:ride_sharing_app/features/past/presentation/pages/ride_request_screen.dart';
// import 'package:ride_sharing_app/features/past/presentation/pages/set_destination_screen.dart';

// class RiderHomeScreen extends StatefulWidget {
//   const RiderHomeScreen({Key? key}) : super(key: key);

//   @override
//   State createState() => _RiderHomeScreenState();
// }

// class _RiderHomeScreenState extends State {
//   GoogleMapController? _mapController;

//   @override
//   void initState() {
//     super.initState();
//     context.read <MapCubit>().getCurrentLocation();
    
//     final authState = context.read <AuthCubit>().state;
//     if (authState is Authenticated) {
//       context.read().listenToRiderActiveRides(authState.user.id);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener(
//         listener: (context, state) {
//           if (state is RideCreated || state is RideUpdated || state is ActiveRidesLoaded) {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => RideRequestScreen(
//                   ride: state is RideCreated 
//                       ? state.ride 
//                       : state is RideUpdated 
//                           ? state.ride 
//                           : (state as ActiveRidesLoaded).rides,
//                 ),
//               ),
//             );
//           }
//         },
//         child: Stack(
//           children: [
//             BlocBuilder(
//               builder: (context, state) {
//                 if (state is MapLoaded || state is DestinationSelected) {
//                   final location = state is MapLoaded
//                       ? state.currentLocation
//                       : (state as DestinationSelected).currentLocation;

//                   return GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(location.latitude, location.longitude),
//                       zoom: 15,
//                     ),
//                     onMapCreated: (controller) {
//                       _mapController = controller;
//                     },
//                     myLocationEnabled: true,
//                     myLocationButtonEnabled: false,
//                     zoomControlsEnabled: false,
//                     markers: state is DestinationSelected
//                         ? {
//                             Marker(
//                               markerId: const MarkerId('pickup'),
//                               position: LatLng(
//                                 state.currentLocation.latitude,
//                                 state.currentLocation.longitude,
//                               ),
//                               infoWindow: const InfoWindow(title: 'Pickup'),
//                             ),
//                             Marker(
//                               markerId: const MarkerId('destination'),
//                               position: LatLng(
//                                 state.destinationLocation.latitude,
//                                 state.destinationLocation.longitude,
//                               ),
//                               infoWindow: const InfoWindow(title: 'Destination'),
//                             ),
//                           }
//                         : {},
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
//                       backgroundColor: AppColors.primary,
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
//                           'Rider Mode',
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Where to?',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => const SetDestinationScreen(),
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.search, color: Colors.grey),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Search destination',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildQuickAction(
//             icon: Icons.home,
//             title: 'Home',
//             onTap: () {},
//           ),
//           const SizedBox(height: 8),
//           _buildQuickAction(
//             icon: Icons.work,
//             title: 'Work',
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAction({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.grey[200],
//         child: Icon(icon, color: Colors.grey[700]),
//       ),
//       title: Text(title),
//       onTap: onTap,
//       contentPadding: EdgeInsets.zero,
//     );
//   }
// }