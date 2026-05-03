import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

class AvailableDriversProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSelectingDriver = false;
  bool hasLoaded = false;

  Map<String, dynamic>? selectedTrip;
  int driversNearby = 0;
  String mapLabel = '0 drivers nearby';

  List<Map<String, dynamic>> drivers = [];

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadDrivers({
    required String hireRequestId,
  }) async {
    try {
      isLoading = true;
      _safeNotify();

      final findData = await HireDriverApiService.findDrivers(
        hireRequestId: hireRequestId,
      );

      final getData = await HireDriverApiService.getDrivers(
        hireRequestId: hireRequestId,
      );

      if (_disposed) return;

      final apiDrivers = getData['drivers'] ?? [];

      selectedTrip = getData['selectedTrip'];
      driversNearby = findData['driversNearby'] ?? apiDrivers.length;
      mapLabel =
          findData['mapSummary']?['label'] ?? '$driversNearby drivers nearby';

      drivers = List<Map<String, dynamic>>.from(
        apiDrivers.map((driver) {
          return {
            'id': driver['id'] ?? '',
            'driverId': driver['driverId'] ?? '',
            'name': driver['driverName'] ?? 'Driver',
            'rating': (driver['rating'] ?? 0).toDouble(),
            'price': 'PKR ${driver['amount'] ?? 0}/hr',
            'eta': '${driver['etaMinutes'] ?? 0} min',
            'experience': '${driver['tripsCompleted'] ?? 0} trips completed',
            'trips': '${driver['tripsCompleted'] ?? 0} trips',
            'languages': driver['note'] ?? 'Urdu',
            'photo': '',
            'badge': driver['rating']?.toString() ?? '0',
            'apiBadge': driver['badge'] ?? '',
            'phone': driver['phone'] ?? '',
            'vehicleMakeModel': driver['vehicleMakeModel'] ?? '',
            'vehiclePlate': driver['vehiclePlate'] ?? '',
            'avatarInitial': driver['avatarInitial'] ?? 'D',
            'status': driver['status'] ?? '',
          };
        }),
      );

      hasLoaded = true;
      isLoading = false;
      _safeNotify();
    } catch (e) {
      if (_disposed) return;
      isLoading = false;
      _safeNotify();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> selectDriver({
    required String hireRequestId,
    required Map<String, dynamic> driver,
  }) async {
    try {
      isSelectingDriver = true;
      _safeNotify();

      await HireDriverApiService.selectDriver(
        hireRequestId: hireRequestId,
        offerId: driver['id'],
      );

      return {
        'success': true,
        'selectedTrip': selectedTrip ?? {},
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    } finally {
      if (!_disposed) {
        isSelectingDriver = false;
        _safeNotify();
      }
    }
  }
}