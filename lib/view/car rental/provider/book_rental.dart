import 'package:flutter/material.dart';
import 'package:hire_driver/view/car%20rental/services/carlisting.dart';

class BookRentalProvider extends ChangeNotifier {
  DateTime? pickupDate;
  DateTime? returnDate;

  bool isBooking = false;
  bool isPreviewLoading = false;

  String previewError = '';
  Map<String, dynamic>? previewData;

  int selectedDuration = 3;
  bool selfPickup = true;
  bool addInsurance = false;

  final TextEditingController couponController = TextEditingController();

  final int pricePerDay = 3500;
  final int deliveryCharges = 300;
  final int insurancePerDay = 500;

  String formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int get basePrice => pricePerDay * selectedDuration;

  int get pickupCharges => selfPickup ? 0 : deliveryCharges;

  int get insuranceCharges =>
      addInsurance ? insurancePerDay * selectedDuration : 0;

  int get totalPrice => basePrice + pickupCharges + insuranceCharges;

  int get shownBasePrice => previewData?['basePrice'] ?? basePrice;

  int get shownTotalPrice => previewData?['totalPrice'] ?? totalPrice;

  void updatePickupDate(DateTime date) {
    pickupDate = date;

    if (returnDate != null && returnDate!.isBefore(date)) {
      returnDate = null;
    }

    notifyListeners();
  }

  void updateReturnDate(DateTime date) {
    returnDate = date;
    notifyListeners();
  }

  void updateDuration(int value) {
    selectedDuration = value;
    notifyListeners();
  }

  void updateSelfPickup(bool value) {
    selfPickup = value;
    notifyListeners();
  }

  void updateInsurance(bool value) {
    addInsurance = value;
    notifyListeners();
  }

  Future<void> loadBookingPreview(String listingId) async {
    if (pickupDate == null || returnDate == null) return;

    isPreviewLoading = true;
    previewError = '';
    notifyListeners();

    try {
      final result = await CarRentalApiService.previewBooking(
        listingId: listingId,
        pickupDate: formatApiDate(pickupDate!),
        returnDate: formatApiDate(returnDate!),
      );

      previewData = result;
      isPreviewLoading = false;
      notifyListeners();
    } catch (e) {
      previewError = e.toString();
      isPreviewLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> requestRental(String listingId) async {
    if (pickupDate == null || returnDate == null) {
      throw Exception('Please select pickup and return dates');
    }

    isBooking = true;
    notifyListeners();

    try {
      final result = await CarRentalApiService.bookRental(
        listingId: listingId,
        pickupDate: formatApiDate(pickupDate!),
        returnDate: formatApiDate(returnDate!),
        selfPickup: selfPickup,
        addInsurance: addInsurance,
        couponCode: couponController.text,
      );

      isBooking = false;
      notifyListeners();

      return result;
    } catch (e) {
      isBooking = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}