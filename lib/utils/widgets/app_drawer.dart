import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/screens/rider/ride_history_screen.dart';
import 'package:ride_sharing_app/screens/shared/notification.dart';
import 'package:ride_sharing_app/screens/shared/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final isDriver = user.role == 'driver';

        return Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [

                _buildDrawerHeader(user.email, user.role),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildSectionHeader('Account'),
                      
                      _buildDrawerTile(
                        context: context,
                        icon: Icons.person,
                        title: 'Profile',
                        subtitle: 'View and edit profile',
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(),
                            ),
                          );
                        },
                      ),

                      _buildDrawerTile(
                        context: context,
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'View all notifications',
                        iconColor: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationCenterScreen(),
                            ),
                          );
                        },
                      ),

                      Divider(height: 1, thickness: 1),

                      _buildSectionHeader('Activity'),
                      
                      _buildDrawerTile(
                        context: context,
                        icon: Icons.history,
                        title: 'Ride History',
                        subtitle: 'View past rides',
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RideHistoryScreen(),
                            ),
                          );
                        },
                      ),

                      if (isDriver) ...[
                        _buildDrawerTile(
                          context: context,
                          icon: Icons.attach_money,
                          title: 'Earnings',
                          subtitle: 'View your earnings',
                          iconColor: Colors.green,
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Earnings feature coming soon!'),
                              ),
                            );
                          },
                        ),
                      ],

                      Divider(height: 1, thickness: 1),

                      _buildSectionHeader('Settings'),
                      
                      _buildDrawerTile(
                        context: context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App preferences',
                        iconColor: Colors.grey,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Settings feature coming soon!'),
                            ),
                          );
                        },
                      ),

                      _buildDrawerTile(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help',
                        iconColor: Colors.teal,
                        onTap: () {
                          Navigator.pop(context);
                          _showHelpDialog(context);
                        },
                      ),

                      _buildDrawerTile(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version & info',
                        iconColor: Colors.indigo,
                        onTap: () {
                          Navigator.pop(context);
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 2),
                _buildLogoutTile(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(String email, String role) {
    final roleDisplay = role == 'driver' ? 'Driver' : 'Rider';
    final roleIcon = role == 'driver' ? Icons.local_taxi : Icons.person;
    final gradientColors = role == 'driver' 
        ? [Colors.blue[700]!, Colors.blue[900]!]
        : [Colors.green[700]!, Colors.green[900]!];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  roleIcon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      roleIcon,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      roleDisplay,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.logout,
          color: Colors.red,
          size: 24,
        ),
      ),
      title: Text(
        'Logout',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); 
              Navigator.pop(context); 
              context.read<AuthCubit>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.teal),
            SizedBox(width: 12),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help?', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('📧 Email: support@rideshare.com'),
            Text('📞 Phone: +1 (555) 123-4567'),
            Text('🌐 Website: www.rideshare.com/help'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.indigo),
            SizedBox(width: 12),
            Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ride Sharing App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 2024.01'),
            SizedBox(height: 16),
            Text(
              'Connect riders and drivers for safe, affordable transportation.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}