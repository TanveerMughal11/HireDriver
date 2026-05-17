import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarRentalApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<Map<String, dynamic>>> browseCars({
    String search = '',
    String carType = '',
    String location = '',
    int seats = 0,
    int minPrice = 0,
    int maxPrice = 0,
    String fuelType = '',
    String transmission = '',
    String sort = 'newest',
  }) async {
    final uri = Uri.parse('$baseUrl/api/rentals/browse').replace(
      queryParameters: {
        'search': search,
        'carType': carType,
        'location': location,
        'seats': seats.toString(),
        'minPrice': minPrice.toString(),
        'maxPrice': maxPrice.toString(),
        'fuelType': fuelType,
        'transmission': transmission,
        'sort': sort,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'User-Agent': 'FlutterApp'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['listings'] is List) {
        return List<Map<String, dynamic>>.from(data['listings']);
      } else {
        throw Exception('No listings found');
      }
    } else {
      throw Exception('Failed to load cars: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getCarDetails(String listingId) async {
    final uri = Uri.parse('$baseUrl/api/rentals/browse/$listingId');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'User-Agent': 'FlutterApp'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['listing'] != null) {
        return Map<String, dynamic>.from(data['listing']);
      } else {
        throw Exception('Car details not found');
      }
    } else {
      throw Exception('Failed to load car details: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> bookRental({
    required String listingId,
    required String pickupDate,
    required String returnDate,
    bool selfPickup = true,
    bool addInsurance = false,
    String couponCode = '',
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/api/rentals/browse/$listingId/book');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'pickupDate': pickupDate,
        'returnDate': returnDate,
        'selfPickup': selfPickup,
        'addInsurance': addInsurance,
        'couponCode': couponCode.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(data['message'] ?? 'Rental booking failed');
      }
    } else {
      if (data['errors'] is List && data['errors'].isNotEmpty) {
        throw Exception(data['errors'][0]['msg'] ?? 'Rental booking failed');
      }
      throw Exception(data['message'] ?? 'Rental booking failed');
    }
  }

  static Future<Map<String, dynamic>> previewBooking({
    required String listingId,
    required String pickupDate,
    required String returnDate,
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final uri = Uri.parse(
      '$baseUrl/api/rentals/browse/$listingId/preview-booking',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'pickupDate': pickupDate, 'returnDate': returnDate}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(data['message'] ?? 'Booking preview failed');
      }
    } else {
      if (data['errors'] is List && data['errors'].isNotEmpty) {
        throw Exception(data['errors'][0]['msg'] ?? 'Booking preview failed');
      }
      throw Exception(data['message'] ?? 'Booking preview failed');
    }
  }
}

