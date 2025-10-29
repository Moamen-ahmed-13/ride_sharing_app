// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ride_sharing_app/features/past/driver/data/models/bid_model.dart';
// import 'package:ride_sharing_app/features/rider/data/models/ride_model.dart';

// class RideRemoteDatasource {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future createRide(RideModel ride) async {
//     final doc = await _firestore
//         .collection('rides')
//         .add(ride.toJson() as Map<String, dynamic>);
//     return ride.copyWith(id: doc.id);
//   }

//   Stream<List> getRides() {
//     return _firestore
//         .collection('rides')
//         .where('status', isEqualTo: 'pending')
//         .snapshots()
//         .map((snap) {
//           return snap.docs.map((e) {
//             return RideModel.fromJson({...e.data(), 'id': e.id});
//           }).toList();
//         });
//   }

//   Stream getRideById(String rideId) {
//     return _firestore.collection('rides').doc(rideId).snapshots().map((snap) {
//       if (!snap.exists) return null;
//       return RideModel.fromJson({...snap.data()!, 'id': snap.id});
//     });
//   }

//   Future placeBid(BidModel bid) async {
//     await _firestore
//         .collection('bids')
//         .add(bid.toJson() as Map<String, dynamic>);
//     await _firestore.collection('rides').doc(bid.rideId).update({
//       'bids': FieldValue.arrayUnion([bid.toJson() as Map<String, dynamic>]),
//     });
//   }

//   Future acceptBid(String rideId, String driverId) async {
//     await _firestore.collection('bids').doc(rideId).update({
//       'acceptedDriverId': driverId,
//       'status': RideStatus.bidAccepted.name,
//     });
//   }

//   Future updateRideStatus(String rideId, RideStatus status) async {
//     await _firestore.collection('rides').doc(rideId).update({
//       'status': status.name,
//     });
//   }

//   Stream<List> getDriverActiveRides(String driverId) {
//     return _firestore
//         .collection('rides')
//         .where('acceptedDriverId', isEqualTo: driverId)
//         .where(
//           'status',
//           whereIn: [
//             RideStatus.bidAccepted.name,
//             RideStatus.driverArriving.name,
//             RideStatus.ongoing.name,
//           ],
//         )
//         .snapshots()
//         .map((snap) {
//           return snap.docs.map((e) {
//             return RideModel.fromJson({...e.data(), 'id': e.id});
//           }).toList();
//         });
//   }

//   Stream<List> getRiderActiveRides(String riderId) {
//     return _firestore
//         .collection('rides')
//         .where('riderId', isEqualTo: riderId)
//         .where(
//           'status',
//           whereIn: [
//             RideStatus.waitingForBids.name,
//             RideStatus.bidAccepted.name,
//             RideStatus.driverArriving.name,
//             RideStatus.ongoing.name,
//           ],
//         )
//         .snapshots()
//         .map((snap) {
//           return snap.docs.map((e) {
//             return RideModel.fromJson({...e.data(), 'id': e.id});
//           }).toList();
//         });
//   }
// }
