import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RideApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'message': response.body,
      };
    }
  }

  static Future<Map<String, dynamic>> previewRide({
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    required String tripType,
    required double distanceKm,
    required int durationMinutes,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/rides/preview'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pickup': pickup,
          'dropoff': dropoff,
          'tripType': tripType,
          'distanceKm': distanceKm,
          'durationMinutes': durationMinutes,
        }),
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Ride preview failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createRide({
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    required String tripType,
    required String vehicleType,
    required double distanceKm,
    required int durationMinutes,
    required int offeredFare,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rides'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pickup': pickup,
          'dropoff': dropoff,
          'tripType': tripType,
          'vehicleType': vehicleType,
          'distanceKm': distanceKm,
          'durationMinutes': durationMinutes,
          'offeredFare': offeredFare,
        }),
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Ride create failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> acceptOffer({
    required String rideId,
    required String offerId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rides/$rideId/offers/$offerId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Offer accept failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> declineOffer({
    required String rideId,
    required String offerId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rides/$rideId/offers/$offerId/decline'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Offer decline failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> counterOffer({
    required String rideId,
    required String offerId,
    required int counterAmount,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rides/$rideId/offers/$offerId/counter'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'counterAmount': counterAmount,
        }),
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Counter offer failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMyRideRequests() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rides/my-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'My rides loaded',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMyHireRequests() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/hire-drivers/my-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Hire requests loaded',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> broadcastRide({
    required String rideId,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rides/$rideId/broadcast'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'Ride broadcast failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}