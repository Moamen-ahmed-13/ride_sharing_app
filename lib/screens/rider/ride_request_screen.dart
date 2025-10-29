import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../cubits/ride/ride_cubit.dart';
import '../../cubits/ride/ride_state.dart';
import '../../cubits/map/map_cubit.dart';
import '../../cubits/map/map_state.dart';
import '../../models/user_model.dart';

class RideRequestScreen extends StatefulWidget {
  final LatLng pickupLocation;
  final String pickupAddress;
  final LatLng dropoffLocation;
  final String dropoffAddress;

  const RideRequestScreen({
    Key? key,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.dropoffLocation,
    required this.dropoffAddress,
  }) : super(key: key);

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  @override
  void initState() {
    super.initState();
    // Calculate route and search for drivers
    context.read<MapCubit>().calculateAndDrawRoute(
          widget.pickupLocation,
          widget.dropoffLocation,
        );
    context.read<RideCubit>().searchNearbyDrivers(widget.pickupLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Ride'),
        elevation: 0,
      ),
      body: BlocConsumer<RideCubit, RideState>(
        listener: (context, state) {
          if (state is RideRequested) {
            Navigator.pop(context);
          } else if (state is RideError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, rideState) {
          return Column(
            children: [
              // Map preview
              Expanded(
                flex: 2,
                child: BlocBuilder<MapCubit, MapState>(
                  builder: (context, mapState) {
                    if (mapState is MapRouteCalculated) {
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: widget.pickupLocation,
                          zoom: 13,
                        ),
                        markers: mapState.markers,
                        polylines: mapState.polylines,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              // Ride details
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Locations
                      _LocationRow(
                        icon: Icons.circle,
                        iconColor: Colors.green,
                        address: widget.pickupAddress,
                      ),
                      const SizedBox(height: 12),
                      _LocationRow(
                        icon: Icons.location_on,
                        iconColor: Colors.red,
                        address: widget.dropoffAddress,
                      ),
                      const SizedBox(height: 24),

                      // Trip info
                      BlocBuilder<MapCubit, MapState>(
                        builder: (context, mapState) {
                          if (mapState is MapRouteCalculated) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _TripInfoItem(
                                    icon: Icons.route,
                                    label: 'Distance',
                                    value: '${mapState.distance.toStringAsFixed(1)} km',
                                    color: Colors.blue,
                                  ),
                                  _TripInfoItem(
                                    icon: Icons.access_time,
                                    label: 'Time',
                                    value: '${mapState.duration} min',
                                    color: Colors.orange,
                                  ),
                                  _TripInfoItem(
                                    icon: Icons.attach_money,
                                    label: 'Fare',
                                    value: '\$${mapState.fare.toStringAsFixed(2)}',
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Available drivers
                      if (rideState is RideSearchingDrivers) ...[
                        Text(
                          'Available Drivers',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (rideState.nearbyDrivers.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No drivers available nearby',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: rideState.nearbyDrivers.length,
                              itemBuilder: (context, index) {
                                UserModel driver = rideState.nearbyDrivers[index];
                                return _DriverCard(driver: driver);
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Request button
                      ElevatedButton(
                        onPressed: rideState is RideLoading
                            ? null
                            : () {
                                context.read<RideCubit>().requestRide(
                                      pickupLocation: widget.pickupLocation,
                                      pickupAddress: widget.pickupAddress,
                                      dropoffLocation: widget.dropoffLocation,
                                      dropoffAddress: widget.dropoffAddress,
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: rideState is RideLoading
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String address;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _TripInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TripInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  final UserModel driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue[100],
            child: Text(
              driver.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            driver.name.split(' ')[0],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                driver.rating?.toStringAsFixed(1) ?? '5.0',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
