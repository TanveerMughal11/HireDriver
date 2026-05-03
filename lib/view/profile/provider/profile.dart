import 'package:flutter/material.dart';
import 'package:hire_driver/view/profile/services/profile.dart';


class ProfileDriverStatusProvider extends ChangeNotifier {
  bool isLoading = false;
  String driverStatus = 'none';

  Future<void> loadDriverApplicationStatus() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await ProfileService.getMyApplication();

      if (res['success'] == true && res['application'] != null) {
        final application = res['application'];

        driverStatus = application['status'] ?? 'none';
      } else {
        driverStatus = 'none';
      }
    } catch (e) {
      debugPrint('Driver status error: $e');
      driverStatus = 'none';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}