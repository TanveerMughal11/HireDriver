import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiderRequestsApi {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

    return token;
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid server response');
    }
  }

  static Future<Map<String, dynamic>> updateAvailability({
    required bool isOnline,
    required bool liveLocationActive,
  }) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/rider-requests/availability'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'isOnline': isOnline,
        'liveLocationActive': liveLocationActive,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to update availability');
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rider-requests/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch dashboard');
  }

  static Future<Map<String, dynamic>> getRideRequestReview({
    required String rideRequestId,
  }) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rider-requests/$rideRequestId/review'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch request review');
  }

  static Future<Map<String, dynamic>> getRideNavigation({
    required String rideRequestId,
  }) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rider-requests/$rideRequestId/navigation'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch navigation');
  }
static Future<Map<String, dynamic>> getIncomingRequests() async {
  final token = await _getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/api/rider-requests/incoming-requests'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = _decodeResponse(response);

  if (response.statusCode == 200 && data['success'] == true) {
    return data;
  }

  throw Exception(data['message'] ?? 'Failed to fetch incoming requests');
}
static Future<Map<String, dynamic>> declineRideRequest({
  required String rideRequestId,
}) async {
  final token = await _getToken();

  final response = await http.post(
    Uri.parse('$baseUrl/api/rider-requests/$rideRequestId/decline'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = _decodeResponse(response);

  if (response.statusCode == 200 && data['success'] == true) {
    return data;
  }

  throw Exception(data['message'] ?? 'Failed to decline ride request');
}
  static Future<Map<String, dynamic>> acceptRideRequest({
    required String rideRequestId,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/rider-requests/$rideRequestId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to accept ride request');
  }
}