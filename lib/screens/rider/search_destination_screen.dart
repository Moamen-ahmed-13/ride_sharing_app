import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/maps_service.dart';

class SearchDestinationScreen extends StatefulWidget {
  final LatLng currentLocation;

  const SearchDestinationScreen({
    Key? key,
    required this.currentLocation,
  }) : super(key: key);

  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final MapsService _mapsService = MapsService();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  List<Map<String, dynamic>> _pickupSuggestions = [];
  List<Map<String, dynamic>> _dropoffSuggestions = [];

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  String? _pickupAddress;
  String? _dropoffAddress;

  bool _isSearchingPickup = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocationAddress();
  }

  Future<void> _loadCurrentLocationAddress() async {
    setState(() => _isLoading = true);
    
    String? address = await _mapsService.getAddressFromCoordinates(
      widget.currentLocation,
    );
    
    if (address != null) {
      _pickupController.text = address;
      _pickupLocation = widget.currentLocation;
      _pickupAddress = address;
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _searchPlaces(String query, bool isPickup) async {
    if (query.isEmpty) {
      setState(() {
        if (isPickup) {
          _pickupSuggestions = [];
        } else {
          _dropoffSuggestions = [];
        }
      });
      return;
    }

    List<Map<String, dynamic>> results =
        await _mapsService.searchPlaces(query);

    setState(() {
      if (isPickup) {
        _pickupSuggestions = results;
      } else {
        _dropoffSuggestions = results;
      }
    });
  }

  Future<void> _selectPlace(
    String placeId,
    String description,
    bool isPickup,
  ) async {
    setState(() => _isLoading = true);

    LatLng? location = await _mapsService.getPlaceDetails(placeId);

    if (location != null) {
      setState(() {
        if (isPickup) {
          _pickupLocation = location;
          _pickupAddress = description;
          _pickupController.text = description;
          _pickupSuggestions = [];
        } else {
          _dropoffLocation = location;
          _dropoffAddress = description;
          _dropoffController.text = description;
          _dropoffSuggestions = [];
        }
      });
    }

    setState(() => _isLoading = false);
  }

  void _confirmDestinations() {
    if (_pickupLocation != null && _dropoffLocation != null) {
      Navigator.pop(context, {
        'pickup': _pickupLocation,
        'pickupAddress': _pickupAddress,
        'dropoff': _dropoffLocation,
        'dropoffAddress': _dropoffAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Destinations'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search fields
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pickup field
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.circle, color: Colors.green),
                    hintText: 'Pickup location',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _pickupController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _pickupController.clear();
                              setState(() {
                                _pickupSuggestions = [];
                                _pickupLocation = null;
                                _pickupAddress = null;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _searchPlaces(value, true);
                  },
                  onTap: () {
                    setState(() => _isSearchingPickup = true);
                  },
                ),
                const SizedBox(height: 12),

                // Dropoff field
                TextField(
                  controller: _dropoffController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    hintText: 'Where to?',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _dropoffController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _dropoffController.clear();
                              setState(() {
                                _dropoffSuggestions = [];
                                _dropoffLocation = null;
                                _dropoffAddress = null;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _searchPlaces(value, false);
                  },
                  onTap: () {
                    setState(() => _isSearchingPickup = false);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Suggestions list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _isSearchingPickup
                        ? _pickupSuggestions.length
                        : _dropoffSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _isSearchingPickup
                          ? _pickupSuggestions[index]
                          : _dropoffSuggestions[index];

                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(suggestion['description']),
                        onTap: () {
                          _selectPlace(
                            suggestion['placeId'],
                            suggestion['description'],
                            _isSearchingPickup,
                          );
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _pickupLocation != null && _dropoffLocation != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _confirmDestinations,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Locations',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }
}