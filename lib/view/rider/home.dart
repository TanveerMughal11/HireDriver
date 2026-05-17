import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hire_driver/view/rider/service.dart';
import 'package:latlong2/latlong.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/rider/bottombar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  String userName = "Rider";
  bool isOnline = false;
  bool isLoading = true;
  Timer? _refreshTimer;

  List<dynamic> incomingRequests = [];

  String bannerText = '';

  String earnings = 'PKR 0';
  String completedTrips = '0';

  String rating = '0';
  String trips = '0';
  String onlineHours = '0';
  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _loadDashboard(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateAvailability(bool value) async {
    final oldValue = isOnline;

    setState(() {
      isOnline = value;
    });

    try {
      final data = await RiderRequestsApi.updateAvailability(
        isOnline: value,
        liveLocationActive: value,
      );

      final availability = data['availability'] ?? data;

      setState(() {
        isOnline = availability['isOnline'] ?? value;
      });
    } catch (e) {
      setState(() {
        isOnline = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _loadDashboard({bool silent = false}) async {
    try {
      final data = await RiderRequestsApi.getDashboard();
      final incomingData = await RiderRequestsApi.getIncomingRequests();

      final dashboard = data['dashboard'] ?? {};

      final rider = dashboard['rider'] ?? {};
      final availability = rider['availability'] ?? {};

      final todayEarnings = dashboard['todayEarnings'] ?? {};
      final stats = dashboard['stats'] ?? {};
      final pendingSummary = dashboard['pendingSummary'] ?? {};

      if (!mounted) return;

      setState(() {
        userName = rider['name'] ?? 'Rider';

        isOnline = availability['isOnline'] ?? false;

        earnings =
            '${todayEarnings['currency'] ?? 'PKR'} ${todayEarnings['amount'] ?? 0}';

        completedTrips = '${todayEarnings['completedTripsToday'] ?? 0}';

        rating = '${stats['rating'] ?? 0}';
        trips = '${stats['trips'] ?? 0}';
        onlineHours = '${stats['onlineHours'] ?? 0}h';

        bannerText =
            incomingData['bannerText'] ?? pendingSummary['bannerText'] ?? '';

        incomingRequests =
            incomingData['incomingRequests'] ??
            dashboard['incomingRequests'] ??
            [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        userName = user['name'] ?? "Rider";
      });
    }
  }

  void _openRequestDetail(String rideRequestId) {
    if (rideRequestId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid ride request. Please refresh dashboard.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverRequestDetailScreen(rideRequestId: rideRequestId),
      ),
    ).then((value) {
      if (value == true && mounted) {
        _loadDashboard(silent: true);
      }
    });
  }

  Future<void> _declineRequestFromCard(String rideRequestId) async {
    try {
      final data = await RiderRequestsApi.declineRideRequest(
        rideRequestId: rideRequestId,
      );

      if (!mounted) return;

      setState(() {
        incomingRequests.removeWhere((req) {
          final id =
              req['requestId']?.toString() ?? req['_id']?.toString() ?? '';
          return id == rideRequestId;
        });
        bannerText = incomingRequests.isNotEmpty
            ? '${incomingRequests.length} new ride requests waiting for response'
            : 'No pending requests right now';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Ride request declined successfully',
          ),
        ),
      );

      _loadDashboard(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _openNavigation() {
    final firstRequest = incomingRequests.isNotEmpty
        ? Map<String, dynamic>.from(incomingRequests.first as Map)
        : <String, dynamic>{};
    final rideRequestId =
        (firstRequest['requestId'] ?? firstRequest['id'] ?? '').toString();

    if (rideRequestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active request available for navigation'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverNavigationScreen(rideRequestId: rideRequestId),
      ),
    );
  }

  void _openEarnings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RiderEarningsScreen()),
    );
  }

  void _openReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverReviewsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const RiderBottomNavBar(currentIndex: 0),
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
                onToggle: _updateAvailability,
              ),

              const SizedBox(height: 16),
              _TodayEarningsCard(
                earnings: earnings,
                completedTrips: completedTrips,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                subtitle: 'Accept or review nearby book ride requests',
              ),
              const SizedBox(height: 12),
              Column(
                children: incomingRequests.map((req) {
                  final user = req['user'] ?? {};
                  final pickup = req['pickup'] ?? {};
                  final dropoff = req['dropoff'] ?? {};
                  final fare = req['fare'] ?? {};
                  final requestId =
                      req['requestId']?.toString() ??
                      req['_id']?.toString() ??
                      '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _IncomingRequestCard(
                      passengerName: user['name'] ?? '',
                      tripType: req['subtitle'] ?? '',
                      pickup: pickup['address'] ?? '',
                      dropoff: dropoff['address'] ?? '',
                      fare:
                          '${fare['currency'] ?? 'PKR'} ${fare['amount'] ?? 0}',
                      distance: req['tripMeta'] ?? '',
                      onTap: requestId.isEmpty
                          ? null
                          : () => _openRequestDetail(requestId),
                      onDecline: requestId.isEmpty
                          ? null
                          : () => _declineRequestFromCard(requestId),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Quick Actions',
                subtitle: 'Open useful rider tools fast',
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
                'Rider Dashboard',
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
                activeThumbColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverMapCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _DriverMapCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final trip = review['trip'];

    final pickupLat = (trip['pickup']['coordinates']['lat'] as num).toDouble();
    final pickupLng = (trip['pickup']['coordinates']['lng'] as num).toDouble();

    final dropLat = (trip['dropoff']['coordinates']['lat'] as num).toDouble();
    final dropLng = (trip['dropoff']['coordinates']['lng'] as num).toDouble();

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(pickupLat, pickupLng),
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hire_driver',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(pickupLat, pickupLng),
                        LatLng(dropLat, dropLng),
                      ],
                      strokeWidth: 5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(pickupLat, pickupLng),
                      width: 80,
                      height: 80,
                      child: const _GlowPickupMarker(),
                    ),
                    Marker(
                      point: LatLng(dropLat, dropLng),
                      width: 60,
                      height: 60,
                      child: const _MapPinBubble(
                        color: Colors.green,
                        icon: Icons.location_on_rounded,
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
                text: 'Live Request Route',
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

  const _MapInfoChip({required this.icon, required this.text});

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
  final String earnings;
  final String completedTrips;

  const _TodayEarningsCard({
    required this.earnings,
    required this.completedTrips,
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
                  earnings,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '$completedTrips completed trips today',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
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
    required this.rating,
    required this.trips,
    required this.onlineHours,
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
        SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.route_rounded,
            value: trips,
            label: 'Trips',
          ),
        ),
        SizedBox(width: 12),
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
  final VoidCallback? onTap;
  final VoidCallback? onDecline;

  const _IncomingRequestCard({
    required this.passengerName,
    required this.tripType,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.onTap,
    this.onDecline,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
            _TripRow(icon: Icons.my_location_rounded, text: pickup),
            const SizedBox(height: 8),
            _TripRow(icon: Icons.location_on_rounded, text: dropoff),
            const SizedBox(height: 8),
            _TripRow(icon: Icons.route_rounded, text: distance),
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
                    onPressed: onDecline,
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

  const _TripRow({required this.icon, required this.text});

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

  const _SectionTitle({required this.title, required this.subtitle});

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

  const _MapPinBubble({required this.color, required this.icon});

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
  final String rideRequestId;

  const DriverRequestDetailScreen({super.key, required this.rideRequestId});

  @override
  State<DriverRequestDetailScreen> createState() =>
      _DriverRequestDetailScreenState();
}

class _DriverRequestDetailScreenState extends State<DriverRequestDetailScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? review;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _declineRideRequest() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await RiderRequestsApi.declineRideRequest(
        rideRequestId: widget.rideRequestId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Ride request declined successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _acceptRideRequest() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await RiderRequestsApi.acceptRideRequest(
        rideRequestId: widget.rideRequestId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Ride request accepted successfully',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DriverNavigationScreen(navigationData: data['navigation']),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _fetchReview() async {
    try {
      final data = await RiderRequestsApi.getRideRequestReview(
        rideRequestId: widget.rideRequestId,
      );

      setState(() {
        review = data['review'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _openNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DriverNavigationScreen(rideRequestId: widget.rideRequestId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.bg(context),
          title: const Text('Request Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.bg(context),
          title: const Text('Request Details'),
        ),
        body: Center(child: Text(error!)),
      );
    }

    final user = review!['user'];
    final trip = review!['trip'];
    final fare = review!['fare'];

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Request Details',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DriverMapCard(review: review!),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softBg(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.45),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user['avatarInitial'] ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user['name'] ?? 'Passenger',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                    ),
                    Text(
                      '${user['rating'] ?? 0} ★',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _DetailCard(
                title: 'Trip Details',
                children: [
                  _DetailRow(
                    icon: Icons.my_location_rounded,
                    title: 'Pickup',
                    value: trip['pickup']['address'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    title: 'Drop',
                    value: trip['dropoff']['address'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.two_wheeler_rounded,
                    title: 'Vehicle',
                    value: trip['vehicleType'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.route_rounded,
                    title: 'Distance',
                    value:
                        '${trip['distanceKm']} km • ${trip['durationMinutes']} min',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.payments_rounded,
                    title: 'Fare',
                    value: '${fare['currency']} ${fare['amount']}',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (review?['actions']?['canDecline'] == true)
                          ? _declineRideRequest
                          : null,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: (review?['actions']?['canAccept'] == true)
                          ? _acceptRideRequest
                          : null,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverNavigationScreen extends StatefulWidget {
  final String? rideRequestId;
  final Map<String, dynamic>? navigationData;

  const DriverNavigationScreen({
    super.key,
    this.rideRequestId,
    this.navigationData,
  });

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  final MapController mapController = MapController();

  StreamSubscription<Position>? positionStream;

  LatLng? driverPoint;
  LatLng? pickupPoint;
  LatLng? dropoffPoint;

  List<LatLng> routePoints = [];
  List<LatLng> destinationRoutePoints = [];

  Map<String, dynamic>? apiNavigationData;

  bool isNavigationLoading = false;
  bool isRouteLoading = true;

  String dropoffAddress = '';

  @override
  void initState() {
    super.initState();

    if (widget.navigationData != null) {
      apiNavigationData = widget.navigationData;
      _setPickupLocation();
      _startLiveLocation();
    } else if (widget.rideRequestId != null &&
        widget.rideRequestId!.isNotEmpty) {
      _loadNavigation();
    } else {
      _setPickupLocation();
      _startLiveLocation();
    }
  }

  Future<void> _loadNavigation() async {
    try {
      setState(() {
        isNavigationLoading = true;
      });

      final data = await RiderRequestsApi.getRideNavigation(
        rideRequestId: widget.rideRequestId!,
      );

      apiNavigationData = data['navigation'];

      setState(() {
        isNavigationLoading = false;
      });

      _setPickupLocation();
      _startLiveLocation();
    } catch (e) {
      setState(() {
        isNavigationLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _setPickupLocation() {
    final trip = apiNavigationData?['trip'];

    final pickup = trip?['pickup'];
    final dropoff = trip?['dropoff'];

    final pickupCoordinates = pickup?['coordinates'];
    final dropoffCoordinates = dropoff?['coordinates'];

    final pickupLat =
        (pickupCoordinates?['lat'] as num?)?.toDouble() ??
        (pickup?['lat'] as num?)?.toDouble() ??
        (pickup?['latitude'] as num?)?.toDouble() ??
        31.4719997;

    final pickupLng =
        (pickupCoordinates?['lng'] as num?)?.toDouble() ??
        (pickupCoordinates?['lon'] as num?)?.toDouble() ??
        (pickupCoordinates?['longitude'] as num?)?.toDouble() ??
        (pickup?['lng'] as num?)?.toDouble() ??
        (pickup?['lon'] as num?)?.toDouble() ??
        (pickup?['longitude'] as num?)?.toDouble() ??
        74.36066;

    final dropLat =
        (dropoffCoordinates?['lat'] as num?)?.toDouble() ??
        (dropoff?['lat'] as num?)?.toDouble() ??
        (dropoff?['latitude'] as num?)?.toDouble() ??
        31.5100;

    final dropLng =
        (dropoffCoordinates?['lng'] as num?)?.toDouble() ??
        (dropoffCoordinates?['lon'] as num?)?.toDouble() ??
        (dropoffCoordinates?['longitude'] as num?)?.toDouble() ??
        (dropoff?['lng'] as num?)?.toDouble() ??
        (dropoff?['lon'] as num?)?.toDouble() ??
        (dropoff?['longitude'] as num?)?.toDouble() ??
        74.3440;

    pickupPoint = LatLng(pickupLat, pickupLng);
    dropoffPoint = LatLng(dropLat, dropLng);
    dropoffAddress = dropoff?['address'] ?? '';
  }

  Future<void> _startLiveLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required')),
      );
      return;
    }

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 3,
          ),
        ).listen((position) async {
          final newDriverPoint = LatLng(position.latitude, position.longitude);

          setState(() {
            driverPoint = newDriverPoint;
          });

          if (pickupPoint != null) {
            await _fetchRoute(from: newDriverPoint, to: pickupPoint!);
          }

          mapController.move(newDriverPoint, 16.5);
        });
  }

  Future<void> _fetchRoute({required LatLng from, required LatLng to}) async {
    try {
      final points = await _loadRoutePoints(from: from, to: to);

      if (!mounted) return;

      setState(() {
        routePoints = points;
        isRouteLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isRouteLoading = false;
      });
    }
  }

  Future<List<LatLng>> _loadRoutePoints({
    required LatLng from,
    required LatLng to,
  }) async {
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

    return coordinates.map<LatLng>((item) {
      return LatLng((item[1] as num).toDouble(), (item[0] as num).toDouble());
    }).toList();
  }

  void _openActiveRide(BuildContext context) async {
    if (pickupPoint != null && dropoffPoint != null) {
      destinationRoutePoints = await _loadRoutePoints(
        from: pickupPoint!,
        to: dropoffPoint!,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverRideActiveScreen(
          pickupPoint: pickupPoint,
          dropoffPoint: dropoffPoint,
          routePoints: destinationRoutePoints,
          dropoffAddress: dropoffAddress,
        ),
      ),
    );
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = apiNavigationData?['navigation'];
    final pickup = apiNavigationData?['map']?['pickupMarker'];

    final eta = nav?['etaMinutes'] ?? 8;
    final locationLabel =
        nav?['locationLabel'] ?? pickup?['address'] ?? 'Pickup';
    final tripMeta = nav?['tripMeta'] ?? '0.6 km • 5 min';
    final actionButton = nav?['actionButton'] ?? 'Arrived at Pickup';

    final centerPoint =
        driverPoint ?? pickupPoint ?? const LatLng(31.4719997, 74.36066);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rider Navigation',
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: centerPoint,
                        initialZoom: 15.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.hire_driver',
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
                            if (driverPoint != null)
                              Marker(
                                point: driverPoint!,
                                width: 70,
                                height: 70,
                                child: const _MapPinBubble(
                                  color: AppColors.primary,
                                  icon: Icons.two_wheeler_rounded,
                                ),
                              ),
                            if (pickupPoint != null)
                              Marker(
                                point: pickupPoint!,
                                width: 70,
                                height: 70,
                                child: const _GlowPickupMarker(),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: _MapInfoChip(
                        icon: Icons.navigation_rounded,
                        text: isRouteLoading
                            ? 'Finding route...'
                            : 'ETA $eta mins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.timer_rounded,
                  title: 'ETA',
                  value: '$eta mins',
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.my_location_rounded,
                  title: 'Pickup',
                  value: pickup?['address'] ?? locationLabel,
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _openActiveRide(context),
                    child: Text(
                      actionButton,
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
  final LatLng? pickupPoint;
  final LatLng? dropoffPoint;
  final List<LatLng> routePoints;
  final String dropoffAddress;

  const DriverRideActiveScreen({
    super.key,
    required this.pickupPoint,
    required this.dropoffPoint,
    required this.routePoints,
    this.dropoffAddress = '',
  });

  void _openComplete(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverCompleteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint =
        pickupPoint ?? dropoffPoint ?? const LatLng(31.5204, 74.3587);

    final destinationText = dropoffAddress.isNotEmpty
        ? dropoffAddress
        : dropoffPoint == null
        ? 'Destination'
        : '${dropoffPoint!.latitude.toStringAsFixed(5)}, ${dropoffPoint!.longitude.toStringAsFixed(5)}';

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: centerPoint,
                        initialZoom: 14.8,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.hire_driver',
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
                            if (pickupPoint != null)
                              Marker(
                                point: pickupPoint!,
                                width: 70,
                                height: 70,
                                child: const _GlowPickupMarker(),
                              ),

                            if (dropoffPoint != null)
                              Marker(
                                point: dropoffPoint!,
                                width: 70,
                                height: 70,
                                child: const _MapPinBubble(
                                  color: Colors.green,
                                  icon: Icons.location_on_rounded,
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
                        icon: Icons.route_rounded,
                        text: 'Destination route active',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
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
              children: [
                const _DetailRow(
                  icon: Icons.timer_rounded,
                  title: 'Trip Timer',
                  value: '12 mins',
                ),

                const SizedBox(height: 12),

                _DetailRow(
                  icon: Icons.location_on_rounded,
                  title: 'Dropoff',
                  value: destinationText,
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
                          builder: (_) => const RiderHomeScreen(),
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

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const RiderBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rider Earnings',
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
            const _TodayEarningsCard(earnings: 'PKR 0', completedTrips: '0'),
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
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.45),
                ),
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

  const _BarItem({required this.label, required this.height});

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

  const _PeriodChip({required this.label, required this.selected});

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
      bottomNavigationBar: const RiderBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rider Reviews',
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
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips from Top Rated Rider',
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
              review: 'Professional Rider and good behaviour.',
            ),
            const SizedBox(height: 10),
            const _ReviewCard(
              name: 'Sara',
              review: 'Clean Riding and easy communication.',
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

  const _ReviewFilterChip({required this.label, required this.selected});

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

  const _DetailCard({required this.title, required this.children});

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

  const _ActionMiniButton({required this.icon, required this.title});

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
            child: const Icon(Icons.payments_rounded, color: AppColors.primary),
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

  const _ReviewCard({required this.name, required this.review});

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

class _GlowPickupMarker extends StatefulWidget {
  const _GlowPickupMarker();

  @override
  State<_GlowPickupMarker> createState() => _GlowPickupMarkerState();
}

class _GlowPickupMarkerState extends State<_GlowPickupMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0.9,
      end: 1.12,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 22,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}
