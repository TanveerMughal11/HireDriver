import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RentalOwnerApi {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

    return token;
  }

  static Future<Map<String, dynamic>> declineRentalRequest(
    String bookingId,
  ) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/rentals/owner/requests/$bookingId/decline'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to decline rental request');
  }

  static Future<Map<String, dynamic>> acceptRentalRequest(
    String bookingId,
  ) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/rentals/owner/requests/$bookingId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to accept rental request');
  }

  static Future<Map<String, dynamic>> getOwnerRequestDetails(
    String bookingId,
  ) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rentals/owner/requests/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to fetch rental request details',
    );
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid server response');
    }
  }

  static Future<Map<String, dynamic>> getOwnerDashboard() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rentals/owner/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch owner dashboard');
  }

  static Future<Map<String, dynamic>> getOwnerRequests() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rentals/owner/requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch rental requests');
  }
}

