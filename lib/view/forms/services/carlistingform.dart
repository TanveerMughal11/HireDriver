import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RentalApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ STEP 1: CREATE CAR LISTING
  static Future<Map<String, dynamic>> createCar({
    required String make,
    required String model,
    required String year,
    required String color,
    required String plate,
    required String seating,
    required String location,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/rentals'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "make": make,
        "model": model,
        "variant": "",
        "year": int.parse(year),
        "color": color,
        "plateNumber": plate,
        "seatingCapacity": int.parse(seating),
        "locationArea": location,
        "carType": "Sedan",
        "fuelType": "Petrol",
        "transmission": "Auto",
        "isInsured": true
      }),
    );

    return jsonDecode(response.body);
  }

  // ✅ STEP 2: UPLOAD PHOTOS
static Future<Map<String, dynamic>> uploadPhotos({
  required String listingId,
  required XFile front,
  required XFile back,
  required XFile interior,
  required XFile sideView,
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
      "front": await MultipartFile.fromFile(front.path, filename: front.name),
      "back": await MultipartFile.fromFile(back.path, filename: back.name),
      "interior": await MultipartFile.fromFile(
        interior.path,
        filename: interior.name,
      ),
      "sideView": await MultipartFile.fromFile(
        sideView.path,
        filename: sideView.name,
      ),
    });

    final response = await dio.patch(
      '$baseUrl/api/rentals/$listingId/photos',
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ),
    );

    return Map<String, dynamic>.from(response.data);
  } on DioException catch (e) {
    return {
      'success': false,
      'message': e.response?.data is Map
          ? e.response?.data['message'] ?? 'Photo upload failed'
          : 'Photo upload failed',
      'body': e.response?.data,
    };
  } catch (e) {
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}
static Future<Map<String, dynamic>> getMyListings() async {
  final token = await _getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/api/rentals/my-listings'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
  // ✅ STEP 3: PRICING
static Future<Map<String, dynamic>> setPricing({
  required String listingId,
  required int dailyRate,
  required int minDays,
  required List<String> days,
  required String insuranceDocument,
  required String vehicleRegistration,
}) async {
  final token = await _getToken();

  if (token == null || token.isEmpty) {
    return {
      'success': false,
      'message': 'Token not found. Please login again.',
    };
  }

  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/rentals/$listingId/pricing'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "dailyRate": dailyRate,
        "minRentalDays": minDays,
        "availableDays": days,
        "insuranceDocument": insuranceDocument,
        "vehicleRegistration": vehicleRegistration,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Pricing failed',
        'body': data,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}
  // ✅ STEP 4: SUBMIT
  static Future<Map<String, dynamic>> submitListing(
      String listingId) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/rentals/$listingId/submit'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}