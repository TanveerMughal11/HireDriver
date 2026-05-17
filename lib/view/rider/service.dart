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
      if (response.body.trim().isEmpty) {
        return {
          '_invalidResponse': true,
          'message': 'Server returned an empty response',
        };
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {'data': decoded};
    } catch (_) {
      return {
        '_invalidResponse': true,
        'message':
            'Server returned invalid response (${response.statusCode}). Please try again.',
      };
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
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
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/api/rider-requests/$rideRequestId/navigation'),
      headers: headers,
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 &&
        (data['success'] == true ||
            data['navigation'] != null ||
            data['trip'] != null ||
            _asMap(data['data'])['navigation'] != null)) {
      return _normalizeNavigationResponse(data);
    }

    final shouldTryReviewFallback =
        data['_invalidResponse'] == true ||
        response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 405 ||
        response.statusCode >= 500;

    if (shouldTryReviewFallback) {
      final fallback = await _buildNavigationFromReview(
        rideRequestId: rideRequestId,
        headers: headers,
      );

      if (fallback != null) return fallback;
    }

    throw Exception(data['message'] ?? 'Failed to fetch navigation');
  }

  static Map<String, dynamic> _normalizeNavigationResponse(
    Map<String, dynamic> data,
  ) {
    final dataMap = _asMap(data['data']);
    final navigation =
        _asMap(data['navigation']).isNotEmpty
            ? _asMap(data['navigation'])
            : _asMap(dataMap['navigation']).isNotEmpty
            ? _asMap(dataMap['navigation'])
            : dataMap.isNotEmpty
            ? dataMap
            : data;

    return {
      ...data,
      'success': true,
      'navigation': navigation,
    };
  }

  static Future<Map<String, dynamic>?> _buildNavigationFromReview({
    required String rideRequestId,
    required Map<String, String> headers,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/rider-requests/$rideRequestId/review'),
      headers: headers,
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 200) return null;

    final dataMap = _asMap(data['data']);
    final review = _asMap(
      data['review'] ?? dataMap['review'] ?? dataMap['rideRequest'] ?? dataMap,
    );
    final trip = _asMap(review['trip']);

    if (trip.isEmpty) return null;

    final pickup = _asMap(trip['pickup']);
    final dropoff = _asMap(trip['dropoff'] ?? trip['destination']);
    final distance = trip['distanceKm'] ?? trip['distance'] ?? 0;
    final duration = trip['durationMinutes'] ?? trip['duration'] ?? 0;

    final navigation = {
      'trip': trip,
      'navigation': {
        'etaMinutes': duration is num ? duration.toInt() : 8,
        'locationLabel': pickup['address'] ?? 'Pickup',
        'tripMeta': '$distance km - $duration min',
        'actionButton': 'Arrived at Pickup',
      },
      'map': {
        'pickupMarker': pickup,
        'dropoffMarker': dropoff,
      },
    };

    return {
      'success': true,
      'navigation': navigation,
      'message': 'Navigation loaded from request details',
    };
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

    print(response.statusCode);
    print(response.body);

    final data = _decodeResponse(response);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
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

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to accept ride request');
  }

  static Future<Map<String, dynamic>> startRide({
    required String rideRequestId,
  }) async {
    return _postRideLifecycle(
      riderRequestPath: '/api/rider-requests/$rideRequestId/start',
      fallbackRidePath: '/api/rides/driver/active/$rideRequestId/start',
      fallbackMessage: 'Failed to start ride',
    );
  }

  static Future<Map<String, dynamic>> endRide({
    required String rideRequestId,
  }) async {
    return _postRideLifecycle(
      riderRequestPath: '/api/rider-requests/$rideRequestId/end',
      fallbackRidePath: '/api/rides/driver/active/$rideRequestId/end',
      fallbackMessage: 'Failed to end ride',
      fallbackBody: {'finalPrice': 0, 'distanceCovered': 0},
    );
  }

  static Future<Map<String, dynamic>> _postRideLifecycle({
    required String riderRequestPath,
    required String fallbackRidePath,
    required String fallbackMessage,
    Map<String, dynamic>? fallbackBody,
  }) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final primaryResponse = await http.post(
      Uri.parse('$baseUrl$riderRequestPath'),
      headers: headers,
    );
    final primaryData = _decodeResponse(primaryResponse);

    if ((primaryResponse.statusCode == 200 ||
            primaryResponse.statusCode == 201) &&
        primaryData['success'] == true) {
      return primaryData;
    }

    final shouldTryFallback =
        primaryResponse.statusCode == 404 ||
        primaryResponse.statusCode == 405 ||
        primaryResponse.statusCode == 400;

    if (!shouldTryFallback) {
      throw Exception(primaryData['message'] ?? fallbackMessage);
    }

    final fallbackResponse = await http.post(
      Uri.parse('$baseUrl$fallbackRidePath'),
      headers: headers,
      body: fallbackBody == null ? null : jsonEncode(fallbackBody),
    );
    final fallbackData = _decodeResponse(fallbackResponse);

    if ((fallbackResponse.statusCode == 200 ||
            fallbackResponse.statusCode == 201) &&
        fallbackData['success'] == true) {
      return fallbackData;
    }

    throw Exception(fallbackData['message'] ?? fallbackMessage);
  }
}
