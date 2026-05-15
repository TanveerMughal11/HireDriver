import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/main.dart';
import 'package:hire_driver/view/history.dart';
import 'package:hire_driver/view/home.dart';
import 'package:hire_driver/view/profile/screens/profile.dart';
import 'package:hire_driver/view/wallet.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  static const List<_BottomNavItemData> _items = [
    _BottomNavItemData(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    _BottomNavItemData(
      icon: Icons.history_rounded,
      label: 'History',
    ),
    _BottomNavItemData(
      icon: Icons.wallet,
      label: 'Wallet',
    ),
    _BottomNavItemData(
      icon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

void _onItemTapped(BuildContext context, int index) {
  if (index == currentIndex) return;

  Widget screen;

  switch (index) {
    case 0:
      screen = const HomeScreen();
      break;
    case 1:
      screen = const HistoryScreen();
      break;
    case 2:
      screen = const WalletScreen();
      break;
    case 3:
      screen = const ProfileScreen();
      break;
    default:
      screen = const HomeScreen();
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.35)
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
          (index) => _ReusableNavItem(
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

class _ReusableNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ReusableNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColors.text2(context).withOpacity(0.75);

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
              color: active ? AppColors.primary : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : inactiveColor,
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

class _BottomNavItemData {
  final IconData icon;
  final String label;

  const _BottomNavItemData({
    required this.icon,
    required this.label,
  });
}