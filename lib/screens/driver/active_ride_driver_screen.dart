import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_app/cubits/map/map_state.dart';
import 'package:ride_sharing_app/utils/constants/app_colors.dart';
import '../../cubits/driver/driver_cubit.dart';
import '../../cubits/driver/driver_state.dart';
import '../../cubits/map/map_cubit.dart';
import '../../models/ride_model.dart';
import '../../models/user_model.dart';
import '../../utils/helpers.dart';

class ActiveRideDriverScreen extends StatefulWidget {
  const ActiveRideDriverScreen({Key? key}) : super(key: key);

  @override
  State<ActiveRideDriverScreen> createState() => _ActiveRideDriverScreenState();
}

class _ActiveRideDriverScreenState extends State<ActiveRideDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DriverCubit, DriverState>(
        listener: (context, state) {
          if (state is DriverRideCompleted) {
            _showCompletionDialog(state.ride);
          }
        },
        builder: (context, state) {
          if (state is DriverRideAccepted) {
            return _buildGoingToPickup(state.ride, state.rider);
          } else if (state is DriverRideInProgress) {
            return _buildGoingToDropoff(state.ride, state.rider);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGoingToPickup(RideModel ride, UserModel rider) {
    return Stack(
      children: [
        BlocBuilder<MapCubit, MapState>(
          builder: (context, mapState) {
            if (mapState is MapLoaded) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(ride.pickupLocation.latitude, ride.pickupLocation.longitude),
                  zoom: 14,
                ),
                markers: mapState.markers,
                polylines: mapState.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Going to Pickup', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                        child: Text(rider.name[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.accent)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rider.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 18, color: AppColors.ratingGold),
                                const SizedBox(width: 4),
                                Text(rider.rating?.toStringAsFixed(1) ?? '5.0', style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.success),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pickupColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: AppColors.pickupColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Location', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(ride.pickupLocation.address ?? 'Pickup location', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.read<DriverCubit>().startRide(ride.rideId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Start Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoingToDropoff(RideModel ride, UserModel rider) {
    return Stack(
      children: [
        BlocBuilder<MapCubit, MapState>(
          builder: (context, mapState) {
            if (mapState is MapLoaded) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(ride.dropoffLocation.latitude, ride.dropoffLocation.longitude),
                  zoom: 14,
                ),
                markers: mapState.markers,
                polylines: mapState.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.rideStarted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_taxi, size: 16, color: AppColors.rideStarted),
                            SizedBox(width: 6),
                            Text('Ride in Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.rideStarted)),
                          ],
                        ),
                      ),
                      Text(Helpers.formatCurrency(ride.fare ?? 0), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.dropoffColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.dropoffColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dropoff Location', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(ride.dropoffLocation.address ?? 'Dropoff location', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.read<DriverCubit>().completeRide(ride.rideId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rideCompleted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Complete Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(RideModel ride) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 80),
            ),
            const SizedBox(height: 24),
            const Text('Ride Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('You earned', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(Helpers.formatCurrency(ride.fare ?? 0), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.success)),
            const SizedBox(height: 8),
            Text('from this trip', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}