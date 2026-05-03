import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> getMyApplication() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/driver-applications/me'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to load application');
  }
}