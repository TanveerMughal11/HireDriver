import 'package:flutter/material.dart';
import 'package:hire_driver/customwidgets/bottombar.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/utils/theme_color_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool rideUpdates = true;
  bool promotions = true;
  bool systemAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PageTitle(title: 'Settings'),
              const SizedBox(height: 18),

              _SettingsSection(
                title: 'APP THEME',
                child: Column(
                  children: [
                    _SettingSwitchTile(
                      icon: Icons.dark_mode_rounded,
                      iconBackground: AppColors.softBg(context),
                      iconColor: AppColors.primary,
                      title: 'Dark Mode',
                      subtitle: 'Change app colors to dark theme',
                      value: themeController.isDarkMode,
                      onChanged: (value) {
                        setState(() {});
                        themeController.toggleTheme(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _SettingsSection(
                title: 'NOTIFICATIONS',
                child: Column(
                  children: [
                    _SettingSwitchTile(
                      icon: Icons.local_taxi_rounded,
                      iconBackground: AppColors.softBg(context),
                      iconColor: const Color(0xFFE5674D),
                      title: 'Ride Updates',
                      subtitle: 'Trip status and driver arrival',
                      value: rideUpdates,
                      onChanged: (value) {
                        setState(() {
                          rideUpdates = value;
                        });
                      },
                    ),
                    const _TileDivider(),
                    _SettingSwitchTile(
                      icon: Icons.card_giftcard_rounded,
                      iconBackground: AppColors.softBg(context),
                      iconColor: const Color(0xFFE2A51A),
                      title: 'Promotions & Offers',
                      subtitle: 'Discounts and special deals',
                      value: promotions,
                      onChanged: (value) {
                        setState(() {
                          promotions = value;
                        });
                      },
                    ),
                    const _TileDivider(),
                    _SettingSwitchTile(
                      icon: Icons.notifications_active_rounded,
                      iconBackground: AppColors.softBg(context),
                      iconColor: const Color(0xFFF4A62A),
                      title: 'System Alerts',
                      subtitle: 'App updates and maintenance',
                      value: systemAlerts,
                      onChanged: (value) {
                        setState(() {
                          systemAlerts = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const _SettingsSection(
                title: 'LEGAL & ACCOUNT',
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                    ),
                    _TileDivider(),
                    _ActionTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                    ),
                    _TileDivider(),
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      value: 'v1.0.0',
                    ),
                    _TileDivider(),
                    _ActionTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Account',
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  final String title;

  const _PageTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text1(context),
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.secondary.withOpacity(0.35),
                ),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.text2(context).withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.secondary.withOpacity(0.65),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFE5484D) : AppColors.primary;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.softBg(context),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive
                      ? const Color(0xFFE5484D)
                      : AppColors.text1(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondary.withOpacity(0.95),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.softBg(context),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.text1(context),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: AppColors.secondary.withOpacity(0.35),
    );
  }
}