import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/host/bottombar.dart';

import 'package:hire_driver/view/host/service.dart';

class HostListingsScreen extends StatefulWidget {
  const HostListingsScreen({super.key});

  @override
  State<HostListingsScreen> createState() => _HostListingsScreenState();
}

class _HostListingsScreenState extends State<HostListingsScreen> {
  bool isLoading = true;
  String? error;

  Map<String, dynamic>? dashboard;
  List incomingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dashboardResponse = await RentalOwnerApi.getOwnerDashboard();
      final requestsResponse = await RentalOwnerApi.getOwnerRequests();

      setState(() {
        dashboard = dashboardResponse['dashboard'];
        incomingRequests = requestsResponse['incomingRequests'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  String _earnedText() {
    final earned = dashboard?['stats']?['earned'];
    final currency = earned?['currency'] ?? 'PKR';
    final amount = earned?['amount'] ?? 0;
    return '$currency $amount';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const HostBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Listings',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                error = null;
              });
              _loadData();
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final ownerName = dashboard?['owner']?['name'] ?? 'Host';
    final heroText =
        dashboard?['heroText'] ?? 'Earn money by listing your car for rent';

    final cars = dashboard?['stats']?['cars'] ?? 0;
    final requests = dashboard?['stats']?['requests'] ?? incomingRequests.length;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text(
          'Welcome, $ownerName',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.text1(context),
          ),
        ),
        const SizedBox(height: 6),
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
                value: '$cars',
                label: 'Cars',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HostStatCard(
                icon: Icons.pending_actions_rounded,
                value: '$requests',
                label: 'Requests',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HostStatCard(
                icon: Icons.payments_rounded,
                value: _earnedText(),
                label: 'Earned',
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

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
          _EmptyRequestsCard()
        else
          ...incomingRequests.map((request) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RentalRequestCard(
                renterName: request['renter']?['name'] ??
                    request['user']?['name'] ??
                    'Renter',
                carName: request['car']?['name'] ??
                    request['listing']?['carName'] ??
                    request['carName'] ??
                    'Rental Car',
                dates: _formatDates(request),
                price: _formatPrice(request),
                onTap: () {},
              ),
            );
          }),
      ],
    );
  }

  String _formatDates(dynamic request) {
    final start = request['startDate'] ?? request['pickupDate'] ?? '';
    final end = request['endDate'] ?? request['returnDate'] ?? '';

    if (start.toString().isEmpty && end.toString().isEmpty) {
      return 'Dates not available';
    }

    return '$start - $end';
  }

  String _formatPrice(dynamic request) {
    final amount = request['amount'] ??
        request['totalAmount'] ??
        request['price']?['amount'] ??
        0;

    final currency = request['currency'] ??
        request['price']?['currency'] ??
        'PKR';

    return '$currency $amount';
  }
}

class _EmptyRequestsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 42,
            color: AppColors.text2(context),
          ),
          const SizedBox(height: 10),
          Text(
            'No incoming rental requests',
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New rental requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text2(context),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalRequestCard extends StatelessWidget {
  final String renterName;
  final String carName;
  final String dates;
  final String price;
  final VoidCallback onTap;

  const _RentalRequestCard({
    required this.renterName,
    required this.carName,
    required this.dates,
    required this.price,
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
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.45),
          ),
        ),
        child: Row(
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
                    '$carName • $dates',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text2(context),
                      fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.text2(context),
            ),
          ),
        ],
      ),
    );
  }
}