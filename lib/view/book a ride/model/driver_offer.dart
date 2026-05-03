class DriverOfferModel {
  final String id;
  final String driverName;
  final String vehicleName;
  final String vehicleColor;
  final String vehiclePlate;
  final int amount;
  final int etaMinutes;
  final double rating;
  final String status;

  DriverOfferModel({
    required this.id,
    required this.driverName,
    required this.vehicleName,
    required this.vehicleColor,
    required this.vehiclePlate,
    required this.amount,
    required this.etaMinutes,
    required this.rating,
    required this.status,
  });

  factory DriverOfferModel.fromJson(Map<String, dynamic>? json) {
    return DriverOfferModel(
      id: json?['_id']?.toString() ?? json?['id']?.toString() ?? '',
      driverName: json?['driverName']?.toString() ?? 'Driver',
      vehicleName: json?['vehicleName']?.toString() ?? 'Vehicle',
      vehicleColor: json?['vehicleColor']?.toString() ?? '',
      vehiclePlate: json?['vehiclePlate']?.toString() ?? '',
      amount: (json?['amount'] as num?)?.toInt() ?? 0,
      etaMinutes: (json?['etaMinutes'] as num?)?.toInt() ?? 0,
      rating: (json?['rating'] as num?)?.toDouble() ?? 0.0,
      status: json?['status']?.toString() ?? '',
    );
  }

  String get carInfo {
    final parts = [
      vehicleName,
      if (vehicleColor.isNotEmpty) vehicleColor,
      if (vehiclePlate.isNotEmpty) vehiclePlate,
    ];

    return parts.join(' • ');
  }

  String get avatarLetter {
    if (driverName.isEmpty) return 'D';
    return driverName[0].toUpperCase();
  }

  bool get isDisabled {
    final value = status.toLowerCase();
    return value == 'accepted' || value == 'declined';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'driverName': driverName,
      'vehicleName': vehicleName,
      'vehicleColor': vehicleColor,
      'vehiclePlate': vehiclePlate,
      'amount': amount,
      'etaMinutes': etaMinutes,
      'rating': rating,
      'status': status,
    };
  }
}