import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hire_driver/service/applyasrider.dart';

class ApplyAsRiderProvider extends ChangeNotifier {
  int currentStep = 0;
  bool isLoading = false;
  bool alreadySubmitted = false;

  String? fullNameError;
  String? cnicError;
  String? dobError;
  String? addressError;
  String? vehicleError;
  String? plateError;
  String? serviceError;
  String? consentError;

  XFile? cnicFrontFile;
  XFile? cnicBackFile;
  XFile? licenseFrontFile;
  XFile? licenseBackFile;

  bool hireDriverService = true;
  bool bookRideService = false;
  bool consentAccepted = false;

  Future<void> loadMyApplication({
    required TextEditingController fullNameController,
    required TextEditingController cnicController,
    required TextEditingController dobController,
    required TextEditingController addressController,
    required TextEditingController vehicleController,
    required TextEditingController plateController,
  }) async {
    try {
      final res = await DriverApplicationApiService.getMyApplication();

      if (res['success'] == true && res['application'] != null) {
        final application = res['application'];
        final progress = application['progress'];

        final bool isSubmitted =
            application['status'] == 'pending_admin' ||
            application['status'] == 'submitted' ||
            application['status'] == 'approved' ||
            application['status'] == 'rejected' ||
            progress?['submittedAt'] != null;

        if (isSubmitted) {
          alreadySubmitted = true;
          currentStep = 4;
          notifyListeners();
          return;
        }

        if (progress != null) {
          if (progress['personalInfoCompleted'] == true) currentStep = 1;
          if (progress['documentsCompleted'] == true) currentStep = 2;
          if (progress['vehicleInfoCompleted'] == true) currentStep = 3;
        }

        final personalInfo = application['personalInfo'];
        final vehicleInfo = application['vehicleInfo'];

        if (personalInfo != null) {
          fullNameController.text = personalInfo['fullName'] ?? '';
          cnicController.text = personalInfo['cnicNumber'] ?? '';
          addressController.text = personalInfo['homeAddress'] ?? '';

          final dob = personalInfo['dateOfBirth'];
          if (dob != null && dob.toString().isNotEmpty) {
            dobController.text = dob.toString().split('T').first;
          }
        }

        if (vehicleInfo != null) {
          vehicleController.text = vehicleInfo['vehicleMakeModel'] ?? '';
          plateController.text = vehicleInfo['plateNumber'] ?? '';

          final services = vehicleInfo['services'] ?? [];
          hireDriverService = services.contains('hire_driver');
          bookRideService = services.contains('book_ride');
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Get my application error: $e');
    }
  }

  void pickDocument(String type, XFile picked) {
    if (type == 'cnicFront') cnicFrontFile = picked;
    if (type == 'cnicBack') cnicBackFile = picked;
    if (type == 'licenseFront') licenseFrontFile = picked;
    if (type == 'licenseBack') licenseBackFile = picked;
    notifyListeners();
  }

  void setDob(String value, TextEditingController dobController) {
    dobController.text = value;
    dobError = null;
    notifyListeners();
  }

  void toggleHireDriverService() {
    hireDriverService = !hireDriverService;
    serviceError = null;
    notifyListeners();
  }

  void toggleBookRideService() {
    bookRideService = !bookRideService;
    serviceError = null;
    notifyListeners();
  }

  void toggleConsent() {
    consentAccepted = !consentAccepted;
    consentError = null;
    notifyListeners();
  }

  Future<String?> nextStep({
    required TextEditingController fullNameController,
    required TextEditingController cnicController,
    required TextEditingController dobController,
    required TextEditingController addressController,
    required TextEditingController vehicleController,
    required TextEditingController plateController,
  }) async {
    try {
      if (currentStep == 0) {
        fullNameError = null;
        cnicError = null;
        dobError = null;
        addressError = null;

        bool hasError = false;

        if (fullNameController.text.trim().isEmpty) {
          fullNameError = 'Enter full name';
          hasError = true;
        } else if (fullNameController.text.trim().length < 3) {
          fullNameError = 'Enter valid full name';
          hasError = true;
        }

        if (cnicController.text.trim().isEmpty) {
          cnicError = 'Enter CNIC number';
          hasError = true;
        } else if (cnicController.text.trim().length != 13) {
          cnicError = 'CNIC must be 13 digits';
          hasError = true;
        }

        if (dobController.text.trim().isEmpty) {
          dobError = 'Select date of birth';
          hasError = true;
        }

        if (addressController.text.trim().isEmpty) {
          addressError = 'Enter home address';
          hasError = true;
        }

        if (hasError) {
          notifyListeners();
          return null;
        }

        isLoading = true;
        notifyListeners();

        final res = await DriverApplicationApiService.savePersonalInfo(
          fullName: fullNameController.text.trim(),
          cnicNumber: cnicController.text.trim(),
          dateOfBirth: dobController.text.trim(),
          homeAddress: addressController.text.trim(),
        );

        isLoading = false;
        notifyListeners();

        if (res['success'] != true) {
          return res['message'] ?? 'Personal info failed';
        }
      }

      if (currentStep == 1) {
        if (cnicFrontFile == null ||
            cnicBackFile == null ||
            licenseFrontFile == null ||
            licenseBackFile == null) {
          return 'Please upload all required documents';
        }

        isLoading = true;
        notifyListeners();

        final res = await DriverApplicationApiService.uploadDocuments(
          cnicFront: cnicFrontFile!,
          cnicBack: cnicBackFile!,
          licenseFront: licenseFrontFile!,
          licenseBack: licenseBackFile!,
        );

        isLoading = false;
        notifyListeners();

        if (res['success'] != true) {
          return res['message'] ?? 'Documents upload failed';
        }
      }

      if (currentStep == 2) {
        vehicleError = null;
        plateError = null;
        serviceError = null;

        bool hasError = false;

        if (vehicleController.text.trim().isEmpty) {
          vehicleError = 'Enter vehicle info';
          hasError = true;
        }

        if (plateController.text.trim().isEmpty) {
          plateError = 'Enter plate number';
          hasError = true;
        } else if (!RegExp(r'^[A-Z]{3}-\d{4}$')
            .hasMatch(plateController.text.trim())) {
          plateError = 'Use format LEA-1234';
          hasError = true;
        }

        final services = <String>[];
        if (hireDriverService) services.add('hire_driver');
        if (bookRideService) services.add('book_ride');

        if (services.isEmpty) {
          serviceError = 'Select at least one service';
          hasError = true;
        }

        if (hasError) {
          notifyListeners();
          return null;
        }

        isLoading = true;
        notifyListeners();

        final res = await DriverApplicationApiService.saveVehicleInfo(
          vehicleMakeModel: vehicleController.text.trim(),
          plateNumber: plateController.text.trim(),
          services: services,
        );

        isLoading = false;
        notifyListeners();

        if (res['success'] != true) {
          return res['message'] ?? 'Vehicle info failed';
        }
      }

      if (currentStep == 3) {
        if (!consentAccepted) {
          consentError = 'Please accept terms';
          notifyListeners();
          return null;
        }

        isLoading = true;
        notifyListeners();

        final res = await DriverApplicationApiService.submitApplication();

        isLoading = false;
        notifyListeners();

        if (res['success'] != true) {
          return res['message'] ?? 'Submit failed';
        }

        alreadySubmitted = true;
        currentStep = 4;
        notifyListeners();
        return null;
      }

      currentStep++;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
}