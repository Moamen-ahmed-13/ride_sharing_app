import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/screens/auth/login_screen.dart';
import 'package:ride_sharing_app/screens/driver/earnings_screen.dart';
import 'package:ride_sharing_app/screens/rider/active_ride_screen.dart';
import 'package:ride_sharing_app/screens/rider/search_destination_screen.dart';
import 'package:ride_sharing_app/screens/shared/profile_screen.dart';
import 'package:ride_sharing_app/screens/shared/settings_screen.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';
import 'package:ride_sharing_app/utils/helpers.dart';
import '../../cubits/location/location_cubit.dart';
import '../../cubits/location/location_state.dart';
import '../../cubits/map/map_cubit.dart';
import '../../cubits/map/map_state.dart';
import '../../cubits/ride/ride_cubit.dart';
import '../../cubits/ride/ride_state.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
@override
void initState() {
  super.initState();
  Future.microtask(() {
    if (mounted) {
      final locationCubit = context.read<LocationCubit>();
      locationCubit.getCurrentLocation();
      locationCubit.startLocationTracking();
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: BlocConsumer<LocationCubit, LocationState>(
          listener: (context, locationState) {
            if (locationState is LocationLoaded) {
              // Initialize map with current location
              context.read<MapCubit>().initializeMap(
                LatLng(
                  locationState.position.latitude,
                  locationState.position.longitude,
                ),
              );
            } else if (locationState is LocationUpdating) {
              // Update marker on map
              context.read<MapCubit>().updateCurrentLocationMarker(
                LatLng(
                  locationState.position.latitude,
                  locationState.position.longitude,
                ),
              );
            } else if (locationState is LocationPermissionDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location permission denied'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, locationState) {
            return BlocConsumer<RideCubit, RideState>(
              listener: (context, rideState) {
                if (rideState is RideRequested ||
                    rideState is RideAccepted ||
                    rideState is RideStarted) {
                  // Navigate to active ride screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActiveRideScreen(),
                    ),
                  );
                } else if (rideState is RideError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(rideState.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, rideState) {
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

                    // Top bar with menu and profile
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
                                    // Navigate to profile
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

                    // Search destination card
                    Positioned(
                      top: 100,
                      left: 16,
                      right: 16,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (locationState is LocationLoaded ||
                                locationState is LocationUpdating) {
                              // Navigate to search destination
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchDestinationScreen(
                                    currentLocation:
                                        locationState is LocationLoaded
                                        ? LatLng(
                                            locationState.position.latitude,
                                            locationState.position.longitude,
                                          )
                                        : LatLng(
                                            (locationState as LocationUpdating)
                                                .position
                                                .latitude,
                                            (locationState as LocationUpdating)
                                                .position
                                                .longitude,
                                          ),
                                  ),
                                ),
                              );

                              if (result != null && result is Map) {
                                // Show ride request screen
                                _showRideRequestBottomSheet(
                                  context,
                                  result['pickup'],
                                  result['pickupAddress'],
                                  result['dropoff'],
                                  result['dropoffAddress'],
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(
                                  'Where to?',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
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
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      
    );
  }

  void _showRideRequestBottomSheet(
    BuildContext context,
    LatLng pickup,
    String pickupAddress,
    LatLng dropoff,
    String dropoffAddress,
  ) {
    // Calculate route first
    context.read<MapCubit>().calculateAndDrawRoute(pickup, dropoff);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocBuilder<MapCubit, MapState>(
        builder: (context, mapState) {
          if (mapState is MapRouteCalculated) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
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
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Confirm Ride',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pickup location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.circle,
                          size: 12,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pickupAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dropoff location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dropoffAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trip details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.route, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '${mapState.distance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Distance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(height: 4),
                            Text(
                              '${mapState.duration} min',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.green),
                            const SizedBox(height: 4),
                            Text(
                              '\$${mapState.fare.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Fare',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Request ride button
                  BlocBuilder<RideCubit, RideState>(
                    builder: (context, rideState) {
                      final isLoading = rideState is RideLoading;

                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final rideCubit = context.read<RideCubit>();
                                Navigator.pop(context);
                                rideCubit.requestRide(
                                  pickupLocation: pickup,
                                  pickupAddress: pickupAddress,
                                  dropoffLocation: dropoff,
                                  dropoffAddress: dropoffAddress,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Request Ride',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(50.0),
            child: Center(child: CircularProgressIndicator()),
          );
        },
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
  if (mounted) {
    context.read<LocationCubit>().stopLocationTracking();
  }
  super.dispose();
}
}
