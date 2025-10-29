// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/core/widgets/custom_button.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
// import 'package:ride_sharing_app/cubits/map/map_state.dart';
// import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';

// class SetDestinationScreen extends StatefulWidget {
//   const SetDestinationScreen({Key? key}) : super(key: key);

//   @override
//   State createState() => _SetDestinationScreenState();
// }

// class _SetDestinationScreenState extends State {
//   final _destinationController = TextEditingController();
//   final _priceController = TextEditingController();

//   @override
//   void dispose() {
//     _destinationController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   void _handleSearch() {
//     if (_destinationController.text.isNotEmpty) {
//       context.read<MapCubit>().selectedDestination(_destinationController.text);
//     }
//   }

//   void _handleRequestRide() {
//     final mapState = context.read<MapCubit>().state;
//     final authState = context.read<AuthCubit>().state;

//     if (mapState is DestinationSelected && authState is Authenticated) {
//       final price = double.tryParse(_priceController.text) ?? 0.0;

//       if (price <= 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a valid price')),
//         );
//         return;
//       }

//       context.read <RideCubit>().createRide(
//         riderId: authState.user.id,
//         riderName: authState.user.name,
//         pickupLocation: mapState.currentLocation,
//         destinationLocation: mapState.destinationLocation,
//         distance: mapState.distance,
//         suggestedPrice: price,
//       );

//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set Destination'),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 0,
//       ),
//       body: BlocBuilder(
//         builder: (context, state) {
//           return Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _destinationController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter destination address',
//                     prefixIcon: const Icon(Icons.location_on),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.search),
//                       onPressed: _handleSearch,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   onSubmitted: (_) => _handleSearch(),
//                 ),
//                 const SizedBox(height: 24),
//                 if (state is MapLoading)
//                   const Center(child: CircularProgressIndicator()),
//                 if (state is DestinationSelected) ...[
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.location_on,
//                               color: AppColors.primary,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 state.destinationLocation.address ?? 'Unknown location',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.straighten,
//                               color: AppColors.secondary,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Distance: ${state.distance.toStringAsFixed(2)} km',
//                               style: TextStyle(color: Colors.grey[700]),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Your Price Offer',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: _priceController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your price',
//                       prefixIcon: const Icon(Icons.attach_money),
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   CustomButton(
//                     text: 'Request Ride',
//                     onPressed: _handleRequestRide,
//                   ),
//                 ],
//                 if (state is MapError)
//                   Center(
//                     child: Text(
//                       state.message,
//                       style: const TextStyle(color: AppColors.error),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
