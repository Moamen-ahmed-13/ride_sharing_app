import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/location/location_cubit.dart';
import 'package:ride_sharing_app/cubits/location/location_state.dart';
import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';
import 'package:ride_sharing_app/utils/service_locator.dart';
import 'package:ride_sharing_app/utils/widgets/app_drawer.dart';
import 'package:ride_sharing_app/utils/widgets/in_app_notification_banner.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final MapController _mapController = MapController();
  final DatabaseService _dbService = DatabaseService(
    database: getIt<DatabaseReference>(),
  );

  LatLng? _currentLocation;
  bool _isOnline = false;
  Timer? _locationTimer;
  Timer? _rideRefreshTimer;
  Timer? _activeRideLocationTimer;
  Ride? _activeRide;
  String? _lastNotificationKey;
  DateTime? _lastNotificationTime;
  final Duration _notificationCooldown = Duration(seconds: 3);
  Set<String> _shownRideIds = {};
  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _debugAuth();
    _startRideRefreshTimer();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _rideRefreshTimer?.cancel();
    _activeRideLocationTimer?.cancel();
    super.dispose();
  }

  bool _shouldShowNotification(String key) {
    final now = DateTime.now();

    if (_lastNotificationKey == key && _lastNotificationTime != null) {
      final timeSinceLastNotification = now.difference(_lastNotificationTime!);
      if (timeSinceLastNotification < _notificationCooldown) {
        print('🚫 Blocked duplicate notification: $key (cooldown active)');
        return false;
      }
    }

    return true;
  }

  void _markNotificationShown(String key) {
    _lastNotificationKey = key;
    _lastNotificationTime = DateTime.now();
  }

  Future<void> _initializeLocation() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      await context.read<LocationCubit>().getCurrentLocation(authState.user.id);
      context.read<LocationCubit>().startLocationTracking(authState.user.id);

      _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        context.read<LocationCubit>().getCurrentLocation(authState.user.id);
      });
    }
  }

  void _showNotification({
    required String key,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    if (_shouldShowNotification(key)) {
      _markNotificationShown(key);
      InAppNotificationBanner.show(
        context,
        title: title,
        message: message,
        icon: icon,
        color: color,
      );
    }
  }

  void _startRideRefreshTimer() {
    _rideRefreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_isOnline && _activeRide == null && _currentLocation != null) {
        print('🔄 Auto-refreshing nearby rides...');
        context.read<RideCubitWithNotifications>().loadNearbyRides(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
      }
    });
  }

  Future<void> _debugAuth() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      print('═══════════════════════════════');
      print('🔐 AUTH DEBUG');
      print('User ID: ${authState.user.id}');
      print('Email: ${authState.user.email}');
      print('Role: ${authState.user.role}');
      print('═══════════════════════════════');
    }
  }

  void _startActiveRideLocationTracking() {
    print('🎯 Starting active ride location tracking...');

    _activeRideLocationTimer?.cancel();
    _activeRideLocationTimer = Timer.periodic(Duration(seconds: 5), (
      timer,
    ) async {
      if (_activeRide != null && _currentLocation != null) {
        await _dbService.updateDriverLocationInRide(
          _activeRide!.id,
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        print(
          '📍 Updated driver location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
        );
      } else {
        print('⚠️ No active ride or location, stopping tracker');
        _stopActiveRideLocationTracking();
      }
    });
  }

  void _stopActiveRideLocationTracking() {
    print('🛑 Stopping active ride location tracking');
    _activeRideLocationTimer?.cancel();
    _activeRideLocationTimer = null;
  }

  void _toggleOnlineStatus() {
    setState(() => _isOnline = !_isOnline);

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      if (_isOnline && _currentLocation != null) {
        _shownRideIds.clear();
        context.read<RideCubitWithNotifications>().loadNearbyRides(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are now online and accepting rides'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        context.read<RideCubitWithNotifications>().stopWatchingRide();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are now offline'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  void _resetToAvailableState() {
    _stopActiveRideLocationTracking();
    setState(() {
      _activeRide = null;
      _isOnline = true;
    });
    _shownRideIds.clear();
    if (_currentLocation != null) {
      context.read<RideCubitWithNotifications>().loadNearbyRides(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
    }

    print('✅ Driver reset to available state');
  }

  void _acceptRide(Ride ride) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Ride Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup: ${ride.startLat.toStringAsFixed(4)}, ${ride.startLng.toStringAsFixed(4)}',
            ),
            SizedBox(height: 8),
            Text(
              'Destination: ${ride.endLat.toStringAsFixed(4)}, ${ride.endLng.toStringAsFixed(4)}',
            ),
            SizedBox(height: 8),
            Text(
              'Fare: \$${ride.fare?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        await context.read<RideCubitWithNotifications>().acceptRide(
          ride.id,
          authState.user.id,
          ride.riderId,
          'Driver',
        );

        setState(() {
          _activeRide = ride;
          _isOnline = false;
        });
        _startActiveRideLocationTracking();

        context.read<RideCubitWithNotifications>().watchRide(ride.id);

        InAppNotificationBanner.show(
          context,
          title: 'Ride Accepted',
          message: 'Navigate to pickup location',
          icon: Icons.navigation,
          color: Colors.green,
        );
      }
    }
  }

  void _startRide(Ride ride) async {
    if (_activeRide == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Ride'),
        content: Text('Have you picked up the passenger?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Start Ride'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<RideCubitWithNotifications>().startRide(
        ride.id,
        ride.riderId,
      );
      InAppNotificationBanner.show(
        context,
        title: 'Ride Started',
        message: 'Your location is being shared with the rider',
        icon: Icons.gps_fixed,
        color: Colors.blue,
      );
    }
  }

  void _completeRide(Ride ride) async {
    if (_activeRide == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Ride'),
        content: Text('Have you reached the destination?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Complete Ride'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        await context.read<RideCubitWithNotifications>().completeRide(
          ride.id,
          ride.riderId,
          authState.user.id,
          ride.fare ?? 0.0,
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _resetToAvailableState();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '💰 Ride completed! You are now available for new rides',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
  }

  void _cancelRide(Ride ride, String cancelledBy) async {
    if (_activeRide == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Ride'),
        content: Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final otherUserId = ride.riderId;

        await context.read<RideCubitWithNotifications>().cancelRide(
          ride.id,
          authState.user.id,
          otherUserId,
          cancelledBy,
        );

        _resetToAvailableState();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ride cancelled. You are now available for new rides',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: BlocListener<RideCubitWithNotifications, RideState>(
        listenWhen: (previous, current) {
          if (previous.runtimeType == current.runtimeType) {
            if (current is RideListLoaded && previous is RideListLoaded) {
              final currentIds = current.rides.map((r) => r.id).toSet();
              final previousIds = previous.rides.map((r) => r.id).toSet();
              return !currentIds.containsAll(previousIds) ||
                  !previousIds.containsAll(currentIds);
            }
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is RideError) {
            _showNotification(
              key: 'ride_error_${state.message}',
              title: 'Error',
              message: state.message,
              icon: Icons.error,
              color: Colors.red,
            );
          } else if (state is RideListLoaded && state.rides.isNotEmpty) {
            if (_activeRide == null && _isOnline) {
              final newRides = state.rides
                  .where((r) => !_shownRideIds.contains(r.id))
                  .toList();

              if (newRides.isNotEmpty) {
                _shownRideIds.addAll(state.rides.map((r) => r.id));

                _showNotification(
                  key: 'new_rides_${newRides.length}',
                  title: 'New Ride Request! 🚗',
                  message: '${newRides.length} new ride(s) available nearby',
                  icon: Icons.car_rental,
                  color: Colors.blue,
                );
              }
            }
          } else if (state is RideAccepted) {
            setState(() => _activeRide = state.ride);
          } else if (state is RideInProgress) {
            _showNotification(
              key: 'trip_started_${state.ride.id}',
              title: 'Trip Started',
              message: 'Drive safely!',
              icon: Icons.directions_car,
              color: Colors.orange,
            );
          } else if (state is RideCompleted) {
            _showNotification(
              key: 'trip_completed_${state.ride.id}',
              title: 'Trip Completed! 🎉',
              message: 'Fare: \$${state.ride.fare?.toStringAsFixed(2)}',
              icon: Icons.check_circle,
              color: Colors.green,
            );
          } else if (state is RideCancelled) {
            if (_activeRide != null) {
              _resetToAvailableState();

              _showNotification(
                key: 'ride_cancelled_${state.ride.id}',
                title: 'Ride Cancelled',
                message:
                    'Rider cancelled the ride. You are now available again.',
                icon: Icons.cancel,
                color: Colors.orange,
              );
            }
          }
        },
        child: Stack(
          children: [
            _buildMap(),

            _buildOnlineToggle(),

            if (_activeRide != null) _buildActiveRideCard(),

            if (_isOnline && _activeRide == null) _buildAvailableRides(),
            _buildMyLocationButton(),
            _appDrawer(),
            _trackMyLocation(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationLoaded) {
          _currentLocation = LatLng(locationState.lat, locationState.lng);
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? LatLng(0, 0),
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              additionalOptions: {
                'attribution': '© OpenStreetMap contributors',
              },
            ),
            MarkerLayer(
              markers: [
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.local_taxi,
                      color: _isOnline ? Colors.green : Colors.black,
                      size: 40,
                    ),
                  ),
                if (_activeRide != null) ...[
                  Marker(
                    point: LatLng(_activeRide!.startLat, _activeRide!.startLng),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  Marker(
                    point: LatLng(_activeRide!.endLat, _activeRide!.endLng),
                    width: 40,
                    height: 40,
                    child: Icon(Icons.flag, color: Colors.red, size: 40),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _trackMyLocation() {
    if (_activeRide != null) {
      return Positioned(
        top: 40,
        right: 16,
        child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_fixed, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'TRACKING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _appDrawer() {
    return Positioned(
      top: 40,
      left: 16,
      child: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu, size: 30, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              AppDrawer();
            },
          );
        },
      ),
    );
  }

  Widget _buildOnlineToggle() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: _isOnline ? Colors.green : Colors.grey[300],
        child: InkWell(
          onTap: _activeRide == null ? _toggleOnlineStatus : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isOnline ? Icons.check_circle : Icons.cancel,
                      color: _isOnline ? Colors.white : Colors.grey[700],
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isOnline ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        Text(
                          _isOnline
                              ? 'Accepting ride requests'
                              : 'Tap to go online',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOnline
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_activeRide == null)
                  Switch(
                    value: _isOnline,
                    onChanged: (_) => _toggleOnlineStatus(),
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.grey[200],
                    activeTrackColor: Colors.green[300],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRideCard() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Ride',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${_activeRide!.fare?.toStringAsFixed(2) ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
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
                          '${_activeRide!.startLat.toStringAsFixed(4)}, ${_activeRide!.startLng.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${_activeRide!.endLat.toStringAsFixed(4)}, ${_activeRide!.endLng.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              BlocBuilder<RideCubitWithNotifications, RideState>(
                builder: (context, state) {
                  if (state is RideAccepted) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _startRide(state.ride),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Start Ride',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _cancelRide(state.ride, 'driver'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Cancel Ride'),
                          ),
                        ),
                      ],
                    );
                  } else if (state is RideInProgress) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _completeRide(state.ride),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Complete Ride',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableRides() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 300),
          child: BlocBuilder<RideCubitWithNotifications, RideState>(
            builder: (context, state) {
              if (state is RideLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is RideListLoaded) {
                if (state.rides.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No ride requests nearby',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Waiting for passengers...',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Rides',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.rides.length}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.rides.length,
                        itemBuilder: (context, index) {
                          final ride = state.rides[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[50],
                              child: Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text(
                              '\$${ride.fare?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${ride.distance?.toStringAsFixed(1) ?? '?'} km away',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _acceptRide(ride),
                              child: Text('Accept'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return Positioned(
      bottom: _activeRide != null ? 240 : (_isOnline ? 200 : 50),
      right: 16,
      child: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 15);
          }
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
