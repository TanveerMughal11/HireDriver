import 'dart:async';
import 'package:flutter/material.dart';

class AwaitingDriverProvider extends ChangeNotifier {
  Timer? _countdownTimer;
  int remainingSeconds = 60;
  bool isTimeFinished = false;

  void startCountdown(int seconds) {
    _countdownTimer?.cancel();

    remainingSeconds = seconds;
    isTimeFinished = false;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        isTimeFinished = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void cancelTimer() {
    _countdownTimer?.cancel();
  }

  void syncRemainingSeconds(int seconds) {
    final normalized = seconds < 0 ? 0 : seconds;
    remainingSeconds = normalized;
    isTimeFinished = normalized == 0;
    notifyListeners();
  }

  String formatTimer() {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
