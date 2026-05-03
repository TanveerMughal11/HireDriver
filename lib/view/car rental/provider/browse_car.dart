import 'package:flutter/material.dart';
import 'package:hire_driver/view/car%20rental/services/carlisting.dart';

class BrowseCarsProvider extends ChangeNotifier {
  String selectedCarType = 'All';
  String selectedCity = 'Lahore';
  String selectedPrice = 'Any Price';
  String selectedSeats = '5 Seats';
  String selectedSort = 'Recommended';

  DateTime? pickupDate;
  DateTime? returnDate;

  final TextEditingController searchController = TextEditingController();

  final List<String> carTypes = ['All', 'Sedan', 'SUV', 'Van'];

  List<Map<String, dynamic>> cars = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchCars() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final result = await CarRentalApiService.browseCars(
        search: searchController.text.trim(),
        carType: selectedCarType == 'All' ? '' : selectedCarType,
        location: selectedCity,
        seats: _extractSeats(selectedSeats),
        minPrice: _getMinPrice(selectedPrice),
        maxPrice: _getMaxPrice(selectedPrice),
        sort: _mapSortValue(selectedSort),
      );

      cars = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void updateCity(String value) {
    selectedCity = value;
    notifyListeners();
  }

  void updateSeats(String value) {
    selectedSeats = value;
    notifyListeners();
  }

  void updatePrice(String value) {
    selectedPrice = value;
    notifyListeners();
  }

  void updateType(String value) {
    selectedCarType = value;
    notifyListeners();
  }

  void updateSort(String value) {
    selectedSort = value;
    notifyListeners();
  }

  void updatePickupDate(DateTime date) {
    pickupDate = date;
    notifyListeners();
  }

  void updateReturnDate(DateTime date) {
    returnDate = date;
    notifyListeners();
  }

  int _extractSeats(String seatsText) {
    if (seatsText.contains('10')) return 10;
    if (seatsText.contains('2')) return 2;
    if (seatsText.contains('4')) return 4;
    if (seatsText.contains('5')) return 5;
    if (seatsText.contains('7')) return 7;
    return 0;
  }

  int _getMinPrice(String price) {
    switch (price) {
      case 'Under 4,000':
        return 0;
      case '4,000 - 6,000':
        return 4000;
      case 'Above 6,000':
        return 6000;
      default:
        return 0;
    }
  }

  int _getMaxPrice(String price) {
    switch (price) {
      case 'Under 4,000':
        return 4000;
      case '4,000 - 6,000':
        return 6000;
      case 'Above 6,000':
        return 0;
      default:
        return 0;
    }
  }

  String _mapSortValue(String sort) {
    switch (sort) {
      case 'Price Low to High':
        return 'price_asc';
      case 'Price High to Low':
        return 'price_desc';
      case 'Top Rated':
        return 'rating';
      case 'Newest Model':
        return 'newest';
      default:
        return 'newest';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}