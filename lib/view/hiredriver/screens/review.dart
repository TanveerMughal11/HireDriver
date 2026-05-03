import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/screens/tripcompleted.dart';

class TripCompletedScreen extends StatefulWidget {
  const TripCompletedScreen({super.key});

  @override
  State<TripCompletedScreen> createState() => _TripCompletedScreenState();
}

class _TripCompletedScreenState extends State<TripCompletedScreen> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double amountPaid = 405;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  children: [
                    _buildReceiptCard(amountPaid),
                    const SizedBox(height: 16),
                    _buildRatingCard(),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.download_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Download Receipt',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
  if (selectedRating == 0) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const TripCompletedSuccessScreen(),
    ),
  );
},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        selectedRating == 0
                            ? 'Select Rating First'
                            : 'Submit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(double amountPaid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.secondary),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFDDF6E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_box_rounded,
              color: Color(0xFF18B777),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Trip Completed',
            style: TextStyle(
              color: Color(0xFF18B777),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'April 11, 2026 · 2:45 PM',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),
          Divider(color: AppColors.secondary.withOpacity(0.7), height: 1),
          const SizedBox(height: 18),

          const _ReceiptRow(
            icon: Icons.location_on_rounded,
            iconColor: Color(0xFFFF5B8A),
            label: 'Pickup',
            value: 'DHA Phase 5, Lahore',
          ),
          const SizedBox(height: 14),

          const _ReceiptRow(
            icon: Icons.flag_rounded,
            iconColor: Color(0xFF6E6E6E),
            label: 'Drop-off',
            value: 'Gulberg III, Lahore',
          ),
          const SizedBox(height: 14),

          const _ReceiptRow(
            icon: Icons.timer_outlined,
            iconColor: Color(0xFFFF9D42),
            label: 'Duration',
            value: '45 minutes',
          ),
          const SizedBox(height: 14),

          const _ReceiptRow(
            icon: Icons.straighten_rounded,
            iconColor: Color(0xFF8B8FA8),
            label: 'Distance',
            value: '12.4 km',
          ),
          const SizedBox(height: 14),

          const _ReceiptRow(
            icon: Icons.person_rounded,
            iconColor: Color(0xFF4B8DFF),
            label: 'Driver',
            value: 'Ali Hassan',
          ),

          const SizedBox(height: 18),
          Divider(color: AppColors.secondary.withOpacity(0.7), height: 1),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Amount Paid',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'PKR ',
                  style: TextStyle(
                    color: Color(0xFF92A0BD),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                amountPaid.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFF18B777),
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.secondary),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Rate Ali Hassan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (index) {
                final starIndex = index + 1;
                final isSelected = selectedRating >= starIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = starIndex;
                    });
                  },
                  child: Icon(
                    Icons.star_rounded,
                    size: 42,
                    color: isSelected
                        ? const Color(0xFFFFB020)
                        : AppColors.secondary,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          Container(
            decoration: BoxDecoration(
              color: AppColors.light.withOpacity(0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.8),
              ),
            ),
            child: TextField(
              controller: reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
  final Color iconColor;
  final String label;
  final String value;

  const _ReceiptRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: iconColor),
        const SizedBox(width: 14),
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF92A0BD),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}