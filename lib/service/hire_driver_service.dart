import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HireDriverService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Rider Side - Hiring Drivers

  static Future<Map<String, dynamic>> getOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/hire-drivers/options'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Options fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch options',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> previewHireDriver({
    required String serviceType,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String scheduledDate,
    required String scheduledTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
    required double estimatedDistanceKm,
    required double estimatedDurationMinutes,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/hire-drivers/preview'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'serviceType': serviceType,
          'pickup': {
            'address': pickupAddress,
            'latitude': pickupLat,
            'longitude': pickupLng,
          },
          'dropoff': {
            'address': dropoffAddress,
            'latitude': dropoffLat,
            'longitude': dropoffLng,
          },
          'scheduledDate': scheduledDate,
          'scheduledTime': scheduledTime,
          'vehicle': {
            'makeModel': vehicleModel,
            'color': vehicleColor,
            'plateNumber': plateNumber,
          },
          'estimatedDistanceKm': estimatedDistanceKm,
          'estimatedDurationMinutes': estimatedDurationMinutes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Preview generated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to generate preview',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createHireDriverRequest({
    required String serviceType,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String scheduledDate,
    required String scheduledTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
    required double estimatedDistanceKm,
    required double estimatedDurationMinutes,
    required double estimatedPrice,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/hire-drivers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'serviceType': serviceType,
          'pickup': {
            'address': pickupAddress,
            'latitude': pickupLat,
            'longitude': pickupLng,
          },
          'dropoff': {
            'address': dropoffAddress,
            'latitude': dropoffLat,
            'longitude': dropoffLng,
          },
          'scheduledDate': scheduledDate,
          'scheduledTime': scheduledTime,
          'vehicle': {
            'makeModel': vehicleModel,
            'color': vehicleColor,
            'plateNumber': plateNumber,
          },
          'estimatedDistanceKm': estimatedDistanceKm,
          'estimatedDurationMinutes': estimatedDurationMinutes,
          'estimatedPrice': estimatedPrice,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Hire driver request created successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create request',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> findAvailableDrivers(
    String hireRequestId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId/find-drivers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Available drivers found successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to find drivers',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAvailableDrivers(
    String hireRequestId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId/drivers'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Drivers fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch drivers',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> selectDriver({
    required String hireRequestId,
    required String offerId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/hire-drivers/$hireRequestId/drivers/$offerId/select',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Driver selected successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to select driver',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> confirmBooking(
    String hireRequestId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Booking confirmed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to confirm booking',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHireDriverRequest(
    String hireRequestId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Request details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch request details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMyHireDriverRequests() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/hire-drivers/my-requests'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Requests fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch requests',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

