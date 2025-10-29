import 'package:equatable/equatable.dart';

class BidModel extends Equatable {
  final String id;
  final String driverId;
  final String driverName;
  final String rideId;
  final double bidAmount;
  final String? message;
  final DateTime createdAt;
  final double? driverRating;

  const BidModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.rideId,
    required this.bidAmount,
    this.message,
    required this.createdAt,
    this.driverRating,
  });

  factory BidModel.fromJson(Map json) {
    return BidModel(
      id: json['id'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      rideId: json['rideId'],
      bidAmount: json['bidAmount'].toDouble(),
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      driverRating: json['driverRating']?.toDouble(),
    );
  }

  Map toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'rideId': rideId,
      'bidAmount': bidAmount,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'driverRating': driverRating,
    };
  }

  @override
  List get props => [id, driverId, rideId, bidAmount];
}