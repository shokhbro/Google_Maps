import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  static final _location = Location();

  static bool isSeviceEnabled = false;
  static PermissionStatus permissionStatus = PermissionStatus.denied;
  static LocationData? currentLocation;

  static Future<void> init() async {
    await _checkSevice();
    await _checkPermission();
  }

  //! joylashuvni olish xizmati yoqilganmi tekshiramiz
  static Future<void> _checkSevice() async {
    isSeviceEnabled = await _location.serviceEnabled();
    if (!isSeviceEnabled) {
      _location.requestService();
      if (!isSeviceEnabled) {
        return; // Redirect to Settings  - Sozlamalardan to'g'irlash kerak endi.
      }
    }
  }

  //! joylashuv olish uchun ruxsat berilganmi teshiramiz
  static Future<void> _checkPermission() async {
    permissionStatus = await _location.hasPermission();

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return; // Sozlamalardan to'g'irlash kerak (ruxsat berish kerak)
      }
    }
  }

  //! hozirgi joylashuvni olish
  static Future<void> getCurrentLocation() async {
    if (isSeviceEnabled && permissionStatus == PermissionStatus.granted) {
      currentLocation = await _location.getLocation();
    }
  }

  //! jonli joylashuvni olish
  static Stream<LocationData> getLiveLocation() async* {
    yield* _location.onLocationChanged;
  }

  static Future<List<LatLng>> fetchPolylinePoints(
      LatLng from, LatLng to) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ",
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.transit,
      ),
    );
    if (result.points.isNotEmpty) {
      return result.alternatives
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    }

    return [];
  }
}
