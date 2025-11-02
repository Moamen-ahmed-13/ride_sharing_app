import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/notification/notification_cubit.dart';
import 'package:ride_sharing_app/screens/shared/notification.dart';

class NotificationBadge extends StatefulWidget {
  @override
  _NotificationBadgeState createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final count = await context.read<NotificationCubit>().getUnreadCount(
        authState.user.id,
      );
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.grey),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationCenterScreen()),
            );
            _loadUnreadCount();
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
