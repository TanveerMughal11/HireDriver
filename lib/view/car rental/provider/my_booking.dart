import 'package:flutter/material.dart';
import 'package:hire_driver/view/car%20rental/services/carbookinghistory.dart';

class MyBookingsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchBookings() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final result = await CarbookinghistoryApi.getMyBookings();

      bookings = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }
}