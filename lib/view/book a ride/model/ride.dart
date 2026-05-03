import 'package:hire_driver/view/book%20a%20ride/model/location.dart';


class RideModel {
  final String id;
  final LocationModel pickup;
  final LocationModel dropoff;
  final String tripType;
  final String vehicleType;
  final double distanceKm;
  final int durationMinutes;
  final int offeredFare;
  final String status;

  RideModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.tripType,
    required this.vehicleType,
    required this.distanceKm,
    required this.durationMinutes,
    required this.offeredFare,
    required this.status,
  });

  factory RideModel.fromJson(Map<String, dynamic>? json) {
    return RideModel(
      id: json?['id']?.toString() ?? json?['_id']?.toString() ?? '',
      pickup: LocationModel.fromJson(json?['pickup']),
      dropoff: LocationModel.fromJson(json?['dropoff']),
      tripType: json?['tripType']?.toString() ?? '',
      vehicleType: json?['vehicleType']?.toString() ?? '',
      distanceKm: (json?['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json?['durationMinutes'] as num?)?.toInt() ?? 0,
      offeredFare: (json?['offeredFare'] as num?)?.toInt() ?? 0,
      status: json?['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'tripType': tripType,
      'vehicleType': vehicleType,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'offeredFare': offeredFare,
      'status': status,
    };
  }
}