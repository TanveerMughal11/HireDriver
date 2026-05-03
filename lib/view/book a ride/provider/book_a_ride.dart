import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';

class BookRideProvider extends ChangeNotifier {
  bool isReturn = true;
  int selectedVehicle = 0;

  bool isPreviewLoading = false;
  String errorMessage = '';

  LatLng pickupLatLng = const LatLng(31.4801, 74.4008);
  LatLng? destinationLatLng;

  String pickupPlaceId = '';
  String destinationPlaceId = '';

  String pickupText = 'Current Location';
  String destinationText = 'Where to go?';

  void changeTripType(bool value) {
    isReturn = value;
    notifyListeners();
  }

  void changeVehicle(int index) {
    selectedVehicle = index;
    notifyListeners();
  }

  void setPickup({
    required LatLng latLng,
    required String address,
    String placeId = '',
  }) {
    pickupLatLng = latLng;
    pickupText = address;
    pickupPlaceId = placeId;
    notifyListeners();
  }

  void setDestination({
    required LatLng latLng,
    required String address,
    String placeId = '',
  }) {
    destinationLatLng = latLng;
    destinationText = address;
    destinationPlaceId = placeId;
    notifyListeners();
  }

  double calculateDistanceKm() {
    if (destinationLatLng == null) return 0;

    final distanceMeters = Geolocator.distanceBetween(
      pickupLatLng.latitude,
      pickupLatLng.longitude,
      destinationLatLng!.latitude,
      destinationLatLng!.longitude,
    );

    return double.parse((distanceMeters / 1000).toStringAsFixed(1));
  }

  int calculateDurationMinutes(double distanceKm) {
    final minutes = (distanceKm / 18 * 60).round();
    if (minutes < 5) return 5;
    return minutes;
  }

  Map<String, dynamic> buildLocationPayload({
    required String address,
    required String placeId,
    required LatLng coordinates,
  }) {
    return {
      'address': address,
      'placeId': placeId,
      'coordinates': {
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
      },
    };
  }

  Future<Map<String, dynamic>> previewRide() async {
    if (destinationLatLng == null || destinationText == 'Where to go?') {
      return {
        'success': false,
        'message': 'Please select destination first.',
      };
    }

    isPreviewLoading = true;
    errorMessage = '';
    notifyListeners();

    final distanceKm = calculateDistanceKm();
    final durationMinutes = calculateDurationMinutes(distanceKm);
    final tripType = isReturn ? 'return' : 'one-way';

    final pickupPayload = buildLocationPayload(
      address: pickupText,
      placeId: pickupPlaceId,
      coordinates: pickupLatLng,
    );

    final dropoffPayload = buildLocationPayload(
      address: destinationText,
      placeId: destinationPlaceId,
      coordinates: destinationLatLng!,
    );

    final result = await RideApiService.previewRide(
      pickup: pickupPayload,
      dropoff: dropoffPayload,
      tripType: tripType,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
    );

    isPreviewLoading = false;

    if (result['success'] != true) {
      errorMessage = result['message'] ?? 'Ride preview failed';
    }

    notifyListeners();
    return result;
  }
}