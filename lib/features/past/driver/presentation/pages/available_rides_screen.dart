// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/features/past/driver/presentation/widgets/ride_card.dart';
// import 'bid_dialog.dart';

// class AvailableRidesScreen extends StatelessWidget {
//   final List rides;

//   const AvailableRidesScreen({Key? key, required this.rides}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Available Rides'),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 0,
//       ),
//       body: rides.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.search_off,
//                     size: 80,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No rides available',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: rides.length,
//               itemBuilder: (context, index) {
//                 final ride = rides[index];
//                 return RideCard(ride: ride);
//               },
//             ),
//     );
//   }
// }