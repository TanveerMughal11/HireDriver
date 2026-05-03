import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book a ride/provider/riderating.dart';
import 'package:provider/provider.dart';

class RideReviewScreen extends StatefulWidget {
  const RideReviewScreen({super.key});

  @override
  State<RideReviewScreen> createState() => _RideReviewScreenState();
}

class _RideReviewScreenState extends State<RideReviewScreen> {
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final provider = context.read<RideReviewProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThankYouRatingScreen(
          rating: provider.selectedRating,
        ),
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    final provider = context.read<RideReviewProvider>();

    final success = await provider.downloadReceipt();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Receipt downloaded" : "Receipt download failed",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RideReviewProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              _ReceiptCard(
                onDownload: provider.isDownloading
                    ? null
                    : () => _downloadReceipt(context),
              ),
              const SizedBox(height: 18),
              _RatingReviewCard(
                selectedRating: provider.selectedRating,
                controller: reviewController,
                onRatingTap: provider.selectRating,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      provider.selectedRating == 0 ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.secondary.withOpacity(.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final VoidCallback? onDownload;

  const _ReceiptCard({required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.softBg(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "You've arrived!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 20),
          const _ReceiptRow(
            icon: Icons.route_rounded,
            label: 'Trip',
            value: '12 km · 28 min',
          ),
          const SizedBox(height: 14),
          const _ReceiptRow(
            icon: Icons.person_rounded,
            label: 'Driver',
            value: 'Zain Ul Abideen',
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.grey.withOpacity(.7), thickness: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Paid',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'PKR ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text2(context),
                      ),
                    ),
                    const TextSpan(
                      text: '350',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(
                Icons.download_rounded,
                color: AppColors.darkPrimary,
                size: 20,
              ),
              label: const Text(
                'Download Receipt',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primary.withOpacity(.35),
                ),
                backgroundColor: AppColors.softBg(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.text2(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingReviewCard extends StatelessWidget {
  final int selectedRating;
  final TextEditingController controller;
  final ValueChanged<int> onRatingTap;

  const _RatingReviewCard({
    required this.selectedRating,
    required this.controller,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Rate Zain Ul Abideen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text1(context),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= selectedRating;

                return GestureDetector(
                  onTap: () => onRatingTap(starIndex),
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 42,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.secondary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Write review',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Share your experience with the driver...',
              hintStyle: TextStyle(
                color: AppColors.text2(context),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.softBg(context),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(.5),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThankYouRatingScreen extends StatelessWidget {
  final int rating;

  const ThankYouRatingScreen({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        color: AppColors.softBg(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Thanks for the rating!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your feedback helps us improve\ndriver quality on HireDrive.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: AppColors.text2(context),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softBg(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Points Earned',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '+35 pts',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text1(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            rating >= 4
                                ? Icons.workspace_premium_rounded
                                : Icons.star_rounded,
                            size: 34,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}