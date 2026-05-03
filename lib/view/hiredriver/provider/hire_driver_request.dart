import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

class HireRequestProvider extends ChangeNotifier {
  bool isSubmitting = false;

  String _formatApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatApiTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> createOneWayRequest({
    required Map<String, dynamic> serviceOption,
    required String pickupAddress,
    required String dropoffAddress,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    if (selectedDate == null || selectedTime == null) {
      return {
        'success': false,
        'message': 'Please select date and time',
      };
    }

    if (pickupAddress.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter pickup location',
      };
    }

    if (dropoffAddress.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter drop-off location',
      };
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final scheduledDate = _formatApiDate(selectedDate);
      final scheduledTime = _formatApiTime(selectedTime);

      await HireDriverApiService.previewHireDriver(
        serviceType: serviceOption['id'],
        pickupAddress: pickupAddress.trim(),
        dropoffAddress: dropoffAddress.trim(),
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: vehicleModel.trim(),
        vehicleColor: vehicleColor.trim(),
        plateNumber: plateNumber.trim(),
      );

      final createData = await HireDriverApiService.createHireDriverRequest(
        serviceType: serviceOption['id'],
        pickupAddress: pickupAddress.trim(),
        dropoffAddress: dropoffAddress.trim(),
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: vehicleModel.trim(),
        vehicleColor: vehicleColor.trim(),
        plateNumber: plateNumber.trim(),
      );

      final hireRequestId = createData['hireRequest']?['id']?.toString();

      if (hireRequestId == null || hireRequestId.isEmpty) {
        return {
          'success': false,
          'message': 'Hire request ID not found',
        };
      }

      return {
        'success': true,
        'hireRequestId': hireRequestId,
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

  Future<Map<String, dynamic>> createRoundTripRequest({
    required Map<String, dynamic> serviceOption,
    required String pickupAddress,
    required String dropoffAddress,
    required DateTime? departureDate,
    required TimeOfDay? departureTime,
    required DateTime? returnDate,
    required TimeOfDay? returnTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    if (departureDate == null || departureTime == null) {
      return {
        'success': false,
        'message': 'Please select departure date and time',
      };
    }

    if (returnDate == null || returnTime == null) {
      return {
        'success': false,
        'message': 'Please select return date and time',
      };
    }

    if (pickupAddress.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter pickup location',
      };
    }

    if (dropoffAddress.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter drop-off location',
      };
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final scheduledDate = _formatApiDate(departureDate);
      final scheduledTime = _formatApiTime(departureTime);

      await HireDriverApiService.previewHireDriver(
        serviceType: serviceOption['id'],
        pickupAddress: pickupAddress.trim(),
        dropoffAddress: dropoffAddress.trim(),
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: vehicleModel.trim(),
        vehicleColor: vehicleColor.trim(),
        plateNumber: plateNumber.trim(),
      );

      final createData = await HireDriverApiService.createHireDriverRequest(
        serviceType: serviceOption['id'],
        pickupAddress: pickupAddress.trim(),
        dropoffAddress: dropoffAddress.trim(),
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: vehicleModel.trim(),
        vehicleColor: vehicleColor.trim(),
        plateNumber: plateNumber.trim(),
      );

      final hireRequestId = createData['hireRequest']?['id']?.toString();

      if (hireRequestId == null || hireRequestId.isEmpty) {
        return {
          'success': false,
          'message': 'Hire request ID not found',
        };
      }

      return {
        'success': true,
        'hireRequestId': hireRequestId,
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

  Future<Map<String, dynamic>> createMonthlyRequest({
    required Map<String, dynamic> serviceOption,
    required String pickupArea,
    required DateTime? startDate,
  }) async {
    if (startDate == null) {
      return {
        'success': false,
        'message': 'Please select start date',
      };
    }

    if (pickupArea.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter pickup area',
      };
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final scheduledDate = _formatApiDate(startDate);
      const scheduledTime = '09:00';

      await HireDriverApiService.previewHireDriver(
        serviceType: serviceOption['id'],
        pickupAddress: pickupArea.trim(),
        dropoffAddress: pickupArea.trim(),
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: 'Monthly Hire',
        vehicleColor: 'N/A',
        plateNumber: 'MONTHLY',
      );

      final createData = await HireDriverApiService.createHireDriverRequest(
        serviceType: serviceOption['id'],
        pickupAddress: pickupArea.trim(),
        dropoffAddress: pickupArea.trim(),
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        vehicleModel: 'Monthly Hire',
        vehicleColor: 'N/A',
        plateNumber: 'MONTHLY',
      );

      final hireRequestId = createData['hireRequest']?['id']?.toString();

      if (hireRequestId == null || hireRequestId.isEmpty) {
        return {
          'success': false,
          'message': 'Hire request ID not found',
        };
      }

      return {
        'success': true,
        'hireRequestId': hireRequestId,
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