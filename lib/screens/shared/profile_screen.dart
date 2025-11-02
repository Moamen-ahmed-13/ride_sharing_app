import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final isDriver = user.role == 'driver';

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDriver
                          ? [Colors.blue[700]!, Colors.blue[900]!]
                          : [Colors.green[700]!, Colors.green[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isDriver ? Icons.local_taxi : Icons.person,
                          size: 50,
                          color: isDriver ? Colors.blue : Colors.green,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isDriver ? 'Driver' : 'Rider',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.email,
                        title: 'Email',
                        value: user.email,
                        iconColor: Colors.blue,
                      ),
                      _buildInfoCard(
                        icon: Icons.badge,
                        title: 'Role',
                        value: isDriver ? 'Driver' : 'Rider',
                        iconColor: Colors.purple,
                      ),
                      _buildInfoCard(
                        icon: Icons.location_on,
                        title: 'Current Location',
                        value: user.lat != null && user.lng != null
                            ? '${user.lat!.toStringAsFixed(4)}, ${user.lng!.toStringAsFixed(4)}'
                            : 'Not available',
                        iconColor: Colors.red,
                      ),
                      _buildInfoCard(
                        icon: Icons.star,
                        title: 'Rating',
                        value: '5.0 ⭐',
                        iconColor: Colors.orange,
                      ),
                      if (isDriver) ...[
                        _buildInfoCard(
                          icon: Icons.directions_car,
                          title: 'Total Rides',
                          value: '0',
                          iconColor: Colors.green,
                        ),
                        _buildInfoCard(
                          icon: Icons.attach_money,
                          title: 'Total Earnings',
                          value: '\$0.00',
                          iconColor: Colors.teal,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}