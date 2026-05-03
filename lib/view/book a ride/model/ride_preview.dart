import 'package:hire_driver/view/book%20a%20ride/model/location.dart';
import 'package:hire_driver/view/book a ride/model/vehicle_options.dart';


class RidePreviewModel {
  final LocationModel pickup;
  final LocationModel dropoff;
  final String tripType;
  final double distanceKm;
  final int durationMinutes;
  final List<VehicleOptionModel> vehicleOptions;

  RidePreviewModel({
    required this.pickup,
    required this.dropoff,
    required this.tripType,
    required this.distanceKm,
    required this.durationMinutes,
    required this.vehicleOptions,
  });

  factory RidePreviewModel.fromJson(Map<String, dynamic>? json) {
    final route = json?['route'];
    final rawVehicleOptions = json?['vehicleOptions'];

    return RidePreviewModel(
      pickup: LocationModel.fromJson(json?['pickup']),
      dropoff: LocationModel.fromJson(json?['dropoff']),
      tripType: json?['tripType']?.toString() ?? 'one-way',
      distanceKm: route is Map && route['distanceKm'] is num
          ? (route['distanceKm'] as num).toDouble()
          : (json?['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: route is Map && route['durationMinutes'] is num
          ? (route['durationMinutes'] as num).toInt()
          : (json?['durationMinutes'] as num?)?.toInt() ?? 0,
      vehicleOptions: rawVehicleOptions is List
          ? rawVehicleOptions
              .map((e) => VehicleOptionModel.fromJson(
                    e is Map<String, dynamic>
                        ? e
                        : Map<String, dynamic>.from(e),
                  ))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'tripType': tripType,
      'route': {
        'distanceKm': distanceKm,
        'durationMinutes': durationMinutes,
      },
      'vehicleOptions': vehicleOptions.map((e) => e.toJson()).toList(),
    };
  }
}