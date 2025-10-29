// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/core/widgets/custom_button.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';
// import 'rider_home_screen.dart';

// class RideRequestScreen extends StatefulWidget {
//   final RideModel ride;

//   const RideRequestScreen({Key? key, required this.ride}) : super(key: key);

//   @override
//   State createState() => _RideRequestScreenState();
// }

// class _RideRequestScreenState extends State {
//   late RideModel currentRide;
  
//   @override
//   void initState() {
//     super.initState();
//     currentRide = widget.ride;
//     context.read <RideCubit>().listenToRideUpdates(widget.ride.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocConsumer(
//         listener: (context, state) {
//           if (state is RideCompleted) {
//             if (state.ride.status == RideStatus.completed) {
//               _showCompletionDialog(true);
//             } else if (state.ride.status == RideStatus.cancelled) {
//               _showCompletionDialog(false);
//             }
//           }
//         },
//         builder: (context, state) {
//           RideModel currentRide = widget.ride;

//           if (state is RideUpdated) {
//             currentRide = state.ride;
//           } else if (state is ActiveRidesLoaded) {
//             currentRide = state.rides;
//           } else if (state is RideCompleted) {
//             currentRide = state.ride;
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
//           _buildRideInfo(ride),
//           const SizedBox(height: 20),
//           if (ride.status == RideStatus.waitingForBids) ...[
//             _buildBidsList(ride),
//           ] else if (ride.status == RideStatus.bidAccepted ||
//               ride.status == RideStatus.driverArriving) ...[
//             _buildDriverInfo(ride),
//           ] else if (ride.status == RideStatus.ongoing) ...[
//             _buildOngoingRideInfo(ride),
//           ],
//           const SizedBox(height: 16),
//           if (ride.status == RideStatus.waitingForBids ||
//               ride.status == RideStatus.bidAccepted)
//             CustomButton(
//               text: 'Cancel Ride',
//               onPressed: () => _cancelRide(ride.id),
//               backgroundColor: AppColors.error,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRideInfo(RideModel ride) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.straighten, color: AppColors.secondary),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${ride.estimatedDistance.toStringAsFixed(2)} km',
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   const Icon(Icons.attach_money, color: AppColors.success),
//                   Text(
//                     '\${ride.suggestedPrice.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: AppColors.success,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBidsList(RideModel ride) {
//     if (ride.bids.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text(
//               'Waiting for drivers to place bids...',
//               style: TextStyle(color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Available Drivers (${ride.bids.length})',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             itemCount: ride.bids.length,
//             itemBuilder: (context, index) {
//               final bid = ride.bids[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: AppColors.primary,
//                     child: Text(bid.driverName[0].toUpperCase()),
//                   ),
//                   title: Text(
//                     bid.driverName,
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: bid.message != null
//                       ? Text(bid.message!)
//                       : Text('Rating: ${bid.driverRating?.toStringAsFixed(1) ?? 'N/A'}'),
//                   trailing: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '\${bid.bidAmount.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: AppColors.success,
//                         ),
//                       ),
//                     ],
//                   ),
//                   onTap: () => _acceptBid(ride.id, bid.driverId),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDriverInfo(RideModel ride) {
//     final acceptedBid = ride.bids.firstWhere(
//       (bid) => bid.driverId == ride.acceptedDriverId,
//       orElse: () => ride.bids.first,
//     );

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.success),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: AppColors.success,
//                 child: Text(
//                   acceptedBid.driverName[0].toUpperCase(),
//                   style: const TextStyle(
//                     fontSize: 24,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       acceptedBid.driverName,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           acceptedBid.driverRating?.toStringAsFixed(1) ?? 'N/A',
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 '\${acceptedBid.bidAmount.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.success,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.phone, color: AppColors.primary),
//                 iconSize: 32,
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.message, color: AppColors.secondary),
//                 iconSize: 32,
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOngoingRideInfo(RideModel ride) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Column(
//         children: [
//           Icon(Icons.directions_car, size: 48, color: AppColors.primary),
//           SizedBox(height: 12),
//           Text(
//             'Ride in Progress',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text('Enjoy your ride!'),
//         ],
//       ),
//     );
//   }

//   String _getStatusText(RideStatus status) {
//     switch (status) {
//       case RideStatus.waitingForBids:
//         return 'Waiting for Drivers';
//       case RideStatus.bidAccepted:
//         return 'Driver Accepted';
//       case RideStatus.driverArriving:
//         return 'Driver Arriving';
//       case RideStatus.ongoing:
//         return 'Ride in Progress';
//       case RideStatus.completed:
//         return 'Ride Completed';
//       case RideStatus.cancelled:
//         return 'Ride Cancelled';
//       default:
//         return 'Unknown Status';
//     }
//   }

//   void _acceptBid(String rideId, String driverId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Accept Bid'),
//         content: const Text('Do you want to accept this driver?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               context.read <RideCubit>().acceptBid(rideId, driverId);
//               Navigator.pop(context);
//             },
//             child: const Text('Accept'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _cancelRide(String rideId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cancel Ride'),
//         content: const Text('Are you sure you want to cancel this ride?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               context.read().cancelRide(rideId);
//               Navigator.pop(context);
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//             child: const Text('Yes, Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCompletionDialog(bool completed) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text(completed ? 'Ride Completed' : 'Ride Cancelled'),
//         content: Text(
//           completed
//               ? 'Thank you for riding with us!'
//               : 'Your ride has been cancelled.',
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
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

