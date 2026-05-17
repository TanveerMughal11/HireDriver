import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverRequestsApi {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    return token;
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/driver-requests/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getIncomingRequests() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/driver-requests/incoming-requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateAvailability(bool isOnline) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/driver-requests/availability'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"isOnline": isOnline, "liveLocationActive": isOnline}),
    );

    return jsonDecode(response.body);
  }
}

