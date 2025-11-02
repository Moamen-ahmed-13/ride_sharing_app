import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:ride_sharing_app/cubits/map/map_state.dart';
import 'package:ride_sharing_app/services/openstreetmap_service.dart';


class MapCubit extends Cubit<MapState> {
  final OpenStreetMapService _mapService = OpenStreetMapService();

  MapCubit() : super(MapInitial());

  Future<void> getDirections(LatLng start, LatLng end) async {
    emit(MapLoading());
    try {
      final result = await _mapService.getDirections(start, end);
      if (result != null) {
        final fare = _mapService.calculateFare(result['distance']);
        emit(MapDirectionsLoaded(
          result['polyline'],
          result['distance'],
          result['duration'],
          result['distanceText'],
          result['durationText'],
          fare,
        ));
      } else {
        emit(MapError('No route found'));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> searchPlaces(String query) async {
    emit(MapLoading());
    try {
      final places = await _mapService.searchPlaces(query);
      emit(MapPlacesLoaded(places));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  Future<void> getAddressFromCoordinates(LatLng position) async {
    emit(MapLoading());
    try {
      final address = await _mapService.getAddressFromCoordinates(position);
      if (address != null) {
        emit(MapAddressLoaded(address));
      } else {
        emit(MapError('Address not found'));
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }
}