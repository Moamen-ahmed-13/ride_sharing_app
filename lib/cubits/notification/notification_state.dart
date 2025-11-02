abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationInitialized extends NotificationState {}

class NotificationSent extends NotificationState {}

class NotificationReceived extends NotificationState {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  NotificationReceived({
    required this.title,
    required this.body,
    required this.data,
  });
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
