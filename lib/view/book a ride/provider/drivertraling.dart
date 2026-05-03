import 'dart:async';
import 'package:flutter/material.dart';

class OngoingRideProvider extends ChangeNotifier {
  double rideProgress = 0.0;
  Timer? _timer;

  void startRideProgress() {
    const totalSeconds = 180;

    _timer?.cancel();
    rideProgress = 0.0;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (rideProgress >= 1.0) {
        timer.cancel();
        return;
      }

      rideProgress += 1 / totalSeconds;

      if (rideProgress > 1.0) {
        rideProgress = 1.0;
      }

      notifyListeners();
    });
  }

  void clear() {
    _timer?.cancel();
    rideProgress = 0.0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}