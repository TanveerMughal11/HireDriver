class HireDriverOptionModel {
  final String id;
  final String title;
  final String description;
  final String badge;
  final String rateLabel;
  final String pricingType;
  final int hourlyRate;
  final int minimumHours;

  HireDriverOptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.rateLabel,
    required this.pricingType,
    required this.hourlyRate,
    required this.minimumHours,
  });

  factory HireDriverOptionModel.fromJson(Map<String, dynamic> json) {
    return HireDriverOptionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      rateLabel: json['rateLabel']?.toString() ?? '',
      pricingType: json['pricingType']?.toString() ?? '',
      hourlyRate: (json['hourlyRate'] as num?)?.toInt() ?? 0,
      minimumHours: (json['minimumHours'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'badge': badge,
      'rateLabel': rateLabel,
      'pricingType': pricingType,
      'hourlyRate': hourlyRate,
      'minimumHours': minimumHours,
    };
  }
}