class NotificationItem {
  final String id;
  final String title;
  final String body;
  final int timestamp;
  final bool isRead;
  final String type;
  final Map<String, dynamic> data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.data,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    int? timestamp,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}