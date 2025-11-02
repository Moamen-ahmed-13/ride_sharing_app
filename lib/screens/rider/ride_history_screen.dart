import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';

class RideHistoryScreen extends StatefulWidget {
  @override
  _RideHistoryScreenState createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Ride> _rides = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRideHistory();
  }

  Future<void> _loadRideHistory() async {
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final rides = await _dbService.getUserRideHistory(
          authState.user.id,
          authState.user.role,
        );

        rides.sort((a, b) => b.id.compareTo(a.id));

        setState(() {
          _rides = rides as List<Ride>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load ride history: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String rideId) {
    try {
      final timestamp = int.parse(rideId);
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in_progress':
        return Icons.directions_car;
      case 'accepted':
        return Icons.person_pin_circle;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadRideHistory),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRideHistory,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No ride history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Your completed rides will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _rides.length,
      itemBuilder: (context, index) => _buildRideCard(_rides[index]),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRideDetails(ride),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(ride.status),
                        color: _getStatusColor(ride.status),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        ride.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(ride.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatTimestamp(ride.id),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),

              Divider(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, size: 12, color: Colors.green),
                      Container(width: 2, height: 30, color: Colors.grey[300]),
                      Icon(Icons.location_on, size: 16, color: Colors.red),
                    ],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${ride.startLat.toStringAsFixed(4)}, ${ride.startLng.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${ride.endLat.toStringAsFixed(4)}, ${ride.endLng.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (ride.distance != null)
                    Row(
                      children: [
                        Icon(Icons.straighten, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${ride.distance!.toStringAsFixed(1)} km',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  if (ride.fare != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${ride.fare!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRideDetails(Ride ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  'Ride Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Ride ID: ${ride.id}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                SizedBox(height: 24),

                _buildDetailRow(
                  icon: Icons.event,
                  label: 'Date & Time',
                  value: _formatTimestamp(ride.id),
                ),

                _buildDetailRow(
                  icon: Icons.info,
                  label: 'Status',
                  value: ride.status.toUpperCase(),
                  valueColor: _getStatusColor(ride.status),
                ),

                if (ride.fare != null)
                  _buildDetailRow(
                    icon: Icons.payments,
                    label: 'Fare',
                    value: '\$${ride.fare!.toStringAsFixed(2)}',
                    valueColor: Colors.green,
                  ),

                if (ride.distance != null)
                  _buildDetailRow(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '${ride.distance!.toStringAsFixed(2)} km',
                  ),

                if (ride.duration != null)
                  _buildDetailRow(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: '${ride.duration!.toStringAsFixed(0)} min',
                  ),

                Divider(height: 32),

                Text(
                  'Locations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                _buildLocationDetail(
                  icon: Icons.trip_origin,
                  label: 'Pickup',
                  lat: ride.startLat,
                  lng: ride.startLng,
                  color: Colors.green,
                ),

                SizedBox(height: 12),

                _buildLocationDetail(
                  icon: Icons.location_on,
                  label: 'Destination',
                  lat: ride.endLat,
                  lng: ride.endLng,
                  color: Colors.red,
                ),

                SizedBox(height: 24),

                if (ride.status == 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Rating feature coming soon!'),
                          ),
                        );
                      },
                      child: Text('Rate This Ride'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetail({
    required IconData icon,
    required String label,
    required double lat,
    required double lng,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                'Lat: ${lat.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                'Lng: ${lng.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
