import 'package:flutter/material.dart';
import 'package:hire_driver/view/forms/services/carlistingform.dart';
import 'package:image_picker/image_picker.dart';

class ListMyCarProvider extends ChangeNotifier {
  int currentStep = 0;

  String? listingId;
  String? insurancePath;
  String? registrationPath;

  final carMakeController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final plateController = TextEditingController();
  final locationController = TextEditingController();
  final seatingController = TextEditingController();

  final dailyRateController = TextEditingController();
  final minimumRentalDaysController = TextEditingController();

  final picker = ImagePicker();

  final List<String> photoLabels = [
    'Front',
    'Back',
    'Interior',
    'Side View',
  ];

  List<XFile?> photos = [null, null, null, null];

  final List<Map<String, dynamic>> availability = [
    {'day': 'Mon', 'selected': true},
    {'day': 'Tue', 'selected': true},
    {'day': 'Wed', 'selected': true},
    {'day': 'Thu', 'selected': true},
    {'day': 'Fri', 'selected': true},
    {'day': 'Sat', 'selected': false},
    {'day': 'Sun', 'selected': false},
  ];

  bool insuranceUploaded = false;
  bool registrationUploaded = false;

  int get dailyRate => int.tryParse(dailyRateController.text) ?? 0;
  int get monthlyEstimate => dailyRate * 18;
  int get platformFee => (monthlyEstimate * 0.12).round();

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
    }
  }

  void toggleDay(int index) {
    availability[index]['selected'] = !availability[index]['selected'];
    notifyListeners();
  }

  Future<void> pickPhoto(int index) async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      photos[index] = image;
      notifyListeners();
    }
  }

  Future<void> pickInsurance() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      insurancePath = file.path;
      insuranceUploaded = true;
      notifyListeners();
    }
  }

  Future<void> pickRegistration() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      registrationPath = file.path;
      registrationUploaded = true;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> handleCarSubmit() async {
    final res = await RentalApiService.createCar(
      make: carMakeController.text.trim(),
      model: modelController.text.trim(),
      year: yearController.text.trim(),
      color: colorController.text.trim(),
      plate: plateController.text.trim(),
      seating: seatingController.text.trim(),
      location: locationController.text.trim(),
    );

    if (res['success'] == true) {
      listingId = res['listing']['id'] ?? res['listing']['_id'];
      nextStep();
    }

    return res;
  }

  Future<Map<String, dynamic>> handlePhotoUpload() async {
    if (listingId == null || listingId!.isEmpty) {
      return {
        'success': false,
        'message': 'Listing ID missing',
      };
    }

    if (photos.any((photo) => photo == null)) {
      return {
        'success': false,
        'message': 'Please upload all 4 photos',
      };
    }

    final res = await RentalApiService.uploadPhotos(
      listingId: listingId!,
      front: photos[0]!,
      back: photos[1]!,
      interior: photos[2]!,
      sideView: photos[3]!,
    );

    debugPrint('PHOTO UPLOAD RESPONSE: $res');

    if (res['success'] == true) {
      nextStep();
    }

    return res;
  }

  Future<Map<String, dynamic>> handlePricingSubmit() async {
    if (listingId == null || listingId!.isEmpty) {
      return {
        'success': false,
        'message': 'Listing ID missing',
      };
    }

    final dailyRate = int.tryParse(dailyRateController.text.trim());
    final minDays = int.tryParse(minimumRentalDaysController.text.trim());

    if (dailyRate == null || dailyRate <= 0) {
      return {
        'success': false,
        'message': 'Enter valid daily rate',
      };
    }

    if (minDays == null || minDays <= 0) {
      return {
        'success': false,
        'message': 'Enter valid minimum days',
      };
    }

    if (insurancePath == null) {
      return {
        'success': false,
        'message': 'Upload insurance document',
      };
    }

    if (registrationPath == null) {
      return {
        'success': false,
        'message': 'Upload registration document',
      };
    }

    final selectedDays = availability
        .where((day) => day['selected'] == true)
        .map((day) => day['day'].toString())
        .toList();

    final res = await RentalApiService.setPricing(
      listingId: listingId!,
      dailyRate: dailyRate,
      minDays: minDays,
      days: selectedDays,
      insuranceDocument: "https://example.com/insurance.pdf",
      vehicleRegistration: "https://example.com/registration.pdf",
    );

    debugPrint("PRICING RESPONSE: $res");

    if (res['success'] == true) {
      final submitRes = await RentalApiService.submitListing(listingId!);

      if (submitRes['success'] == true) {
        nextStep();
      }

      return submitRes;
    }

    return res;
  }

  @override
  void dispose() {
    carMakeController.dispose();
    modelController.dispose();
    yearController.dispose();
    colorController.dispose();
    plateController.dispose();
    locationController.dispose();
    seatingController.dispose();
    dailyRateController.dispose();
    minimumRentalDaysController.dispose();
    super.dispose();
  }
}