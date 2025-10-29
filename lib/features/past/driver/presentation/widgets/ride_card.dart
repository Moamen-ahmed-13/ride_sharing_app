// import 'package:flutter/material.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/features/past/driver/presentation/pages/bid_dialog.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';

// class RideCard extends StatelessWidget {
//   final RideModel ride;

//   const RideCard({required this.ride});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () => _showBidDialog(context),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: AppColors.primary,
//                         child: Text(
//                           ride.riderName[0].toUpperCase(),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             ride.riderName,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             '${_getTimeAgo(ride.createdAt)}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.success.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '\${ride.suggestedPrice.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.success,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _buildLocationInfo(
//                 icon: Icons.my_location,
//                 color: AppColors.primary,
//                 text: ride.pickupLocation.address ?? 'Pickup location',
//               ),
//               const SizedBox(height: 8),
//               _buildLocationInfo(
//                 icon: Icons.location_on,
//                 color: AppColors.error,
//                 text: ride.destinationLocation.address ?? 'Destination',
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   _buildInfoChip(
//                     icon: Icons.straighten,
//                     text: '${ride.estimatedDistance.toStringAsFixed(2)} km',
//                   ),
//                   const SizedBox(width: 12),
//                   _buildInfoChip(
//                     icon: Icons.people,
//                     text: '${ride.bids.length} bids',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//  Widget _buildLocationInfo({
//     required IconData icon,
//     required Color color,
//     required String text,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: color),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(fontSize: 14),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoChip({required IconData icon, required String text}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: Colors.grey[700]),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getTimeAgo(DateTime time) {
//     final difference = DateTime.now().difference(time);
//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else {
//       return '${difference.inDays}d ago';
//     }
//   }

//   void _showBidDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => BidDialog(ride: ride),
//     );
//   }
// }