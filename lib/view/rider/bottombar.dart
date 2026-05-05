import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/driver/profile.dart';
import 'package:hire_driver/view/rider/home.dart';
import 'package:hire_driver/view/rider/profile.dart';

class RiderBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const RiderBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  static const List<_DriverBottomNavItemData> _items = [
    _DriverBottomNavItemData(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    _DriverBottomNavItemData(
      icon: Icons.payments_rounded,
      label: 'Earnings',
    ),
    _DriverBottomNavItemData(
      icon: Icons.reviews_rounded,
      label: 'Reviews',
    ),
    _DriverBottomNavItemData(
      icon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;

    switch (index) {
      case 0:
        screen = const RiderHomeScreen();
        break;
      case 1:
        screen = const RiderEarningsScreen();
        break;
      case 2:
        screen = const DriverReviewsScreen();
        break;
      case 3:
        screen = const RiderProfileScreen();
        break;
      default:
        screen = const RiderHomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.40)
                : const Color(0x12000000),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _items.length,
          (index) => _DriverReusableNavItem(
            icon: _items[index].icon,
            label: _items[index].label,
            active: currentIndex == index,
            onTap: () => _onItemTapped(context, index),
          ),
        ),
      ),
    );
  }
}

class _DriverReusableNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DriverReusableNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.text2(context),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.text2(context),
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverBottomNavItemData {
  final IconData icon;
  final String label;

  const _DriverBottomNavItemData({
    required this.icon,
    required this.label,
  });
}