import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/cubits/location/location_cubit.dart';
import 'package:ride_sharing_app/cubits/location/location_state.dart';
import 'package:ride_sharing_app/cubits/map/map_cubit.dart';
import 'package:ride_sharing_app/cubits/map/map_state.dart';
import 'package:ride_sharing_app/cubits/ride/ride_cubit.dart';
import 'package:ride_sharing_app/cubits/ride/ride_state.dart';
import 'package:ride_sharing_app/models/ride_model.dart';
import 'package:ride_sharing_app/utils/widgets/app_drawer.dart';
import 'package:ride_sharing_app/utils/widgets/in_app_notification_banner.dart';

class RiderHomeScreen extends StatefulWidget {
  @override
  _RiderHomeScreenState createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePoints = [];
  double? _fare;
  String? _distanceText;
  String? _durationText;
  Timer? _locationTimer;

  bool _isSearchingPickup = true;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _searchController.dispose();
    context.read<RideCubitWithNotifications>().stopWatchingRide();

    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<LocationCubit>().getCurrentLocation(authState.user.id);
    }
  }

  void _startLocationUpdates() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<LocationCubit>().startLocationTracking(authState.user.id);

      _locationTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        context.read<LocationCubit>().getCurrentLocation(authState.user.id);
      });
    }
  }

  void _searchPlaces() {
    if (_searchController.text.trim().isEmpty) return;
    setState(() => _showSearchResults = true);
    context.read<MapCubit>().searchPlaces(_searchController.text);
  }

  void _selectPlace(Map<String, dynamic> place) {
    final location = LatLng(place['lat'], place['lon']);

    setState(() {
      if (_isSearchingPickup) {
        _pickupLocation = location;
      } else {
        _dropoffLocation = location;
      }
      _showSearchResults = false;
      _searchController.clear();
    });

    _mapController.move(location, 15);

    if (_pickupLocation != null && _dropoffLocation != null) {
      context.read<MapCubit>().getDirections(
        _pickupLocation!,
        _dropoffLocation!,
      );
    }
  }

  void _requestRide() async {
    if (_pickupLocation == null || _dropoffLocation == null || _fare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both pickup and dropoff locations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Ride Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance: $_distanceText'),
            Text('Duration: $_durationText'),
            Text('Estimated Fare: \$${_fare!.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final ride = Ride(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        riderId: authState.user.id,
        startLat: _pickupLocation!.latitude,
        startLng: _pickupLocation!.longitude,
        endLat: _dropoffLocation!.latitude,
        endLng: _dropoffLocation!.longitude,
        status: 'requested',
        fare: _fare,
        distance: double.tryParse(_distanceText?.split(' ')[0] ?? '0') ?? 0,
        duration: double.tryParse(_durationText?.split(' ')[0] ?? '0') ?? 0,
      );

      await context.read<RideCubitWithNotifications>().requestRide(
        ride,
        'Rider',
      );

      context.read<RideCubitWithNotifications>().watchRide(ride.id);
      InAppNotificationBanner.show(
        context,
        title: 'Ride Requested 🚗',
        message: 'Searching for nearby drivers...',
        icon: Icons.search,
        color: Colors.blue,
      );
    }
  }

  void _cancelRide(String rideId) async {
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
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<RideCubitWithNotifications>().cancelRide(
        rideId,
        'Rider',
        rideId,
        'Rider',
      );
      setState(() {
        _pickupLocation = null;
        _dropoffLocation = null;
        _routePoints = [];
        _fare = null;
        _distanceText = null;
        _durationText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: BlocListener<RideCubitWithNotifications, RideState>(
        listener: (context, state) {
          if (state is RideError) {
            InAppNotificationBanner.show(
              context,
              title: 'Error',
              message: state.message,
              icon: Icons.error,
              color: Colors.red,
            );
          } else if (state is RideRequested) {
            InAppNotificationBanner.show(
              context,
              title: 'Ride Requested',
              message: 'Searching for nearby drivers...',
              icon: Icons.search,
              color: Colors.blue,
            );
          } else if (state is RideAccepted) {
            InAppNotificationBanner.show(
              context,
              title: 'Driver Found! 🎉',
              message: 'Your driver is on the way',
              icon: Icons.check_circle,
              color: Colors.green,
            );
            _showDriverAcceptedDialog(state.ride);
          } else if (state is RideInProgress) {
            InAppNotificationBanner.show(
              context,
              title: 'Ride Started',
              message: 'Enjoy your trip!',
              icon: Icons.directions_car,
              color: Colors.orange,
            );
          } else if (state is RideCompleted) {
            InAppNotificationBanner.show(
              context,
              title: 'Trip Complete',
              message: 'Thanks for riding with us!',
              icon: Icons.flag,
              color: Colors.purple,
            );

            _showRatingDialog(state.ride);
          } else if (state is RideCancelled) {
            InAppNotificationBanner.show(
              context,
              title: 'Ride Cancelled',
              message: 'Your ride has been cancelled',
              icon: Icons.cancel,
              color: Colors.red,
            );
          }
        },
        child: Stack(
          children: [
            _buildMap(),

            BlocBuilder<RideCubitWithNotifications, RideState>(
              builder: (context, rideState) {
                if (rideState is! RideRequested &&
                    rideState is! RideAccepted &&
                    rideState is! RideInProgress) {
                  return _buildSearchBar();
                }
                return SizedBox.shrink();
              },
            ),

            if (_showSearchResults) _buildSearchResults(),

            BlocBuilder<RideCubitWithNotifications, RideState>(
              builder: (context, rideState) {
                if (rideState is! RideRequested &&
                    rideState is! RideAccepted &&
                    rideState is! RideInProgress) {
                  return _buildLocationButtons();
                }
                return SizedBox.shrink();
              },
            ),

            BlocBuilder<RideCubitWithNotifications, RideState>(
              builder: (context, rideState) {
                if (rideState is RideRequested) {
                  return _buildRideStatusCard(
                    rideState.ride,
                    'Searching for driver...',
                  );
                } else if (rideState is RideAccepted) {
                  return _buildRideStatusCard(
                    rideState.ride,
                    'Driver on the way!',
                  );
                } else if (rideState is RideInProgress) {
                  return _buildRideStatusCard(
                    rideState.ride,
                    'Ride in progress',
                  );
                }
                return SizedBox.shrink();
              },
            ),

            BlocBuilder<RideCubitWithNotifications, RideState>(
              builder: (context, rideState) {
                if (rideState is! RideRequested &&
                    rideState is! RideAccepted &&
                    rideState is! RideInProgress &&
                    _pickupLocation != null &&
                    _dropoffLocation != null) {
                  return _buildRequestButton(rideState);
                }
                return SizedBox.shrink();
              },
            ),

            _buildMyLocationButton(),
            _appDrawer(),
          ],
        ),
      ),
    );
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

  void _showDriverAcceptedDialog(Ride ride) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Driver Accepted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your driver is on the way to pick you up.'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    SizedBox(height: 4),
                    Text(
                      '\$${ride.fare?.toStringAsFixed(2) ?? 'N/A'}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Fare', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.timer, color: Colors.orange),
                    SizedBox(height: 4),
                    Text('5-10', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('mins', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(Ride ride) {
    int rating = 5;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate Your Ride'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How was your experience?'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thank you for your rating!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Submit'),
            ),
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
          if (_pickupLocation == null) {
            _pickupLocation = _currentLocation;
          }
        }

        return BlocBuilder<MapCubit, MapState>(
          builder: (context, mapState) {
            if (mapState is MapDirectionsLoaded) {
              _routePoints = mapState.polyline;
              _fare = mapState.fare;
              _distanceText = mapState.distanceText;
              _durationText = mapState.durationText;
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(0, 0),
                initialZoom: 15.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  additionalOptions: {
                    'attribution': '© OpenStreetMap contributors',
                  },
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    if (_pickupLocation != null)
                      Marker(
                        point: _pickupLocation!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    if (_dropoffLocation != null)
                      Marker(
                        point: _dropoffLocation!,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.flag, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _isSearchingPickup
                  ? 'Search pickup location'
                  : 'Search destination',
              border: InputBorder.none,
              icon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _showSearchResults = false);
                },
              ),
            ),
            onSubmitted: (_) => _searchPlaces(),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (state is MapPlacesLoaded) {
            return Card(
              elevation: 8,
              child: Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.places.length,
                  itemBuilder: (context, index) {
                    final place = state.places[index];
                    return ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blue),
                      title: Text(
                        place['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _selectPlace(place),
                    );
                  },
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLocationButtons() {
    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (_fare != null && _distanceText != null && _durationText != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.directions_car, size: 20),
                        SizedBox(height: 4),
                        Text(_distanceText!),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.access_time, size: 20),
                        SizedBox(height: 4),
                        Text(_durationText!),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.payments, size: 20),
                        SizedBox(height: 4),
                        Text('\$${_fare!.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isSearchingPickup = true);
                    _searchController.clear();
                  },
                  icon: Icon(Icons.location_on),
                  label: Text('Pickup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSearchingPickup
                        ? Colors.green
                        : Colors.grey[300],
                    foregroundColor: _isSearchingPickup
                        ? Colors.white
                        : Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isSearchingPickup = false);
                    _searchController.clear();
                  },
                  icon: Icon(Icons.flag),
                  label: Text('Destination'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isSearchingPickup
                        ? Colors.red
                        : Colors.grey[300],
                    foregroundColor: !_isSearchingPickup
                        ? Colors.white
                        : Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideStatusCard(Ride ride, String status) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fare: \$${ride.fare?.toStringAsFixed(2) ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _cancelRide(ride.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 45),
                ),
                child: Text(
                  'Cancel Ride',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestButton(RideState rideState) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: rideState is RideRequesting ? null : _requestRide,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: rideState is RideRequesting
            ? CircularProgressIndicator()
            : Text(
                'Request Ride',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return Positioned(
      bottom: 120,
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
