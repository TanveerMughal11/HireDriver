import 'package:flutter/material.dart';
import 'package:hire_driver/view/car%20rental/services/carlisting.dart';

class CarDetailsProvider extends ChangeNotifier {
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic> car = {};

  int currentImage = 0;

  Future<void> fetchCarDetails(String listingId) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final result = await CarRentalApiService.getCarDetails(listingId);

      car = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void updateCurrentImage(int index) {
    currentImage = index;
    notifyListeners();
  }

  List<String> get carImages {
    final photos = car['photos'];
    if (photos is Map<String, dynamic>) {
      final images = [
        photos['front'],
        photos['back'],
        photos['interior'],
        photos['sideView'],
      ]
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString())
          .toList();

      if (images.isNotEmpty) return images;
    }

    return ['https://via.placeholder.com/640x360'];
  }

  Map<String, dynamic> get carInfo =>
      (car['carInfo'] as Map<String, dynamic>?) ?? {};

  Map<String, dynamic> get pricing =>
      (car['pricing'] as Map<String, dynamic>?) ?? {};

  Map<String, dynamic> get rating =>
      (car['rating'] as Map<String, dynamic>?) ?? {};

  Map<String, dynamic> get owner =>
      (car['owner'] as Map<String, dynamic>?) ?? {};

  bool get isAvailable =>
      car['isPublished'] == true && car['approvalStatus'] == 'approved';

  String get ownerName {
    final name = owner['name']?.toString() ?? '';
    return name.isEmpty ? 'Host' : name;
  }

  String get ownerInitial {
    if (ownerName.isNotEmpty) {
      return ownerName[0].toUpperCase();
    }
    return 'H';
  }

  String get carName =>
      '${carInfo['make'] ?? ''} ${carInfo['model'] ?? ''}'.trim().isEmpty
          ? 'Car Details'
          : '${carInfo['make'] ?? ''} ${carInfo['model'] ?? ''}'.trim();

  String get pricePerDay => '${pricing['dailyRate'] ?? 0}';

  String get subtitle =>
      '${carInfo['year'] ?? 'N/A'} · ${carInfo['color'] ?? 'N/A'} · ${carInfo['carType'] ?? 'N/A'}';

  String get ratingText => (rating['avg'] ?? 0).toString();

  String get ratingCountText => '(${rating['count'] ?? 0} reviews)';

  List<Map<String, dynamic>> get specs => [
        {
          'icon': Icons.event_seat_rounded,
          'label': 'Seats',
          'value': '${carInfo['seatingCapacity'] ?? 'N/A'} Seats',
        },
        {
          'icon': Icons.local_gas_station_rounded,
          'label': 'Fuel',
          'value': '${carInfo['fuelType'] ?? 'N/A'}',
        },
        {
          'icon': Icons.settings_rounded,
          'label': 'Transmission',
          'value': '${carInfo['transmission'] ?? 'N/A'}',
        },
        {
          'icon': Icons.shield_outlined,
          'label': 'Insurance',
          'value': (carInfo['isInsured'] == true) ? 'Insured' : 'Not insured',
        },
        {
          'icon': Icons.place_outlined,
          'label': 'Location',
          'value': '${carInfo['locationArea'] ?? 'N/A'}',
        },
        {
          'icon': Icons.build_rounded,
          'label': 'Plate',
          'value': '${carInfo['plateNumber'] ?? 'N/A'}',
        },
      ];

  List<String> get availableDays {
    final days = pricing['availableDays'];
    if (days is List) {
      return days.map((e) => e.toString()).toList();
    }
    return [];
  }
}