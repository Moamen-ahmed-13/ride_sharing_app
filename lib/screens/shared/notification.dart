import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/notification/notification_cubit.dart';
import 'package:ride_sharing_app/models/notification_item_model.dart';
import 'package:ride_sharing_app/utils/constants/database_paths.dart';
import 'package:ride_sharing_app/utils/widgets/notification_card.dart';

class NotificationCenterScreen extends StatefulWidget {
  @override
  _NotificationCenterScreenState createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final snapshot = await _db
            .child(DatabasePaths.userNotifications(authState.user.id))   
            .orderByChild('timestamp')
            .limitToLast(50)
            .get();
        
        if (snapshot.exists) {
          final data = snapshot.value as Map;
          final List<NotificationItem> notifications = [];
          
          data.forEach((key, value) {
            final notificationData = Map<String, dynamic>.from(value as Map);
            notifications.add(NotificationItem(
              id: key,
              title: notificationData['title'] ?? '',
              body: notificationData['body'] ?? '',
              timestamp: notificationData['timestamp'] ?? 0,
              isRead: notificationData['read'] ?? false,
              type: notificationData['data']?['type'] ?? 'general',
              data: Map<String, dynamic>.from(notificationData['data'] ?? {}),
            ));
          });
          
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          setState(() {
            _notifications = notifications;
            _isLoading = false;
          });
        } else {
          setState(() {
            _notifications = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      await context.read<NotificationCubit>().markAsRead(
        authState.user.id,
        notificationId,
      );
      
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      for (var notification in _notifications) {
        if (!notification.isRead) {
          await _markAsRead(notification.id);
        }
      }
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Notifications'),
        content: Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        await context.read<NotificationCubit>().clearAll(authState.user.id);
        setState(() => _notifications = []);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _notifications.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see updates about your rides here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return NotificationCard(
            notification: _notifications[index],
            onTap: () => _markAsRead(_notifications[index].id),
          );
        },
      ),
    );
  }
}
