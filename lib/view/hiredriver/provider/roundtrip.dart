import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

class RoundTripProvider extends ChangeNotifier {
  bool isSubmitting = false;

  Future<Map<String, dynamic>> createHireRequest({
    required String serviceType,
    required String pickupAddress,
    required String dropoffAddress,
    required String scheduledDate,
    required String scheduledTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      await HireDriverApiService.previewHireDriver(
        serviceType: serviceType,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: vehicleModel,
        vehicleColor: vehicleColor,
        plateNumber: plateNumber,
      );

      final createData = await HireDriverApiService.createHireDriverRequest(
        serviceType: serviceType,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: vehicleModel,
        vehicleColor: vehicleColor,
        plateNumber: plateNumber,
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