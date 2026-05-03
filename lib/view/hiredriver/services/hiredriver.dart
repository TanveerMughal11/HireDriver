import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HireDriverApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> getOptions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/hire-drivers/options'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to load hire driver options');
  }

  static Future<Map<String, dynamic>> previewHireDriver({
    required String serviceType,
    required String pickupAddress,
    required String dropoffAddress,
    required String scheduledDate,
    required String scheduledTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/hire-drivers/preview'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'serviceType': serviceType,
        'pickup': {
          'address': pickupAddress,
        },
        'dropoff': {
          'address': dropoffAddress,
        },
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'vehicle': {
          'makeModel': vehicleModel,
          'color': vehicleColor,
          'plateNumber': plateNumber,
        },
        'estimatedDistanceKm': 12.4,
        'estimatedDurationMinutes': 45,
      }),
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to generate preview');
  }

  static Future<Map<String, dynamic>> createHireDriverRequest({
    required String serviceType,
    required String pickupAddress,
    required String dropoffAddress,
    required String scheduledDate,
    required String scheduledTime,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/hire-drivers'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'serviceType': serviceType,
        'pickup': {
          'address': pickupAddress,
        },
        'dropoff': {
          'address': dropoffAddress,
        },
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'vehicle': {
          'makeModel': vehicleModel,
          'color': vehicleColor,
          'plateNumber': plateNumber,
        },
        'estimatedDistanceKm': 12.4,
        'estimatedDurationMinutes': 45,
      }),
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to create hire driver request');
  }

  static Future<Map<String, dynamic>> findDrivers({
    required String hireRequestId,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId/find-drivers'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to find drivers');
  }

  static Future<Map<String, dynamic>> getDrivers({
    required String hireRequestId,
  }) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId/drivers'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to load drivers');
  }

  static Future<Map<String, dynamic>> selectDriver({
    required String hireRequestId,
    required String offerId,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/hire-drivers/$hireRequestId/drivers/$offerId/select',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to select driver');
  }

  static Future<Map<String, dynamic>> confirmHireDriver({
    required String hireRequestId,
    required String paymentMethod,
    required String promoCode,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/hire-drivers/$hireRequestId/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'paymentMethod': paymentMethod,
        'promoCode': promoCode,
      }),
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to confirm booking');
  }
}