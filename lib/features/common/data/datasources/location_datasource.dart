// import 'package:geolocator/geolocator.dart';
// import 'package:ride_sharing_app/models/location_model.dart';
// import 'package:geocoding/geocoding.dart';

// class LocationDatasource {
//   Future getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.',
//       );
//     }
//     final position = await Geolocator.getCurrentPosition();
//     final address = await getAddressFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//     return LocationModel(
//       latitude: position.latitude,
//       longitude: position.longitude,
//       address: address,
//     );
//   }

//   Future getAddressFromCoordinates(double latitude, double longitude) async {
//     try {
//       List placeMarks = await placemarkFromCoordinates(latitude, longitude);
//       if (placeMarks.isNotEmpty) {
//         Placemark place = placeMarks[0];
//         return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
//       }
//       return 'Unknown Location';
//     } on Exception catch (e) {
//       return 'Unknown Location';
//     }
//   }

//   Future getLocationFromAddress(String address) async {
//     try {
//       List locations = await locationFromAddress(address);
//       if (locations.isNotEmpty) {
//         return LocationModel(
//           latitude: locations[0].latitude,
//           longitude: locations[0].longitude,
//           address: address,
//         );
//       }
//       throw Exception('Location not found');
//     } on Exception catch (e) {
//       throw Exception('Failed to get location from address');
//     }
//   }

//   double calculateDistance(double lat1, double lon1, double lat2, double lon2){
//     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2)/1000;
//   }
// }
