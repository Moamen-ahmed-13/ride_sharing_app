// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/core/widgets/custom_button.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';
// import 'driver_home_screen.dart';

// class ActiveRideScreen extends StatefulWidget {
//   final RideModel ride;

//   const ActiveRideScreen({Key? key, required this.ride}) : super(key: key);

//   @override
//   State createState() => _ActiveRideScreenState();
// }

// class _ActiveRideScreenState extends State {
//   @override
//   void initState() {
//     super.initState();
//     context.read <RideCubit>().listenToRideUpdates(widget.ride.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocConsumer(
//         listener: (context, state) {
//           if (state is RideCompleted) {
//             if (state.ride.status == RideStatus.completed) {
//               _showCompletionDialog();
//             } else if (state.ride.status == RideStatus.cancelled) {
//               _showCancellationDialog();
//             }
//           }
//         },
//         builder: (context, state) {
//           RideModel currentRide = widget.ride;

//           if (state is RideUpdated || state is ActiveRidesLoaded) {
//             currentRide = state is RideUpdated 
//                 ? state.ride 
//                 : (state as ActiveRidesLoaded).rides;
//           }

//           return Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(
//                     currentRide.pickupLocation.latitude,
//                     currentRide.pickupLocation.longitude,
//                   ),
//                   zoom: 14,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId('pickup'),
//                     position: LatLng(
//                       currentRide.pickupLocation.latitude,
//                       currentRide.pickupLocation.longitude,
//                     ),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueGreen,
//                     ),
//                     infoWindow: const InfoWindow(title: 'Pickup'),
//                   ),
//                   Marker(
//                     markerId: const MarkerId('destination'),
//                     position: LatLng(
//                       currentRide.destinationLocation.latitude,
//                       currentRide.destinationLocation.longitude,
//                     ),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueRed,
//                     ),
//                     infoWindow: const InfoWindow(title: 'Destination'),
//                   ),
//                 },
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//                 zoomControlsEnabled: false,
//               ),
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: _buildAppBar(currentRide),
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: _buildBottomSheet(currentRide),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAppBar(RideModel ride) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             Expanded(
//               child: Text(
//                 _getStatusText(ride.status),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(width: 48),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomSheet(RideModel ride) {
//     final acceptedBid = ride.bids.firstWhere(
//       (bid) => bid.driverId == ride.acceptedDriverId,
//       orElse: () => ride.bids.first,
//     );

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
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: AppColors.primary,
//                   child: Text(
//                     ride.riderName[0].toUpperCase(),
//                     style: const TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         ride.riderName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         '${ride.estimatedDistance.toStringAsFixed(2)} km',
//                         style: TextStyle(color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   '\${acceptedBid.bidAmount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.success,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.phone),
//                   label: const Text('Call'),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     side: const BorderSide(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.message),
//                   label: const Text('Message'),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     side: const BorderSide(color: AppColors.secondary),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (ride.status == RideStatus.bidAccepted)
//             CustomButton(
//               text: 'Start Trip',
//               onPressed: () => _updateRideStatus(ride.id, RideStatus.ongoing),
//             )
//           else if (ride.status == RideStatus.driverArriving)
//             CustomButton(
//               text: 'Arrived at Pickup',
//               onPressed: () => _updateRideStatus(ride.id, RideStatus.ongoing),
//             )
//           else if (ride.status == RideStatus.ongoing)
//             CustomButton(
//               text: 'Complete Trip',
//               onPressed: () => _updateRideStatus(ride.id, RideStatus.completed),
//               backgroundColor: AppColors.success,
//             ),
//         ],
//       ),
//     );
//   }

//   String _getStatusText(RideStatus status) {
//     switch (status) {
//       case RideStatus.bidAccepted:
//         return 'Heading to Pickup';
//       case RideStatus.driverArriving:
//         return 'Arriving at Pickup';
//       case RideStatus.ongoing:
//         return 'Trip in Progress';
//       case RideStatus.completed:
//         return 'Trip Completed';
//       default:
//         return 'Active Ride';
//     }
//   }

//   void _updateRideStatus(String rideId, RideStatus status) {
//     context.read().updateRideStatus(rideId, status);
//   }

//   void _showCompletionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Trip Completed!'),
//         content: const Text('Great job! The trip has been completed successfully.'),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
//                 (route) => false,
//               );
//             },
//             child: const Text('Back to Home'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCancellationDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Ride Cancelled'),
//         content: const Text('The rider has cancelled this ride.'),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
//                 (route) => false,
//               );
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }