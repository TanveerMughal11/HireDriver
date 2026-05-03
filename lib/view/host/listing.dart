import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/host/bottombar.dart';


class HostListingsScreen extends StatelessWidget {
  const HostListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const HostBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Listings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: const [
          _ListingCard(
            carName: 'Toyota Corolla',
            status: 'Active',
            price: 'Rs. 6,000/day',
          ),
          SizedBox(height: 12),
          _ListingCard(
            carName: 'Honda Civic',
            status: 'Pending',
            price: 'Rs. 8,000/day',
          ),
          SizedBox(height: 12),
          _ListingCard(
            carName: 'Suzuki Alto',
            status: 'Paused',
            price: 'Rs. 4,000/day',
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final String carName;
  final String status;
  final String price;

  const _ListingCard({
    required this.carName,
    required this.status,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Active'
        ? Colors.green
        : status == 'Pending'
            ? Colors.orange
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}