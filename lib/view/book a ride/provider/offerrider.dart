import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';

class DriverOffersProvider extends ChangeNotifier {
  int secondsLeft = 24;
  Timer? timer;

  bool isLoading = true;
  bool isActionLoading = false;
  bool live = false;
  int respondedDrivers = 0;
  String errorMessage = '';

  List<Map<String, dynamic>> offers = [];

  String get timerText {
    final min = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final sec = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void startCountdown() {
    timer?.cancel();
    secondsLeft = 24;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
      } else {
        secondsLeft--;
        notifyListeners();
      }
    });
  }

  Future<Map<String, dynamic>> broadcastRide({
    required String rideId,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await RideApiService.broadcastRide(rideId: rideId);

    if (result['success'] == true) {
      setRideData(result['data']);
    } else {
      isLoading = false;
      errorMessage = result['message'] ?? 'Ride broadcast failed';
      notifyListeners();
    }

    return result;
  }

  void setRideData(Map<String, dynamic> data) {
    final ride = data['ride'];
    final rawOffers = ride?['driverOffers'];

    live = data['live'] == true;

    offers = rawOffers is List
        ? rawOffers.map((e) => Map<String, dynamic>.from(e)).toList()
        : [];

    respondedDrivers = data['respondedDrivers'] is num
        ? data['respondedDrivers']
        : offers.length;

    isLoading = false;
    errorMessage = '';
    notifyListeners();
  }

  Future<Map<String, dynamic>> acceptOffer({
    required String rideId,
    required String offerId,
  }) async {
    isActionLoading = true;
    notifyListeners();

    final result = await RideApiService.acceptOffer(
      rideId: rideId,
      offerId: offerId,
    );

    isActionLoading = false;

    if (result['success'] == true) {
      setRideData(result['data']);
    } else {
      notifyListeners();
    }

    return result;
  }

  Future<Map<String, dynamic>> declineOffer({
    required String rideId,
    required String offerId,
  }) async {
    isActionLoading = true;
    notifyListeners();

    final result = await RideApiService.declineOffer(
      rideId: rideId,
      offerId: offerId,
    );

    isActionLoading = false;

    if (result['success'] == true) {
      setRideData(result['data']);
    } else {
      notifyListeners();
    }

    return result;
  }

  Future<Map<String, dynamic>> counterOffer({
    required String rideId,
    required String offerId,
    required int counterAmount,
  }) async {
    isActionLoading = true;
    notifyListeners();

    final result = await RideApiService.counterOffer(
      rideId: rideId,
      offerId: offerId,
      counterAmount: counterAmount,
    );

    isActionLoading = false;

    if (result['success'] == true) {
      setRideData(result['data']);
    } else {
      notifyListeners();
    }

    return result;
  }

  void clear() {
    timer?.cancel();
    secondsLeft = 24;
    isLoading = true;
    isActionLoading = false;
    live = false;
    respondedDrivers = 0;
    errorMessage = '';
    offers = [];
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}