import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

class ConfirmBookingProvider extends ChangeNotifier {
  bool isConfirming = false;

  Future<Map<String, dynamic>> confirmBooking({
    required String hireRequestId,
    required String paymentMethod,
    required String promoCode,
  }) async {
    try {
      isConfirming = true;
      notifyListeners();

      final data = await HireDriverApiService.confirmHireDriver(
        hireRequestId: hireRequestId,
        paymentMethod: paymentMethod,
        promoCode: promoCode,
      );

      return {
        'success': true,
        'waitingState': data['waitingState'] ?? {},
        'hireRequest': data['hireRequest'] ?? {},
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    } finally {
      isConfirming = false;
      notifyListeners();
    }
  }
}