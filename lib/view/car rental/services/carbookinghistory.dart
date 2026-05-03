import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarbookinghistoryApi {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // keep your old methods too:
  // browseCars()
  // getCarDetails()
  // previewBooking()
  // bookRental()

  static Future<List<Map<String, dynamic>>> getMyBookings() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/rentals/my-bookings'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['success'] == true && data['bookings'] is List) {
        return List<Map<String, dynamic>>.from(data['bookings']);
      } else {
        throw Exception(data['message'] ?? 'No bookings found');
      }
    } else {
      if (data['errors'] is List && data['errors'].isNotEmpty) {
        throw Exception(data['errors'][0]['msg'] ?? 'Failed to load bookings');
      }
      throw Exception(data['message'] ?? 'Failed to load bookings');
    }
  }
}