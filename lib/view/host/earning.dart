import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/host/bottombar.dart';


class HostEarningsScreen extends StatelessWidget {
  const HostEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const HostBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Host Earnings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.darkPrimary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earnings',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 6),
                Text(
                  'Rs. 45,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'From 8 completed rentals',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _EarningHistoryItem(
            title: 'Toyota Corolla Rental',
            subtitle: '25 Apr - 28 Apr',
            amount: 'Rs. 18,000',
          ),
          SizedBox(height: 10),
          const _EarningHistoryItem(
            title: 'Honda Civic Rental',
            subtitle: '10 Apr - 12 Apr',
            amount: 'Rs. 16,000',
          ),
          SizedBox(height: 10),
          const _EarningHistoryItem(
            title: 'Suzuki Alto Rental',
            subtitle: '2 Apr - 4 Apr',
            amount: 'Rs. 8,000',
          ),
        ],
      ),
    );
  }
}

class _EarningHistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _EarningHistoryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}