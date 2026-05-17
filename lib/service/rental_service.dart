import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RentalService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Renter Side - Browse and Book

  static Future<Map<String, dynamic>> browseListings({
    String? location,
    String? vehicleType,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (location != null) query['location'] = location;
      if (vehicleType != null) query['vehicleType'] = vehicleType;
      if (minPrice != null) query['minPrice'] = minPrice;
      if (maxPrice != null) query['maxPrice'] = maxPrice;

      final uri = Uri.parse(
        '$baseUrl/api/rentals/browse',
      ).replace(queryParameters: query.isEmpty ? null : query);

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Listings fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch listings',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getListingDetails(
    String listingId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/browse/$listingId'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Listing details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch listing details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> previewBooking({
    required String listingId,
    required String startDate,
    required String endDate,
    required int numberOfDays,
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
        Uri.parse('$baseUrl/api/rentals/browse/$listingId/preview-booking'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'startDate': startDate,
          'endDate': endDate,
          'numberOfDays': numberOfDays,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Booking preview generated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to preview booking',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> bookRental({
    required String listingId,
    required String startDate,
    required String endDate,
    required int numberOfDays,
    required double totalPrice,
    required String pickupLocation,
    required String dropoffLocation,
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
        Uri.parse('$baseUrl/api/rentals/browse/$listingId/book'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'startDate': startDate,
          'endDate': endDate,
          'numberOfDays': numberOfDays,
          'totalPrice': totalPrice,
          'pickupLocation': pickupLocation,
          'dropoffLocation': dropoffLocation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Rental booked successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to book rental',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/my-bookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Bookings fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch bookings',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBookingDetails(
    String bookingId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/bookings/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Booking details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch booking details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getActiveRentals() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/my-active-rentals'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Active rentals fetched successfully',
        };
      } else {
        final fallback = await _getActiveRentalsFromBookings(token);
        if (fallback['success'] == true) return fallback;

        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch active rentals',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _getActiveRentalsFromBookings(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/my-bookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch bookings',
        };
      }

      final rawBookings = data['bookings'] ?? data['data']?['bookings'] ?? [];
      final bookings = rawBookings is List
          ? rawBookings.where((booking) {
              if (booking is! Map) return false;
              final status = booking['status']?.toString().toLowerCase() ?? '';
              return status == 'active' ||
                  status == 'confirmed' ||
                  status == 'ongoing' ||
                  status == 'in_progress' ||
                  status == 'in-progress';
            }).toList()
          : [];

      return {
        'success': true,
        'data': {'activeRentals': bookings},
        'message': 'Active rentals fetched successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getActiveRentalDetails(
    String bookingId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/my-active-rentals/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Active rental details fetched successfully',
        };
      } else {
        return getBookingDetails(bookingId);
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> returnCar({
    required String bookingId,
    required double rating,
    required String review,
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
        Uri.parse('$baseUrl/api/rentals/my-active-rentals/$bookingId/return'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rating': rating, 'review': review}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Car returned successfully',
        };
      } else {
        final fallback = await _returnCarAtPath(
          path: '/api/rentals/bookings/$bookingId/return',
          token: token,
          rating: rating,
          review: review,
        );
        if (fallback['success'] == true) return fallback;

        return {
          'success': false,
          'message': data['message'] ?? 'Failed to return car',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _returnCarAtPath({
    required String path,
    required String token,
    required double rating,
    required String review,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rating': rating, 'review': review}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Car returned successfully',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to return car',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Owner Side - Create and Manage Listings

  static Future<Map<String, dynamic>> createListing({
    required String carMakeModel,
    required String carType,
    required String color,
    required String plateNumber,
    required double pricePerDay,
    required String description,
    required List<String> amenities,
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
        Uri.parse('$baseUrl/api/rentals'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'carMakeModel': carMakeModel,
          'carType': carType,
          'color': color,
          'plateNumber': plateNumber,
          'pricePerDay': pricePerDay,
          'description': description,
          'amenities': amenities,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Listing created successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create listing',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadListingPhotos({
    required String listingId,
    required List<XFile> photos,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final dio = Dio();
      final formData = FormData();

      for (int i = 0; i < photos.length; i++) {
        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              photos[i].path,
              filename: photos[i].name,
            ),
          ),
        );
      }

      final response = await dio.patch(
        '$baseUrl/api/rentals/$listingId/photos',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Photos uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to upload photos',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Upload failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMyListings() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/my-listings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Listings fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch listings',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getListingOwner(String listingId) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/$listingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Listing details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch listing',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitListingForApproval(
    String listingId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rentals/$listingId/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Listing submitted for approval',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit listing',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerDashboard() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/owner/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Dashboard fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch dashboard',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerEarnings() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/owner/earnings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Earnings fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch earnings',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerRentalRequests() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/owner/requests'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Rental requests fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch requests',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerRentalRequestDetails(
    String bookingId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rentals/owner/requests/$bookingId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Request details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch request details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> acceptRentalRequest(
    String bookingId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rentals/owner/requests/$bookingId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Rental request accepted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to accept request',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> declineRentalRequest(
    String bookingId,
  ) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/rentals/owner/requests/$bookingId/decline'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': 'Rental request declined successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to decline request',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

