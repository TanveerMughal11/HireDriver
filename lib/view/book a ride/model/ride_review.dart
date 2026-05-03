class RideReviewModel {
  final int rating;
  final String review;

  RideReviewModel({
    required this.rating,
    required this.review,
  });

  factory RideReviewModel.fromJson(Map<String, dynamic>? json) {
    return RideReviewModel(
      rating: (json?['rating'] as num?)?.toInt() ?? 0,
      review: json?['review']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'review': review,
    };
  }
}