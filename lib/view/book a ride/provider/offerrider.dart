import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';

class DriverOffersProvider extends ChangeNotifier {
  int secondsLeft = 24;
  Timer? timer;
  Timer? _rideStatusPollTimer;

  bool isLoading = true;
  bool isActionLoading = false;
  bool live = false;
  int respondedDrivers = 0;
  String errorMessage = '';
  bool riderAccepted = false;
  String riderAcceptedMessage = '';
  String passengerDecisionType = '';
  String passengerDecisionMessage = '';

  String pickupAddress = 'Current Location';
  double? pickupLat;
  double? pickupLng;

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

  Future<Map<String, dynamic>> broadcastRide({required String rideId}) async {
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

  Future<void> refreshRideStatus({required String rideId}) async {
    final result = await RideApiService.getRideRequest(rideId: rideId);

    if (result['success'] != true) {
      return;
    }

    final data = result['data'];
    if (data is! Map<String, dynamic>) {
      return;
    }

    final ride = data['ride'];
    if (ride is! Map<String, dynamic>) {
      return;
    }

    setRideData({
      'ride': ride,
      'live': true,
      'respondedDrivers': (ride['driverOffers'] as List?)?.length ?? 0,
    });

    final passengerUpdate = ride['passengerUpdate'];
    if (passengerUpdate is Map<String, dynamic> &&
        passengerUpdate['accepted'] == true) {
      passengerDecisionType = 'accepted';
      riderAccepted = true;
      riderAcceptedMessage =
          passengerUpdate['message']?.toString() ??
          'Rider accepted your ride and is coming.';
      notifyListeners();
      stopRideStatusPolling();
      return;
    }

    if (passengerUpdate is Map<String, dynamic> &&
        passengerUpdate['decision']?.toString() == 'declined') {
      passengerDecisionType = 'declined';
      passengerDecisionMessage =
          passengerUpdate['message']?.toString() ??
          'A rider declined your request. Looking for another rider...';
      notifyListeners();
    }
  }

  void startRideStatusPolling({required String rideId}) {
    _rideStatusPollTimer?.cancel();
    _rideStatusPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      refreshRideStatus(rideId: rideId);
    });
  }

  void stopRideStatusPolling() {
    _rideStatusPollTimer?.cancel();
    _rideStatusPollTimer = null;
  }

  void setRideData(Map<String, dynamic> data) {
    final ride = data['ride'];
    final rawOffers = ride?['driverOffers'];

    final pickup = ride?['pickup'];

    if (pickup is Map) {
      pickupAddress = pickup['address']?.toString() ?? 'Current Location';

      final coordinates = pickup['coordinates'];
      if (coordinates is Map) {
        final lat = coordinates['lat'];
        final lng = coordinates['lng'];

        if (lat is num) pickupLat = lat.toDouble();
        if (lng is num) pickupLng = lng.toDouble();
      }
    }

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
    stopRideStatusPolling();
    secondsLeft = 24;
    isLoading = true;
    isActionLoading = false;
    live = false;
    respondedDrivers = 0;
    errorMessage = '';
    riderAccepted = false;
    riderAcceptedMessage = '';
    passengerDecisionType = '';
    passengerDecisionMessage = '';
    pickupAddress = 'Current Location';
    pickupLat = null;
    pickupLng = null;
    offers = [];
  }

  @override
  void dispose() {
    timer?.cancel();
    stopRideStatusPolling();
    super.dispose();
  }
}
