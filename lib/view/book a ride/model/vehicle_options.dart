class VehicleOptionModel {
  final String type;
  final String label;
  final int minFare;
  final int suggestedFare;
  final int maxFare;
  final String currency;

  VehicleOptionModel({
    required this.type,
    required this.label,
    required this.minFare,
    required this.suggestedFare,
    required this.maxFare,
    required this.currency,
  });

  factory VehicleOptionModel.fromJson(Map<String, dynamic>? json) {
    return VehicleOptionModel(
      type: json?['type']?.toString() ?? '',
      label: json?['label']?.toString() ?? '',
      minFare: (json?['minFare'] as num?)?.toInt() ?? 0,
      suggestedFare: (json?['suggestedFare'] as num?)?.toInt() ?? 0,
      maxFare: (json?['maxFare'] as num?)?.toInt() ?? 0,
      currency: json?['currency']?.toString() ?? 'PKR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'minFare': minFare,
      'suggestedFare': suggestedFare,
      'maxFare': maxFare,
      'currency': currency,
    };
  }
}