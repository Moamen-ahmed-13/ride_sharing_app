// import 'package:equatable/equatable.dart';
// import 'package:ride_sharing_app/features/past/driver/data/models/bid_model.dart';

// abstract class BidState extends Equatable {
//   const BidState();

//   @override
//   List get props => [];
// }

// class BidInitial extends BidState {}

// class BidLoading extends BidState {}

// class BidPlaced extends BidState {
//   final BidModel bid;

//   const BidPlaced(this.bid);

//   @override
//   List get props => [bid];
// }

// class BidAccepted extends BidState {
//   final BidModel bid;

//   const BidAccepted(this.bid);

//   @override
//   List get props => [bid];
// }

// class BidError extends BidState {
//   final String message;

//   const BidError(this.message);

//   @override
//   List get props => [message];
// }