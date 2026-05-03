import 'dart:async';
import 'package:flutter/material.dart';

class DriverComingProvider extends ChangeNotifier {
  double driverProgress = 0.0;
  Timer? _timer;

  void startDriverComing() {
    const totalSeconds = 90;

    _timer?.cancel();
    driverProgress = 0.0;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (driverProgress >= 1.0) {
        timer.cancel();
        return;
      }

      driverProgress += 1 / totalSeconds;

      if (driverProgress > 1.0) {
        driverProgress = 1.0;
      }

      notifyListeners();
    });
  }

  void cancelRide(String reason) {
    debugPrint("Ride cancelled: $reason");
  }

  void clear() {
    _timer?.cancel();
    driverProgress = 0.0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}