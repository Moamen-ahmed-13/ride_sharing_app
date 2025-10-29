// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/ride_remote_datasource.dart';
// import 'package:ride_sharing_app/features/common/presentation/cubit/bid_cubit/bid_state.dart';
// import 'package:ride_sharing_app/features/past/driver/data/models/bid_model.dart';

// class BidCubit extends Cubit<BidState >{
//   final RideRemoteDatasource _rideRemoteDatasource;
//   BidCubit(this._rideRemoteDatasource) : super(BidInitial());

//   Future placeBid({
//     required String riderId,
//     required String driverId,
//     required String driverName,
//     required double bidAmount,
//     double? driverRating,
//     String? message,
//   }) async {
//     emit(BidLoading());
//     try {
//       final bid = BidModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         driverId: driverId,
//         driverName: driverName,
//         rideId: riderId,
//         bidAmount: bidAmount,
//         message: message,
//         createdAt: DateTime.now(),
//         driverRating: driverRating,
//       );
//       await _rideRemoteDatasource.placeBid(bid);
//       emit(BidPlaced(bid));
//     } catch (e) {
//       emit(BidError("Failed to place bid: ${e.toString()}"));
//     }
//   }

//   void resetState() => emit(BidInitial());
// }