import 'package:flutter/material.dart';
import 'package:hire_driver/service/rental_service.dart';
import 'package:hire_driver/utils/app_colors.dart';

class ReturnReviewScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const ReturnReviewScreen({super.key, required this.booking});

  @override
  State<ReturnReviewScreen> createState() => _ReturnReviewScreenState();
}

class _ReturnReviewScreenState extends State<ReturnReviewScreen> {
  int carRating = 0;
  int hostRating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool isSubmitting = false;

  Widget _buildStars(int rating, Function(int) onTap) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onTap(index + 1),
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Return & Review",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          /// ✅ Return Confirmation
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.secondary),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Confirm Return",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text("Please confirm car is returned in good condition."),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// ✅ Car Rating
          _sectionCard(
            title: "Rate Car",
            child: _buildStars(carRating, (val) {
              setState(() => carRating = val);
            }),
          ),

          const SizedBox(height: 16),

          /// ✅ Host Rating
          _sectionCard(
            title: "Rate Host",
            child: _buildStars(hostRating, (val) {
              setState(() => hostRating = val);
            }),
          ),

          const SizedBox(height: 16),

          /// ✅ Review Text
          _sectionCard(
            title: "Write Review",
            child: TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write your experience...",
                filled: true,
                fillColor: AppColors.light,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ✅ Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: isSubmitting
                ? null
                : () async {
                    final bookingId =
                        widget.booking['id']?.toString() ??
                        widget.booking['_id']?.toString() ??
                        widget.booking['bookingId']?.toString() ??
                        widget.booking['rentalId']?.toString() ??
                        '';

                    if (bookingId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to return booking: missing booking id',
                          ),
                        ),
                      );
                      return;
                    }

                    final combinedRating = ((carRating + hostRating) / 2)
                        .clamp(1, 5)
                        .toDouble();
                    final review = reviewController.text.trim();

                    setState(() {
                      isSubmitting = true;
                    });

                    final response = await RentalService.returnCar(
                      bookingId: bookingId,
                      rating: combinedRating,
                      review: review,
                    );

                    if (!mounted) return;

                    setState(() {
                      isSubmitting = false;
                    });

                    if (response['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response['message']?.toString() ??
                                'Car returned successfully',
                          ),
                        ),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response['message']?.toString() ??
                                'Failed to return car',
                          ),
                        ),
                      );
                    }
                  },
            child: const Text(
              "Submit Review",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
