class LocationModel {
  final String address;
  final String placeId;
  final double lat;
  final double lng;

  LocationModel({
    required this.address,
    required this.placeId,
    required this.lat,
    required this.lng,
  });

  factory LocationModel.fromJson(Map<String, dynamic>? json) {
    final coordinates = json?['coordinates'];

    return LocationModel(
      address: json?['address']?.toString() ?? '',
      placeId: json?['placeId']?.toString() ?? '',
      lat: coordinates is Map && coordinates['lat'] is num
          ? (coordinates['lat'] as num).toDouble()
          : 0.0,
      lng: coordinates is Map && coordinates['lng'] is num
          ? (coordinates['lng'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'placeId': placeId,
      'coordinates': {
        'lat': lat,
        'lng': lng,
      },
    };
  }
}