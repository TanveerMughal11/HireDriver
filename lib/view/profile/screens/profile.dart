import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hire_driver/customwidgets/bottombar.dart';
import 'package:hire_driver/customwidgets/buttons.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/applyasdriver2nd.dart';
import 'package:hire_driver/view/applyasrider.dart';
import 'package:hire_driver/view/car%20rental/listofactivecars.dart';
import 'package:hire_driver/view/car%20rental/screens/carbookinghistory.dart';
import 'package:hire_driver/view/car%20rental/activerental.dart';
import 'package:hire_driver/view/car%20rental/screens/mycarlisting.dart';
import 'package:hire_driver/view/driverandriderscreens.dart';
import 'package:hire_driver/view/forms/screen/applyasrider.dart';
import 'package:hire_driver/view/profile/provider/profile.dart';
import 'package:hire_driver/view/rider/home.dart';
import 'package:hire_driver/view/driver/home.dart';
import 'package:hire_driver/view/editprofile.dart';
import 'package:hire_driver/view/help_and_support.dart';
import 'package:hire_driver/view/host/home.dart';
import 'package:hire_driver/auth/login/screen/login.dart';
import 'package:hire_driver/view/settings.dart';
import 'package:hire_driver/view/updateinfo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 3,
      ),
      body: Column(
        children: [
          const _ProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Column(
                children: [
                  ChangeNotifierProvider(
                    create: (_) => ProfileDriverStatusProvider()
                      ..loadDriverApplicationStatus(),
                    child: const _ProfileActionsCard(),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Logout",
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.remove('token');
                      await prefs.remove('userData');

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 56, 18, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkPrimary,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.14),
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.35),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 42,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: _ProfileUserInfo(),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '0★',
                  label: 'Rating',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '0',
                  label: 'Trips',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: 'Verified',
                  label: 'Status',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileUserInfo extends StatefulWidget {
  const _ProfileUserInfo();

  @override
  State<_ProfileUserInfo> createState() => _ProfileUserInfoState();
}

class _ProfileUserInfoState extends State<_ProfileUserInfo> {
  String userName = "User";
  String phone = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final user = jsonDecode(userString);

      setState(() {
        userName = user['name'] ?? "User";
        phone = user['phone'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phone,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.85),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 16,
              color: Colors.amber,
            ),
            SizedBox(width: 4),
            Text(
              'Top Rated User',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withOpacity(0.10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionsCard extends StatelessWidget {
  const _ProfileActionsCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileDriverStatusProvider>(
      builder: (context, provider, _) {
      final riderStatus = provider.riderStatus;
final driverStatus = provider.driverStatus;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card(context).withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.secondary.withOpacity(0.55)),
          ),
          child: Column(
            children: [
              const _TileDivider(),
              _MenuTile(
                icon: Icons.history_toggle_off_rounded,
                title: 'My Bookings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyBookingsScreen(),
                    ),
                  );
                },
              ),
              const _TileDivider(),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
            else if (riderStatus == 'approved')
                _MenuTile(
                  icon: Icons.switch_account_rounded,
                  title: 'Switch to Rider',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  RiderHomeScreen(),
                      ),
                    );
                  },
                )
   else if (riderStatus == 'pending_admin' ||
    riderStatus == 'submitted' ||
    riderStatus == 'pending')
                _MenuTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Check Application Status',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplyAsRiderScreen(),
                      ),
                    );
                  },
                )
              else
                _MenuTile(
                  icon: Icons.app_registration_rounded,
                  title: 'Apply as Rider',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplyAsRiderScreen(),
                      ),
                    );
                  },
                ),
                   const _TileDivider(),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (driverStatus == 'approved')
                _MenuTile(
                  icon: Icons.drive_eta_rounded,
                  title: 'Switch to Driver',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DriverHomeScreen1(),
                      ),
                    );
                  },
                )
              else if (driverStatus == 'pending')
                _MenuTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Application Status',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplyAsDriver(),
                      ),
                    );
                  },
                )
              else if (driverStatus == 'rejected')
                _MenuTile(
                  icon: Icons.app_registration_rounded,
                  title: 'Apply Again as Driver',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplyAsDriver(),
                      ),
                    );
                  },
                )
              else
                _MenuTile(
                  icon: Icons.app_registration_rounded,
                  title: 'Apply as Driver',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplyAsDriver(),
                      ),
                    );
                  },
                ),
              const _TileDivider(),
              _MenuTile(
                icon: Icons.home_work_outlined,
                title: 'Rental Screens',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HostHomeScreen(),
                    ),
                  );
                },
              ),
              const _TileDivider(),
      
     
              const _TileDivider(),
              _MenuTile(
                icon: Icons.key_rounded,
                title: 'My Active Rental',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActiveRentalsListScreen(
                        
                      ),
                    ),
                  );
                },
              ),
         
         /*            _MenuTile(
                icon: Icons.key_rounded,
                title: 'Driver Screens',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverHomeScreen1(
                    
                      ),
                    ),
                  );
                },
              ),
                                _MenuTile(
                icon: Icons.key_rounded,
                title: 'Rider Screens',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiderHomeScreen(
                   
                      ),
                    ),
                  );
                },
              ),
              const _TileDivider(),
              _MenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(),
                    ),
                  );
                },
              ), */
              const _TileDivider(),
              _MenuTile(
                icon: Icons.support_agent_rounded,
                title: 'Help And Support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HelpSupportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.softBg(context),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22,
                color: AppColors.primary,
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.text2(context).withOpacity(0.75),
            ),
          ],
        ),
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
      color: AppColors.secondary.withOpacity(0.45),
    );
  }
}