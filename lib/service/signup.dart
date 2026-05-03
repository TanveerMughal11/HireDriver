import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': fullName, // backend wants "name"
          'email': email,
          'phone': phone,
          'password': password,
          'gender': gender,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Signup successful',
        };
      } else {
        String errorMessage = 'Signup failed';

        if (data['errors'] != null && data['errors'] is List) {
          errorMessage = (data['errors'] as List)
              .map((e) => e['msg'])
              .where((msg) => msg != null)
              .join('\n');
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}