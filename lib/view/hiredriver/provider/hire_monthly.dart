import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

class MonthlyHireProvider extends ChangeNotifier {
  bool isSubmitting = false;

  Future<Map<String, dynamic>> createHireRequest({
    required String serviceType,
    required String pickupAddress,
    required String dropoffAddress,
    required String scheduledDate,
    required String scheduledTime,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      await HireDriverApiService.previewHireDriver(
        serviceType: serviceType,
        pickupAddress: pickupAddress,
        dropoffAddress: pickupAddress,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: 'Monthly Hire',
        vehicleColor: 'N/A',
        plateNumber: 'MONTHLY',
      );

      final createData = await HireDriverApiService.createHireDriverRequest(
        serviceType: serviceType,
        pickupAddress: pickupAddress,
        dropoffAddress: pickupAddress,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: 'Monthly Hire',
        vehicleColor: 'N/A',
        plateNumber: 'MONTHLY',
      );

      return {
        'success': true,
        'hireRequestId': createData['hireRequest']['id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}