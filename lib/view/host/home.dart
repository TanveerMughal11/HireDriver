import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/screens/mycarlisting.dart';

import 'package:hire_driver/view/forms/screen/carlistingform.dart';
import 'package:hire_driver/view/host/bottombar.dart';
import 'package:hire_driver/view/host/rentalrequest.dart';

import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/screens/mycarlisting.dart';

import 'package:hire_driver/view/forms/screen/carlistingform.dart';
import 'package:hire_driver/view/host/bottombar.dart';
import 'package:hire_driver/view/host/rentalrequest.dart';
import 'package:hire_driver/view/host/service.dart';

class HostHomeScreen extends StatefulWidget {
  const HostHomeScreen({super.key});

  @override
  State<HostHomeScreen> createState() => _HostHomeScreenState();
}

class _HostHomeScreenState extends State<HostHomeScreen> {
  bool isLoading = true;
  String errorMessage = '';

  String heroText = 'Earn money by listing your car for rent';
  String cars = '0';
  String requests = '0';
  String earned = 'PKR 0';
  String ownerName = '';
  List<dynamic> incomingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  String _formatRentalDate(String? date) {
    if (date == null || date.isEmpty) return '';

    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}-${parsedDate.month}-${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboardData = await RentalOwnerApi.getOwnerDashboard();
      final requestsData = await RentalOwnerApi.getOwnerRequests();

      final dashboard = dashboardData['dashboard'] ?? {};
      final stats = dashboard['stats'] ?? {};
      final earnedData = stats['earned'] ?? {};

      final ownerRequests =
          requestsData['requests'] ??
          requestsData['rentalRequests'] ??
          requestsData['incomingRequests'] ??
          [];

      setState(() {
        heroText = dashboard['heroText'] ?? heroText;

        ownerName = dashboard['owner']?['name'] ?? '';

        cars = '${stats['cars'] ?? 0}';
        requests = '${stats['requests'] ?? 0}';
        earned =
            '${earnedData['currency'] ?? 'PKR'} ${earnedData['amount'] ?? 0}';

        incomingRequests = ownerRequests;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _openRequest(BuildContext context, String bookingId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HostRentalRequestScreen(bookingId: bookingId),
      ),
    );

    if (result == true) {
      _loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const HostBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text1(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboard,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Text(
                      'Rental Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      ownerName.isEmpty
                          ? 'Welcome Host'
                          : 'Welcome, $ownerName',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your rental cars and requests',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.text2(context),
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
                        children: [
                          const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              heroText,
                              style: const TextStyle(
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
                      children: [
                        Expanded(
                          child: _HostStatCard(
                            icon: Icons.car_rental_rounded,
                            value: cars,
                            label: 'Cars',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HostStatCard(
                            icon: Icons.pending_actions_rounded,
                            value: requests,
                            label: 'Requests',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HostStatCard(
                            icon: Icons.payments_rounded,
                            value: earned,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListMyCarFlowScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'List My Car',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Incoming Rental Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (incomingRequests.isEmpty)
                      Text(
                        'No incoming rental requests yet',
                        style: TextStyle(
                          color: AppColors.text2(context),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      ...incomingRequests.map((req) {
                        final renter = req['renter'] ?? {};
                        final listing = req['listing'] ?? {};

                        final renterName = renter['name'] ?? 'Unknown Renter';

                        final carName = listing['carName'] ?? 'Car';

                        final plateNumber = listing['plateNumber'] ?? '';

                        final status = req['status'] ?? 'pending';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RentalRequestCard(
                            renterName: renterName,
                            carName: '$carName • $plateNumber',
                            dates: '',
                            price: '',
                            status: status,
                            onTap: () =>
                                _openRequest(context, req['requestId'] ?? ''),
                          ),
                        );
                      }),
                  ],
                ),
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
  final String? pickupLocation;
  final String? status;
  final VoidCallback onTap;

  const _RentalRequestCard({
    required this.renterName,
    required this.carName,
    required this.dates,
    required this.price,
    required this.onTap,
    this.pickupLocation,
    this.status,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        carName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text2(context),
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

            if (pickupLocation != null && pickupLocation!.isNotEmpty) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      pickupLocation!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.text2(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (status != null && status!.isNotEmpty) ...[
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
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
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.text2(context)),
          ),
        ],
      ),
    );
  }
}
