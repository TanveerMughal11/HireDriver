import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';

import 'package:hire_driver/view/forms/screen/carlistingform.dart';
import 'package:hire_driver/view/host/bottombar.dart';
import 'package:hire_driver/view/host/rentalrequest.dart';

class HostHomeScreen extends StatelessWidget {
  const HostHomeScreen({super.key});

  /*void _openListCar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CarListingForm()),
    );
  }*/

  void _openRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HostRentalRequestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const HostBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            const Text(
              'Rental Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your rental cars and requests',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.darkPrimary],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: const [
                  Icon(Icons.directions_car_rounded,
                      color: Colors.white, size: 42),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Earn money by listing your car for rent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(
                  child: _HostStatCard(
                    icon: Icons.car_rental_rounded,
                    value: '3',
                    label: 'Cars',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _HostStatCard(
                    icon: Icons.pending_actions_rounded,
                    value: '2',
                    label: 'Requests',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _HostStatCard(
                    icon: Icons.payments_rounded,
                    value: '45k',
                    label: 'Earned',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'List My Car',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Incoming Rental Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _RentalRequestCard(
              renterName: 'Ali Raza',
              carName: 'Toyota Corolla',
              dates: '25 Apr - 28 Apr',
              price: 'Rs. 18,000',
              onTap: () => _openRequest(context),
            ),
            const SizedBox(height: 12),
            _RentalRequestCard(
              renterName: 'Sara Khan',
              carName: 'Honda Civic',
              dates: '1 May - 3 May',
              price: 'Rs. 22,000',
              onTap: () => _openRequest(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentalRequestCard extends StatelessWidget {
  final String renterName;
  final String carName;
  final String dates;
  final String price;
  final VoidCallback onTap;

  const _RentalRequestCard({
    required this.renterName,
    required this.carName,
    required this.dates,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: AppColors.light,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    renterName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$carName • $dates',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HostStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}