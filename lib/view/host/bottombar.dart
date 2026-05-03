import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/host/earning.dart';
import 'package:hire_driver/view/host/home.dart';
import 'package:hire_driver/view/host/listing.dart';
import 'package:hire_driver/view/host/profile.dart';


class HostBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const HostBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;

    switch (index) {
      case 0:
        screen = const HostHomeScreen();
        break;
      case 1:
        screen = const HostListingsScreen();
        break;
      case 2:
        screen = const HostEarningsScreen();
        break;
      case 3:
        screen = const HostProfileScreen();
        break;
      default:
        screen = const HostHomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _HostNavItem(Icons.home_rounded, 'Home'),
      _HostNavItem(Icons.directions_car_rounded, 'Listings'),
      _HostNavItem(Icons.payments_rounded, 'Earnings'),
      _HostNavItem(Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) => InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _onItemTapped(context, index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index].icon,
                    color: currentIndex == index
                        ? AppColors.primary
                        : const Color(0xFF98A2B3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index].label,
                    style: TextStyle(
                      color: currentIndex == index
                          ? AppColors.primary
                          : const Color(0xFF98A2B3),
                      fontSize: 12,
                      fontWeight: currentIndex == index
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HostNavItem {
  final IconData icon;
  final String label;

  _HostNavItem(this.icon, this.label);
}