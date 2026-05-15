import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/drivercomingtoyou.dart';
import 'package:hire_driver/view/hiredriver/screens/drivertopassenger.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  void _openDriver(BuildContext context) {
    // Navigate to driver screen
    // Example:
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => const DriverComingScreen()));
  }

  void _openRider(BuildContext context) {
    // Navigate to rider screen
    // Example:
     Navigator.push(context,
       MaterialPageRoute(builder: (_) => const DriverArrivingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_rounded,
                size: 80,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1(context),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Continue as Driver or Rider',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text2(context),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => _openDriver(context),
                  icon: const Icon(Icons.drive_eta_rounded),
                  label: const Text(
                    'Continue as Driver',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => _openRider(context),
                  icon: const Icon(Icons.person_rounded),
                  label: const Text(
                    'Continue as Rider',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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