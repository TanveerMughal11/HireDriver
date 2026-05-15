import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hire_driver/view/driver/service.dart';
import 'package:latlong2/latlong.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/driver/bottombar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class DriverHomeScreen1 extends StatefulWidget {
  const DriverHomeScreen1({super.key});

  @override
  State<DriverHomeScreen1> createState() => _DriverHomeScreen1State();
}

class _DriverHomeScreen1State extends State<DriverHomeScreen1> {
  String userName = "Driver";
  bool isOnline = false;
bool isDashboardLoading = true;
String dashboardError = '';

String bannerText = '0 new hire driver requests waiting for response';
String todayAmount = 'PKR 0';
String completedTripsToday = '0 completed trips today';

String rating = '0.0';
String trips = '0';
String onlineHours = '0h';

List<Map<String, dynamic>> incomingRequests = [];
  @override
  void initState() {
    super.initState();
_loadUser();
_fetchDriverDashboard();
_fetchIncomingRequests();
  }
Future<void> _fetchIncomingRequests() async {
  try {
    final data = await DriverRequestsApi.getIncomingRequests();

    if (data['success'] == true) {
      setState(() {
        bannerText =
            data['bannerText'] ??
            '0 new hire driver requests waiting for response';

        incomingRequests = List<Map<String, dynamic>>.from(
          data['incomingRequests'] ?? [],
        );
      });
    } else {
      throw Exception(
        data['message'] ?? 'Failed to load incoming requests',
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
Future<void> _updateDriverAvailability(bool value) async {
  final oldValue = isOnline;

  setState(() {
    isOnline = value;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

final data = await DriverRequestsApi.updateAvailability(value);

  if (data['success'] == true) {
      setState(() {
        isOnline = data['availability']['isOnline'] ?? value;
      });
    } else {
      throw Exception(data['message'] ?? 'Failed to update availability');
    }
  } catch (e) {
    setState(() {
      isOnline = oldValue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        userName = user['name'] ?? "Driver";
      });
    }
  }
Future<void> _fetchDriverDashboard() async {

  setState(() {
    isDashboardLoading = true;
    dashboardError = '';
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

    final response = await http.get(
      Uri.parse('https://hiredrive-fal0.onrender.com/api/driver-requests/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final dashboard = data['dashboard'];

      setState(() {
        userName = dashboard['driver']?['name'] ?? userName;
        isOnline = dashboard['driver']?['availability']?['isOnline'] ?? false;

        final earnings = dashboard['todayEarnings'];
        todayAmount =
            '${earnings?['currency'] ?? 'PKR'} ${earnings?['amount'] ?? 0}';
        completedTripsToday =
            '${earnings?['completedTripsToday'] ?? 0} completed trips today';

        final statsData = dashboard['stats'];
        rating = '${statsData?['rating'] ?? 0.0}';
        trips = '${statsData?['trips'] ?? 0}';
        onlineHours = '${statsData?['onlineHours'] ?? 0}h';

        bannerText =
            dashboard['pendingSummary']?['bannerText'] ??
                '0 new hire driver requests waiting for response';

        incomingRequests =
            List<Map<String, dynamic>>.from(dashboard['incomingRequests'] ?? []);

        isDashboardLoading = false;
      });
    } else {
      throw Exception(data['message'] ?? 'Failed to load dashboard');
    }
  } catch (e) {
    setState(() {
      isDashboardLoading = false;
      dashboardError = e.toString();
    });
  }
}
void _openRequestDetail(String requestId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DriverRequestDetailScreen(
        hireRequestId: requestId,
      ),
    ),
  );
}

void _openNavigation() {
  if (incomingRequests.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No active navigation request found'),
      ),
    );
    return;
  }

  final requestId = incomingRequests.first['requestId'] ?? '';

  if (requestId.isEmpty) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DriverNavigationScreen(
        hireRequestId: requestId,
      ),
    ),
  );
}
  void _openEarnings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverEarningsScreen(),
      ),
    );
  }

  void _openReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverReviewsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const DriverBottomNavBar(
        currentIndex: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DriverTopHeader(
                userName: userName,
                isOnline: isOnline,
           onToggle: _updateDriverAvailability,
              ),
              const SizedBox(height: 18),
              const _DriverMapCard(),
              const SizedBox(height: 16),
     _TodayEarningsCard(
  amount: todayAmount,
  completedTrips: completedTripsToday,
),
              const SizedBox(height: 16),
        _DriverStatsRow(
  rating: rating,
  trips: trips,
  onlineHours: onlineHours,
),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        bannerText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(
                title: 'Incoming Requests',
                subtitle: 'Accept or review hire driver requests',
              ),
              const SizedBox(height: 12),
if (incomingRequests.isEmpty)
  Text(
    'No incoming requests available',
    style: TextStyle(
      color: AppColors.text2(context),
      fontWeight: FontWeight.w600,
    ),
  )
else
  ...incomingRequests.map((req) {
    final fare = req['fare'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _IncomingRequestCard(
        passengerName: req['title'] ?? req['rider']?['name'] ?? 'Passenger',
        tripType: req['subtitle'] ?? 'Hire Driver',
        pickup: req['pickup']?['address'] ?? '',
        dropoff: req['dropoff']?['address'] ?? '',
        fare: '${fare?['currency'] ?? 'PKR'} ${fare?['amount'] ?? 0}',
        distance: req['tripMeta'] ?? '',
    onTap: () => _openRequestDetail(req['requestId'] ?? ''),
      ),
    );
  }),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Quick Actions',
                subtitle: 'Open useful driver tools fast',
              ),
              const SizedBox(height: 12),
              _QuickActionsGrid(
                onNavigateTap: _openNavigation,
                onEarningsTap: _openEarnings,
                onReviewsTap: _openReviews,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverTopHeader extends StatelessWidget {
  final String userName;
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const _DriverTopHeader({
    required this.userName,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Dashboard',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Icons.radio_button_on : Icons.radio_button_off,
                color: isOnline ? Colors.green : AppColors.text2(context),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isOnline ? Colors.green : AppColors.text2(context),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isOnline,
                onChanged: onToggle,
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverMapCard extends StatelessWidget {
  const _DriverMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(31.5204, 74.3587),
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hiredrive',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(31.5204, 74.3587),
                      width: 60,
                      height: 60,
                      child: const _MapPinBubble(
                        color: AppColors.primary,
                        icon: Icons.directions_car_filled_rounded,
                      ),
                    ),

                    Marker(
                      point: LatLng(31.5100, 74.3500),
                      width: 60,
                      height: 60,
                      child: const _MapPinBubble(
                        color: Colors.green,
                        icon: Icons.person_pin_circle_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Positioned(
              top: 14,
              left: 14,
              child: _MapInfoChip(
                icon: Icons.my_location_rounded,
                text: 'Live Location Active',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DriverMapPainter extends CustomPainter {
  final Color backgroundColor;
  final Color roadColor;
  final Color laneColor;

  _DriverMapPainter({
    required this.backgroundColor,
    required this.roadColor,
    required this.laneColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = roadColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final lane = Paint()
      ..color = laneColor
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lane);
    }

    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lane);
    }

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.25),
      Offset(size.width * 0.90, size.height * 0.25),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.10),
      Offset(size.width * 0.18, size.height * 0.88),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.05),
      Offset(size.width * 0.62, size.height * 0.76),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.68),
      Offset(size.width * 0.82, size.height * 0.68),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant _DriverMapPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.roadColor != roadColor ||
        oldDelegate.laneColor != laneColor;
  }
}

class _MapInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MapInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayEarningsCard extends StatelessWidget {
  final String amount;
  final String completedTrips;

  const _TodayEarningsCard({
    this.amount = 'PKR 0',
    this.completedTrips = '0 completed trips today',
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.darkPrimary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today Earnings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
        Text(
  amount,
  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                completedTrips,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverStatsRow extends StatelessWidget {
  final String rating;
  final String trips;
  final String onlineHours;

  const _DriverStatsRow({
    this.rating = '0.0',
    this.trips = '0',
    this.onlineHours = '0h',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.star_rounded,
            value: rating,
            label: 'Rating',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.route_rounded,
            value: trips,
            label: 'Trips',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.schedule_rounded,
            value: onlineHours,
            label: 'Online',
          ),
        ),
      ],
    );
  }
}
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.text2(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  final String passengerName;
  final String tripType;
  final String pickup;
  final String dropoff;
  final String fare;
  final String distance;
  final VoidCallback onTap;

  const _IncomingRequestCard({
    required this.passengerName,
    required this.tripType,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
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
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.softBg(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    passengerName.isNotEmpty ? passengerName[0] : 'P',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passengerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tripType,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text2(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.softBg(context),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    fare,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _TripRow(
              icon: Icons.my_location_rounded,
              text: pickup,
            ),
            const SizedBox(height: 8),
            _TripRow(
              icon: Icons.location_on_rounded,
              text: dropoff,
            ),
            const SizedBox(height: 8),
            _TripRow(
              icon: Icons.route_rounded,
              text: distance,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.secondary.withOpacity(0.55),
                      ),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onTap,
                    child: const Text(
                      'Review',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TripRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text1(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onNavigateTap;
  final VoidCallback onEarningsTap;
  final VoidCallback onReviewsTap;

  const _QuickActionsGrid({
    required this.onNavigateTap,
    required this.onEarningsTap,
    required this.onReviewsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.navigation_rounded,
            title: 'Navigate',
            onTap: onNavigateTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.payments_rounded,
            title: 'Earnings',
            onTap: onEarningsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.reviews_rounded,
            title: 'Reviews',
            onTap: onReviewsTap,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text1(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text1(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text2(context),
          ),
        ),
      ],
    );
  }
}

class _MapPinBubble extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapPinBubble({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
          transform: Matrix4.rotationZ(0.78),
        ),
      ],
    );
  }
}

class DriverRequestDetailScreen extends StatefulWidget {
  final String hireRequestId;

  const DriverRequestDetailScreen({
    super.key,
    required this.hireRequestId,
  });

  @override
  State<DriverRequestDetailScreen> createState() =>
      _DriverRequestDetailScreenState();
}

class _DriverRequestDetailScreenState extends State<DriverRequestDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? review;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }
Future<void> _declineHireRequest() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

    final response = await http.post(
      Uri.parse(
        'https://hiredrive-fal0.onrender.com/api/driver-requests/${widget.hireRequestId}/decline',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Request declined successfully'),
        ),
      );

      Navigator.pop(context);
    } else {
      throw Exception(data['message'] ?? 'Failed to decline request');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
Future<void> _acceptHireRequest() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

    final response = await http.post(
      Uri.parse(
        'https://hiredrive-fal0.onrender.com/api/driver-requests/${widget.hireRequestId}/accept',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Request accepted successfully'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DriverNavigationScreen(
  hireRequestId: widget.hireRequestId,
),
        ),
      );
    } else {
      throw Exception(data['message'] ?? 'Failed to accept request');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
  Future<void> _fetchReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse(
          'https://hiredrive-fal0.onrender.com/api/driver-requests/${widget.hireRequestId}/review',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          review = Map<String, dynamic>.from(data['review']);
          isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load request review');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      child: Column(
                        children: [
                          _passengerCard(context),
                          const SizedBox(height: 16),
                          _tripDetailCard(context),
                          const SizedBox(height: 16),
                          _fareCard(),
                        ],
                      ),
                    ),
                  ),
                  _bottomButtons(context),
                ],
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Request Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passengerCard(BuildContext context) {
    final rider = review?['rider'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            child: Text(
              rider?['avatarInitial'] ?? 'R',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider?['name'] ?? 'Passenger',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review?['trip']?['serviceLabel'] ?? 'Hire Driver',
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text(
                "${rider?['rating'] ?? 0.0}",
                style: TextStyle(color: AppColors.text1(context)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tripDetailCard(BuildContext context) {
    final trip = review?['trip'];
    final vehicle = trip?['vehicle'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          _row(context, Icons.location_on, "Pickup",
              trip?['pickup']?['address'] ?? ''),
          const SizedBox(height: 10),
          _row(context, Icons.flag, "Dropoff",
              trip?['dropoff']?['address'] ?? ''),
          Divider(height: 20, color: AppColors.secondary.withOpacity(0.45)),
          _row(context, Icons.calendar_today, "Date", trip?['date'] ?? ''),
          const SizedBox(height: 10),
          _row(context, Icons.access_time, "Time", trip?['time'] ?? ''),
          const SizedBox(height: 10),
          _row(
            context,
            Icons.directions_car,
            "Vehicle",
            "${vehicle?['makeModel'] ?? ''} • ${vehicle?['plateNumber'] ?? ''}",
          ),
          const SizedBox(height: 10),
          _row(
            context,
            Icons.route,
            "Distance",
            "${trip?['distanceKm'] ?? 0} km • ${trip?['durationMinutes'] ?? 0} min",
          ),
        ],
      ),
    );
  }

  Widget _fareCard() {
    final fare = review?['fare'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.darkPrimary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Fare Offered",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            "${fare?['currency'] ?? 'PKR'} ${fare?['amount'] ?? 0}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons(BuildContext context) {
    return Container(
      color: AppColors.bg(context),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
             onPressed: _declineHireRequest,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: Colors.red,
                side: BorderSide(
                  color: AppColors.secondary.withOpacity(0.55),
                ),
              ),
              child: const Text("Decline"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
           onPressed: _acceptHireRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Text(
                "Accept",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$title: $value",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text1(context),
            ),
          ),
        ),
      ],
    );
  }
}
class DriverNavigationScreen extends StatefulWidget {
  final String hireRequestId;

  const DriverNavigationScreen({
    super.key,
    required this.hireRequestId,
  });

  @override
  State<DriverNavigationScreen> createState() =>
      _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  bool isLoading = true;

  LatLng? pickupLatLng;
  LatLng? driverCurrentLatLng;
  LatLng? dropoffLatLng;

  List<LatLng> pickupRoutePoints = [];
  List<LatLng> destinationRoutePoints = [];

  String etaMinutes = '0';
  String locationLabel = '';
  String tripMeta = '';
  String actionButton = 'Arrived at Pickup';
  String dropoffAddress = '';

  @override
  void initState() {
    super.initState();
    _fetchNavigation();
  }

  LatLng _parseLatLng(dynamic location, LatLng fallback) {
    final coordinates = location?['coordinates'];

    final lat = location?['lat'] ??
        location?['latitude'] ??
        coordinates?['lat'] ??
        coordinates?['latitude'];

    final lng = location?['lng'] ??
        location?['lon'] ??
        location?['longitude'] ??
        coordinates?['lng'] ??
        coordinates?['lon'] ??
        coordinates?['longitude'];

    if (lat == null || lng == null) return fallback;

    return LatLng(
      (lat as num).toDouble(),
      (lng as num).toDouble(),
    );
  }

  Future<List<LatLng>> _loadRoute(LatLng from, LatLng to) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${from.longitude},${from.latitude};'
      '${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

    return coordinates.map<LatLng>((coord) {
      return LatLng(
        (coord[1] as num).toDouble(),
        (coord[0] as num).toDouble(),
      );
    }).toList();
  }

  Future<LatLng> _getCurrentLatLng() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _fetchNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse(
          'https://hiredrive-fal0.onrender.com/api/driver-requests/${widget.hireRequestId}/navigation',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final nav = data['navigation']['navigation'];
        final trip = data['navigation']['trip'];

        final pickup = trip?['pickup'];
        final dropoff = trip?['dropoff'];

        pickupLatLng = _parseLatLng(
          pickup,
          const LatLng(31.5204, 74.3587),
        );

        dropoffLatLng = _parseLatLng(
          dropoff,
          const LatLng(31.5100, 74.3500),
        );

        dropoffAddress = dropoff?['address'] ?? '';

        driverCurrentLatLng = await _getCurrentLatLng();

        pickupRoutePoints = await _loadRoute(
          driverCurrentLatLng!,
          pickupLatLng!,
        );

        destinationRoutePoints = await _loadRoute(
          pickupLatLng!,
          dropoffLatLng!,
        );

        setState(() {
          etaMinutes = '${nav['etaMinutes'] ?? 0} mins';
          locationLabel =
              pickup?['address'] ?? nav['locationLabel'] ?? '';
          tripMeta = nav['tripMeta'] ?? '';
          actionButton =
              nav['actionButton'] ?? 'Arrived at Pickup';
          isLoading = false;
        });
      } else {
        throw Exception(
          data['message'] ?? 'Failed to load navigation',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _openActiveRide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverRideActiveScreen(
          pickupLatLng: pickupLatLng,
          dropoffLatLng: dropoffLatLng,
          routePoints: destinationRoutePoints,
          dropoffAddress: dropoffAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint =
        driverCurrentLatLng ?? pickupLatLng ?? const LatLng(31.5204, 74.3587);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Driver Navigation',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    decoration: BoxDecoration(
                      color: AppColors.softBg(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.45),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: centerPoint,
                                initialZoom: 16,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.hiredrive',
                                ),
                                if (pickupRoutePoints.isNotEmpty)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: pickupRoutePoints,
                                        strokeWidth: 5,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                MarkerLayer(
                                  markers: [
                                    if (driverCurrentLatLng != null)
                                      Marker(
                                        point: driverCurrentLatLng!,
                                        width: 60,
                                        height: 60,
                                        child: const _MapPinBubble(
                                          color: AppColors.primary,
                                          icon: Icons
                                              .directions_car_filled_rounded,
                                        ),
                                      ),
                                    if (pickupLatLng != null)
                                      Marker(
                                        point: pickupLatLng!,
                                        width: 60,
                                        height: 60,
                                        child: const _MapPinBubble(
                                          color: Colors.green,
                                          icon: Icons
                                              .person_pin_circle_rounded,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.timer_rounded,
                        title: 'ETA',
                        value: etaMinutes,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.my_location_rounded,
                        title: 'Pickup',
                        value: locationLabel,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.route_rounded,
                        title: 'Trip',
                        value: tripMeta,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _openActiveRide(context),
                          child: Text(
                            actionButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class DriverRideActiveScreen extends StatelessWidget {
  final LatLng? pickupLatLng;
  final LatLng? dropoffLatLng;
  final List<LatLng> routePoints;
  final String dropoffAddress;

  const DriverRideActiveScreen({
    super.key,
    this.pickupLatLng,
    this.dropoffLatLng,
    this.routePoints = const [],
    this.dropoffAddress = '',
  });

  void _openComplete(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverCompleteScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint =
        pickupLatLng ?? dropoffLatLng ?? const LatLng(31.5204, 74.3587);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ride In Progress',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              decoration: BoxDecoration(
                color: AppColors.softBg(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.45),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: centerPoint,
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.hiredrive',
                          ),
                          if (routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: routePoints,
                                  strokeWidth: 5,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              if (pickupLatLng != null)
                                Marker(
                                  point: pickupLatLng!,
                                  width: 60,
                                  height: 60,
                                  child: const _MapPinBubble(
                                    color: Colors.green,
                                    icon:
                                        Icons.person_pin_circle_rounded,
                                  ),
                                ),
                              if (dropoffLatLng != null)
                                Marker(
                                  point: dropoffLatLng!,
                                  width: 60,
                                  height: 60,
                                  child: const _MapPinBubble(
                                    color: Colors.orange,
                                    icon: Icons.location_on_rounded,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 14,
                    left: 14,
                    child: _MapInfoChip(
                      icon: Icons.route_rounded,
                      text: 'Destination route active',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const _DetailRow(
                  icon: Icons.timer_rounded,
                  title: 'Trip Timer',
                  value: '12 mins',
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.location_on_rounded,
                  title: 'Destination',
                  value: dropoffAddress.isNotEmpty
                      ? dropoffAddress
                      : dropoffLatLng == null
                          ? 'Destination'
                          : '${dropoffLatLng!.latitude.toStringAsFixed(5)}, ${dropoffLatLng!.longitude.toStringAsFixed(5)}',
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(
                      child: _ActionMiniButton(
                        icon: Icons.chat_rounded,
                        title: 'Chat',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ActionMiniButton(
                        icon: Icons.sos_rounded,
                        title: 'SOS',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _openComplete(context),
                    child: const Text(
                      'End Ride',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class DriverCompleteScreen extends StatelessWidget {
  const DriverCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Trip Completed',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 78,
                  width: 78,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Trip Completed",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Passenger reached destination successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.text2(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const _DetailRow(
                  icon: Icons.payments_rounded,
                  title: 'Fare Earned',
                  value: 'Rs. 1,250',
                ),
                const SizedBox(height: 12),
                const _DetailRow(
                  icon: Icons.timer_rounded,
                  title: 'Trip Duration',
                  value: '18 mins',
                ),
                const SizedBox(height: 12),
                const _DetailRow(
                  icon: Icons.route_rounded,
                  title: 'Distance',
                  value: '7.2 km',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverHomeScreen1(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const DriverBottomNavBar(
        currentIndex: 1,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Driver Earnings',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            const _TodayEarningsCard(),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.calendar_today_rounded,
                    value: 'Rs. 18k',
                    label: 'Weekly',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.date_range_rounded,
                    value: 'Rs. 62k',
                    label: 'Monthly',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _PeriodChip(label: 'Daily', selected: true),
                  SizedBox(width: 8),
                  _PeriodChip(label: 'Weekly', selected: false),
                  SizedBox(width: 8),
                  _PeriodChip(label: 'Monthly', selected: false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _BarItem(label: 'Mon', height: 40),
                      _BarItem(label: 'Tue', height: 65),
                      _BarItem(label: 'Wed', height: 52),
                      _BarItem(label: 'Thu', height: 78),
                      _BarItem(label: 'Fri', height: 58),
                      _BarItem(label: 'Sat', height: 90),
                      _BarItem(label: 'Sun', height: 48),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Withdraw to Wallet',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _HistoryItem(
              title: 'Johar Town → Gulberg',
              subtitle: 'Today • Ride completed',
              amount: 'Rs. 1,250',
            ),
            const SizedBox(height: 10),
            const _HistoryItem(
              title: 'DHA Phase 6 → Model Town',
              subtitle: 'Today • Hire completed',
              amount: 'Rs. 2,100',
            ),
            const SizedBox(height: 10),
            const _HistoryItem(
              title: 'Airport → Cantt',
              subtitle: 'Yesterday • Ride completed',
              amount: 'Rs. 1,900',
            ),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double height;

  const _BarItem({
    required this.label,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 18,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.text2(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _PeriodChip({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.text1(context),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class DriverReviewsScreen extends StatelessWidget {
  const DriverReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const DriverBottomNavBar(
        currentIndex: 2,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Driver Reviews',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MiniStatCard(
              icon: Icons.star_rounded,
              value: '4.9',
              label: 'Average Rating',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _ReviewFilterChip(label: 'All', selected: true),
                _ReviewFilterChip(label: '5★', selected: false),
                _ReviewFilterChip(label: '4★', selected: false),
                _ReviewFilterChip(label: '3★+', selected: false),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softBg(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips from Top Rated Drivers',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Arrive early\n• Keep communication polite\n• Confirm pickup clearly\n• Drive smoothly and safely',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.text2(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _ReviewCard(
              name: 'Ali Raza',
              review: 'Very polite and reached on time. Smooth ride.',
            ),
            const SizedBox(height: 10),
            const _ReviewCard(
              name: 'Usman',
              review: 'Professional driver and good behaviour.',
            ),
            const SizedBox(height: 10),
            const _ReviewCard(
              name: 'Sara',
              review: 'Clean driving and easy communication.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewFilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _ReviewFilterChip({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.text1(context),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text2(context),
          ),
        ),
      ],
    );
  }
}

class _ActionMiniButton extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ActionMiniButton({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.softBg(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String review;

  const _ReviewCard({
    required this.name,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: TextStyle(
              color: AppColors.text2(context),
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}