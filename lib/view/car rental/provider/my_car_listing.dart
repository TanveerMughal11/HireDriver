import 'package:flutter/material.dart';
import 'package:hire_driver/view/forms/services/carlistingform.dart';

class MyCarListingsProvider extends ChangeNotifier {
  bool isLoading = true;
  List listings = [];
  String errorMessage = '';

  Future<void> loadListings() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final res = await RentalApiService.getMyListings();

    if (res['success'] == true) {
      listings = res['listings'] ?? [];
      isLoading = false;
      notifyListeners();
    } else {
      errorMessage = res['message'] ?? 'Failed to load listings';
      isLoading = false;
      notifyListeners();
    }
  }
}