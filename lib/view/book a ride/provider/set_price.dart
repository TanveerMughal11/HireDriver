import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';

class SetPriceProvider extends ChangeNotifier {
  bool promoApplied = false;
  bool isCreatingRide = false;
  String promoMessage = '';

  int selectedFare = 350;
  int minFare = 280;
  int maxFare = 480;

  void initFare(Map<String, dynamic> selectedVehicleOption) {
    minFare = (selectedVehicleOption['minFare'] as num?)?.toInt() ?? 280;
    selectedFare =
        (selectedVehicleOption['suggestedFare'] as num?)?.toInt() ?? 350;
    maxFare = (selectedVehicleOption['maxFare'] as num?)?.toInt() ?? 480;

    notifyListeners();
  }

  int get finalFare {
    if (promoApplied) {
      return (selectedFare * 0.75).round();
    }
    return selectedFare;
  }

  double get rangeValue {
    if (maxFare == minFare) return 0;
    final value = (selectedFare - minFare) / (maxFare - minFare);
    return value.clamp(0.0, 1.0);
  }

  void selectFare(int fare) {
    selectedFare = fare;
    notifyListeners();
  }

  Future<String> loadAppliedPromo() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCode = prefs.getString('book_ride_promo_code') ?? '';
    final alreadyApplied = prefs.getBool('book_ride_promo_applied') ?? false;

    promoApplied = alreadyApplied;
    promoMessage = alreadyApplied ? '25% discount applied permanently' : '';

    notifyListeners();
    return savedCode;
  }

  Future<void> applyPromoCode(String codeValue) async {
    final code = codeValue.trim().toUpperCase();

    if (code != 'RIDE25') {
      promoApplied = false;
      promoMessage = 'Invalid promo code';
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('book_ride_promo_applied', true);
    await prefs.setString('book_ride_promo_code', code);

    promoApplied = true;
    promoMessage = '25% discount applied permanently';

    notifyListeners();
  }

  Future<Map<String, dynamic>> createRide({
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    required String tripType,
    required String vehicleType,
    required double distanceKm,
    required int durationMinutes,
  }) async {
    if (isCreatingRide) {
      return {
        'success': false,
        'message': 'Already creating ride',
      };
    }

    isCreatingRide = true;
    notifyListeners();

    final result = await RideApiService.createRide(
      pickup: pickup,
      dropoff: dropoff,
      tripType: tripType,
      vehicleType: vehicleType,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      offeredFare: finalFare,
    );

    isCreatingRide = false;
    notifyListeners();

    return result;
  }
}