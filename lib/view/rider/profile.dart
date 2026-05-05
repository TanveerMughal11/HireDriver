import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/rider/bottombar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  String userName = "Rider";
  String email = "Rider@email.com";
  String phone = "0300-0000000";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        userName = user['name'] ?? "Rider";
        email = user['email'] ?? "rider@email.com";
        phone = user['phone'] ?? "0300-0000000";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const RiderBottomNavBar(
        currentIndex: 3,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Rider Profile",
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.text1(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.darkPrimary],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "D",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Approved Rider",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "CNIC Verified",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: _ProfileStatCard(
                    icon: Icons.star_rounded,
                    value: "4.9",
                    label: "Rating",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ProfileStatCard(
                    icon: Icons.route_rounded,
                    value: "128",
                    label: "Trips",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ProfileStatCard(
                    icon: Icons.payments_rounded,
                    value: "62k",
                    label: "Earnings",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ProfileSection(
              title: "Personal Information",
              children: [
                _ProfileTile(
                  icon: Icons.person_rounded,
                  title: "Full Name",
                  value: userName,
                ),
                _ProfileTile(
                  icon: Icons.email_rounded,
                  title: "Email",
                  value: email,
                ),
                _ProfileTile(
                  icon: Icons.phone_rounded,
                  title: "Phone",
                  value: phone,
                ),
                const _ProfileTile(
                  icon: Icons.badge_rounded,
                  title: "CNIC",
                  value: "35202-*******-*",
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _ProfileSection(
              title: "Driving License",
              children: [
                _ProfileTile(
                  icon: Icons.credit_card_rounded,
                  title: "License Number",
                  value: "LHR-DR-2026-001",
                ),
                _ProfileTile(
                  icon: Icons.date_range_rounded,
                  title: "Expiry Date",
                  value: "12 Dec 2028",
                ),
                _ProfileTile(
                  icon: Icons.verified_rounded,
                  title: "License Status",
                  value: "Verified",
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _ProfileSection(
              title: "Vehicle Information",
              children: [
                _ProfileTile(
                  icon: Icons.directions_car_rounded,
                  title: "Vehicle",
                  value: "Toyota Corolla",
                ),
                _ProfileTile(
                  icon: Icons.color_lens_rounded,
                  title: "Color",
                  value: "White",
                ),
                _ProfileTile(
                  icon: Icons.confirmation_number_rounded,
                  title: "Plate Number",
                  value: "LEA-1234",
                ),
                _ProfileTile(
                  icon: Icons.car_rental_rounded,
                  title: "Service",
                  value: "Book a Ride",
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _ProfileSection(
              title: "Rider Services",
              children: [
                _ProfileTile(
                  icon: Icons.check_circle_rounded,
                  title: "Hire a Driver",
                  value: "Enabled",
                ),
                _ProfileTile(
                  icon: Icons.check_circle_rounded,
                  title: "Book a Ride",
                  value: "Enabled",
                ),
                _ProfileTile(
                  icon: Icons.schedule_rounded,
                  title: "Availability",
                  value: "Online / Offline Toggle",
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
              onPressed: () {},
              icon: const Icon(Icons.edit_rounded),
              label: const Text(
                "Edit Profile",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card(context),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.switch_account_rounded),
              label: const Text(
                "Switch to Passenger",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.softBg(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text1(context),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text2(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.text2(context),
            ),
          ),
        ],
      ),
    );
  }
}