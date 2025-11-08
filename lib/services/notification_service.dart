import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String? _fcmToken;
  String? _currentUserId;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    await _requestPermissions();

    await _initializeLocalNotifications();

    _fcmToken = await _fcm.getToken();
    print('FCM Token: $_fcmToken');

    if (_fcmToken != null) {
      await _saveFCMToken(userId, _fcmToken!);
    }

    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _saveFCMToken(userId, newToken);
    });

    _setupMessageHandlers();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      final Map<String, dynamic> data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app: ${message.messageId}');
      _handleNotificationNavigation(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ride_sharing_channel',
      'Ride Sharing Notifications',
      channelDescription: 'Notifications for ride requests and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Ride Sharing',
      message.notification?.body ?? '',
      notificationDetails,
      payload: json.encode(message.data),
    );
  }

  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _db.child('users/$userId/fcmToken').set(token);
      await _db.child('users/$userId/lastTokenUpdate').set(
        ServerValue.timestamp,
      );
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<String?> getUserFCMToken(String userId) async {
    try {
      final snapshot = await _db.child('users/$userId/fcmToken').get();
      if (snapshot.exists) {
        return snapshot.value as String;
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
    return null;
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = await getUserFCMToken(userId);
      if (token == null) {
        print('No FCM token found for user: $userId');
        return;
      }

      await _saveNotificationToDatabase(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );

      print('Notification queued for $userId: $title');
      
      if (userId == _currentUserId) {
        _showDevelopmentNotification(title, body, data);
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _saveNotificationToDatabase({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final notificationRef = _db.child('notifications/$userId').push();
      await notificationRef.set({
        'title': title,
        'body': body,
        'data': data,
        'timestamp': ServerValue.timestamp,
        'read': false,
      });
    } catch (e) {
      print('Error saving notification to database: $e');
    }
  }

  Future<void> _showDevelopmentNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ride_sharing_channel',
      'Ride Sharing Notifications',
      channelDescription: 'Notifications for ride requests and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: json.encode(data),
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    
    switch (type) {
      case 'ride_request':
        print('Navigate to ride request: ${data['rideId']}');
        break;
      case 'ride_accepted':
        print('Navigate to ride details: ${data['rideId']}');
        break;
      case 'ride_started':
        print('Navigate to active ride: ${data['rideId']}');
        break;
      case 'ride_completed':
        print('Navigate to ride rating: ${data['rideId']}');
        break;
      case 'ride_cancelled':
        print('Show cancellation message');
        break;
      default:
        print('Unknown notification type: $type');
    }
  }
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _db.child('notifications/$userId/$notificationId/read').set(true);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _db
          .child('notifications/$userId')
          .orderByChild('read')
          .equalTo(false)
          .get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return data.length;
      }
    } catch (e) {
      print('Error getting unread count: $e');
    }
    return 0;
  }

  Future<void> clearAllNotifications(String userId) async {
    try {
      await _db.child('notifications/$userId').remove();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  String? get fcmToken => _fcmToken;
  Future<void> dispose() async {
    await _localNotifications.cancelAll();
  }
}