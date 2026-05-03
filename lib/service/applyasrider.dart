import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverApplicationApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> savePersonalInfo({
    required String fullName,
    required String cnicNumber,
    required String dateOfBirth,
    required String homeAddress,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/driver-applications/personal-info'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullName': fullName,
        'cnicNumber': cnicNumber,
        'dateOfBirth': dateOfBirth,
        'homeAddress': homeAddress,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadDocuments({
    required XFile cnicFront,
    required XFile cnicBack,
    required XFile licenseFront,
    required XFile licenseBack,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Token not found. Please login again.',
      };
    }

    try {
      final dio = Dio();

      final formData = FormData.fromMap({
        'cnicFront': await MultipartFile.fromFile(
          cnicFront.path,
          filename: cnicFront.name,
        ),
        'cnicBack': await MultipartFile.fromFile(
          cnicBack.path,
          filename: cnicBack.name,
        ),
        'licenseFront': await MultipartFile.fromFile(
          licenseFront.path,
          filename: licenseFront.name,
        ),
        'licenseBack': await MultipartFile.fromFile(
          licenseBack.path,
          filename: licenseBack.name,
        ),
      });

      final response = await dio.post(
        '$baseUrl/api/driver-applications/documents',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('DIO UPLOAD STATUS: ${response.statusCode}');
      print('DIO UPLOAD BODY: ${response.data}');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print('DIO ERROR STATUS: ${e.response?.statusCode}');
      print('DIO ERROR BODY: ${e.response?.data}');

      return {
        'success': false,
        'message': e.response?.data is Map
            ? e.response?.data['message'] ?? 'Documents upload failed'
            : 'Documents upload failed',
        'body': e.response?.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> saveVehicleInfo({
    required String vehicleMakeModel,
    required String plateNumber,
    required List<String> services,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/driver-applications/vehicle-info'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vehicleMakeModel': vehicleMakeModel,
        'plateNumber': plateNumber,
        'services': services,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitApplication() async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/driver-applications/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'consentAccepted': true,
        'consentStatement':
            'I agree to HireDrive background checks and verifications.',
        'note': 'Submitted from mobile app',
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyApplication() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/driver-applications/me'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}