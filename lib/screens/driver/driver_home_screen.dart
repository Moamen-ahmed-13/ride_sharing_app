import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/screens/auth/login_screen.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';
import 'package:ride_sharing_app/utils/helpers.dart';
import '../../cubits/location/location_cubit.dart';
import '../../cubits/location/location_state.dart';
import '../../cubits/map/map_cubit.dart';
import '../../cubits/map/map_state.dart';
import '../../cubits/driver/driver_cubit.dart';
import '../../cubits/driver/driver_state.dart';
import 'ride_requests_screen.dart';
import 'earnings_screen.dart';
import '../shared/profile_screen.dart';
import '../shared/settings_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().getCurrentLocation();
    context.read<LocationCubit>().startLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MapCubit()),
        BlocProvider(create: (context) => DriverCubit()),
      ],
      child: Scaffold(
        body: BlocConsumer<LocationCubit, LocationState>(
          listener: (context, locationState) {
            if (locationState is LocationLoaded) {
              context.read<MapCubit>().initializeMap(
                LatLng(
                  locationState.position.latitude,
                  locationState.position.longitude,
                ),
              );
            } else if (locationState is LocationUpdating) {
              context.read<MapCubit>().updateCurrentLocationMarker(
                LatLng(
                  locationState.position.latitude,
                  locationState.position.longitude,
                ),
              );
            }
          },
          builder: (context, locationState) {
            return BlocConsumer<DriverCubit, DriverState>(
              listener: (context, driverState) {
                if (driverState is DriverRideRequests &&
                    driverState.pendingRequests.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    enableDrag: false,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => RideRequestsScreen(
                      requests: driverState.pendingRequests,
                    ),
                  );
                }
              },
              builder: (context, driverState) {
                return Stack(
                  children: [
                    // Map
                    BlocBuilder<MapCubit, MapState>(
                      builder: (context, mapState) {
                        if (mapState is MapLoaded) {
                          return GoogleMap(
                            initialCameraPosition: mapState.cameraPosition,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            markers: mapState.markers,
                            polylines: mapState.polylines,
                            onMapCreated: (controller) {
                              context.read<MapCubit>().setMapController(
                                controller,
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),

                    // Top bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () => _showDrawer(context),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(Icons.person),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Availability toggle
                    Positioned(
                      top: 100,
                      left: 16,
                      right: 16,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      (_isAvailable
                                              ? AppColors.success
                                              : Colors.grey)
                                          .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isAvailable
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _isAvailable
                                      ? AppColors.success
                                      : Colors.grey,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isAvailable
                                          ? 'You\'re Online'
                                          : 'You\'re Offline',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isAvailable
                                          ? 'Ready to accept rides'
                                          : 'Go online to receive rides',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isAvailable,
                                onChanged: (value) {
                                  setState(() => _isAvailable = value);
                                  context
                                      .read<DriverCubit>()
                                      .toggleAvailability(value);
                                },
                                activeColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // My location button
                    Positioned(
                      bottom: 100,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: 'myLocation',
                        backgroundColor: Colors.white,
                        onPressed: () {
                          if (locationState is LocationLoaded) {
                            context.read<MapCubit>().moveCameraToLocation(
                              LatLng(
                                locationState.position.latitude,
                                locationState.position.longitude,
                              ),
                            );
                          } else if (locationState is LocationUpdating) {
                            context.read<MapCubit>().moveCameraToLocation(
                              LatLng(
                                locationState.position.latitude,
                                locationState.position.longitude,
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_money, color: AppColors.success),
              ),
              title: const Text(
                'Earnings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EarningsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history, color: AppColors.primary),
              ),
              title: const Text(
                'Trip History',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.accent),
              ),
              title: const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings, color: Colors.grey),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppColors.error),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
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

  @override
  void dispose() {
    context.read<LocationCubit>().stopLocationTracking();
    super.dispose();
  }
}
