// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/core/widgets/custom_button.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/features/common/presentation/cubit/bid_cubit/bid_cubit.dart';
// import 'package:ride_sharing_app/features/common/presentation/cubit/bid_cubit/bid_state.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';

// class BidDialog extends StatefulWidget {
//   final RideModel ride;

//   const BidDialog({Key? key, required this.ride}) : super(key: key);

//   @override
//   State createState() => _BidDialogState();
// }

// class _BidDialogState extends State {
//   final _bidController = TextEditingController();
//   final _messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _bidController.text = widget.ride.suggestedPrice.toStringAsFixed(2);
//   }

//   @override
//   void dispose() {
//     _bidController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _placeBid() {
//     final authState = context.read<AuthCubit>().state;
//     if (authState is! Authenticated) return;

//     final bidAmount = double.tryParse(_bidController.text);
//     if (bidAmount == null || bidAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid bid amount')),
//       );
//       return;
//     }

//     context.read <BidCubit>().placeBid(
//           riderId: widget.ride.id,
//           driverId: authState.user.id,
//           driverName: authState.user.name,
//           bidAmount: bidAmount,
//           driverRating: authState.user.rating ?? 4.5,
//           message: _messageController.text.isNotEmpty 
//               ? _messageController.text 
//               : null,
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener(
//       listener: (context, state) {
//         if (state is BidPlaced) {
//           Navigator.of(context).pop();
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Bid placed successfully!'),
//               backgroundColor: AppColors.success,
//             ),
//           );
//         } else if (state is BidError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: AppColors.error,
//             ),
//           );
//         }
//       },
//       child: Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Place Your Bid',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.person, size: 20),
//                           const SizedBox(width: 8),
//                           Text(
//                             widget.ride.riderName,
//                             style: const TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.straighten, size: 20),
//                           const SizedBox(width: 8),
//                           Text(
//                             '${widget.ride.estimatedDistance.toStringAsFixed(2)} km',
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.attach_money, size: 20),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Suggested: \${widget.ride.suggestedPrice.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.success,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Your Bid Amount',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _bidController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: 'Enter your bid',
//                     prefixIcon: const Icon(Icons.attach_money),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Message (Optional)',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _messageController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     hintText: 'Add a message for the rider...',
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 BlocBuilder(
//                   builder: (context, state) {
//                     return CustomButton(
//                       text: 'Place Bid',
//                       onPressed: _placeBid,
//                       isLoading: state is BidLoading,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }