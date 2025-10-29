import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/screens/auth/login_screen.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Account',
            items: [
              _SettingsItem(icon: Icons.person, title: 'Edit Profile', subtitle: 'Update your profile information', onTap: () {}),
              _SettingsItem(icon: Icons.lock, title: 'Change Password', subtitle: 'Update your password', onTap: () {}),
              _SettingsItem(icon: Icons.payment, title: 'Payment Methods', subtitle: 'Manage payment options', onTap: () {}),
            ],
          ),
          _SettingsSection(
            title: 'Notifications',
            items: [
              _SettingsItem(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive ride updates',
                trailing: Switch(value: _pushNotifications, onChanged: (value) => setState(() => _pushNotifications = value), activeColor: AppColors.success),
              ),
              _SettingsItem(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive updates via email',
                trailing: Switch(value: _emailNotifications, onChanged: (value) => setState(() => _emailNotifications = value), activeColor: AppColors.success),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Privacy',
            items: [
              _SettingsItem(
                icon: Icons.location_on,
                title: 'Location Services',
                subtitle: 'Allow location tracking',
                trailing: Switch(value: _locationServices, onChanged: (value) => setState(() => _locationServices = value), activeColor: AppColors.success),
              ),
              _SettingsItem(icon: Icons.security, title: 'Privacy Policy', subtitle: 'Read our privacy policy', onTap: () {}),
            ],
          ),
          _SettingsSection(
            title: 'Support',
            items: [
              _SettingsItem(icon: Icons.help, title: 'Help & Support', subtitle: 'Get help or contact us', onTap: () {}),
              _SettingsItem(icon: Icons.description, title: 'Terms of Service', subtitle: 'Read terms and conditions', onTap: () {}),
              _SettingsItem(icon: Icons.star, title: 'Rate Us', subtitle: 'Share your feedback', onTap: () {}),
            ],
          ),
          _SettingsSection(title: 'About', items: [_SettingsItem(icon: Icons.info, title: 'App Version', subtitle: '1.0.0')]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              Helpers.showSuccessSnackbar(context, 'Logged out successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
        ),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: Colors.grey[600], fontSize: 13)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey[400]) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
