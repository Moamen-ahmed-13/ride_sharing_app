import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/services/notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService = NotificationService();

  NotificationCubit() : super(NotificationInitial());

  Future<void> initialize(String userId) async {
    try {
      emit(NotificationLoading());
      await _notificationService.initialize(userId);
      emit(NotificationInitialized());
    } catch (e) {
      emit(NotificationError('Failed to initialize notifications: $e'));
    }
  }

  Future<void> sendRideRequestNotification({
    required String driverId,
    required String rideId,
    required String pickupLocation,
    required String fare,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: driverId,
        title: '🚗 New Ride Request',
        body: 'Pickup: $pickupLocation • Fare: \$$fare',
        data: {
          'type': 'ride_request',
          'rideId': rideId,
          'pickupLocation': pickupLocation,
          'fare': fare,
        },
      );
      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }

  Future<void> sendRideAcceptedNotification({
    required String riderId,
    required String rideId,
    required String driverName,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: riderId,
        title: '✅ Driver Accepted!',
        body: '$driverName is on the way to pick you up',
        data: {
          'type': 'ride_accepted',
          'rideId': rideId,
          'driverName': driverName,
        },
      );
      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }

  Future<void> sendRideStartedNotification({
    required String riderId,
    required String rideId,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: riderId,
        title: '🚀 Ride Started',
        body: 'Your ride has started. Enjoy your trip!',
        data: {
          'type': 'ride_started',
          'rideId': rideId,
        },
      );
      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }

  Future<void> sendRideCompletedNotification({
    required String userId,
    required String rideId,
    required String fare,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: '✨ Ride Completed',
        body: 'Your ride is complete. Total fare: \$$fare',
        data: {
          'type': 'ride_completed',
          'rideId': rideId,
          'fare': fare,
        },
      );
      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }

  Future<void> sendRideCancelledNotification({
    required String userId,
    required String rideId,
    required String cancelledBy,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: '❌ Ride Cancelled',
        body: 'The ride has been cancelled by $cancelledBy',
        data: {
          'type': 'ride_cancelled',
          'rideId': rideId,
          'cancelledBy': cancelledBy,
        },
      );
      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }

  Future<void> sendDriverArrivingNotification({
    required String riderId,
    required String rideId,
    required String eta,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: riderId,
        title: '⏰ Driver Arriving',
        body: 'Your driver will arrive in $eta minutes',
        data: {
          'type': 'driver_arriving',
          'rideId': rideId,
          'eta': eta,
        },
      );
      emit(NotificationSent());
    } catch (e) {
      emit(NotificationError('Failed to send notification: $e'));
    }
  }

  Future<int> getUnreadCount(String userId) async {
    return await _notificationService.getUnreadNotificationCount(userId);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationService.markNotificationAsRead(userId, notificationId);
  }

  Future<void> clearAll(String userId) async {
    await _notificationService.clearAllNotifications(userId);
  }
}