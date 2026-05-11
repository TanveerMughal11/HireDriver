import 'package:flutter/material.dart';
import 'package:hire_driver/view/profile/services/profile.dart';

class ProfileDriverStatusProvider extends ChangeNotifier {
  bool isLoading = false;

  String riderStatus = 'none';
  String driverStatus = 'none';

  Future<void> loadDriverApplicationStatus() async {
    try {
      isLoading = true;
      notifyListeners();

      final riderRes = await ProfileService.getMyRiderApplication();

      if (riderRes['success'] == true && riderRes['alreadyApplied'] == true) {
        riderStatus = riderRes['applicationStatus']?.toString() ?? 'none';
      } else {
        riderStatus = 'none';
      }

      final driverRes = await ProfileService.getMyDriverVerification();

      if (driverRes['success'] == true && driverRes['alreadyApplied'] == true) {
        driverStatus = driverRes['applicationStatus']?.toString() ?? 'none';
      } else {
        driverStatus = 'none';
      }
    } catch (e) {
      debugPrint('Profile status error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}