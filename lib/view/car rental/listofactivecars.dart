import 'package:flutter/material.dart';
import 'package:hire_driver/service/rental_service.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/activerental.dart';

class ActiveRentalsListScreen extends StatefulWidget {
  const ActiveRentalsListScreen({super.key});

  @override
  State<ActiveRentalsListScreen> createState() =>
      _ActiveRentalsListScreenState();
}

class _ActiveRentalsListScreenState extends State<ActiveRentalsListScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _activeBookings = [];

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<dynamic> _extractRentals(dynamic data) {
    final root = _asMap(data);
    final nestedData = _asMap(root['data']);

    final candidates = [
      root['activeRentals'],
      root['activeBookings'],
      root['rentals'],
      root['bookings'],
      nestedData['activeRentals'],
      nestedData['activeBookings'],
      nestedData['rentals'],
      nestedData['bookings'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) return candidate;
    }

    if (data is List) return data;
    return [];
  }

  String _bookingId(Map<String, dynamic> booking) {
    return booking['id']?.toString() ??
        booking['_id']?.toString() ??
        booking['bookingId']?.toString() ??
        booking['rentalId']?.toString() ??
        '';
  }

  @override
  void initState() {
    super.initState();
    _fetchActiveRentals();
  }

  Future<void> _fetchActiveRentals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await RentalService.getActiveRentals();

    if (!mounted) return;

    if (response['success'] == true) {
      final rentals = _extractRentals(response['data']);
      setState(() {
        _activeBookings = rentals
            .map((e) => _asMap(e))
            .where((e) => e.isNotEmpty)
            .toList();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _errorMessage =
          response['message']?.toString() ?? 'Failed to load active rentals';
      _isLoading = false;
    });
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        title: Text(
          'Active Rentals',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text1(context)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text1(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchActiveRentals,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _activeBookings.isEmpty
          ? Center(
              child: Text(
                'No active rentals right now',
                style: TextStyle(
                  color: AppColors.text2(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchActiveRentals,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _activeBookings.length,
                itemBuilder: (context, index) {
                  final booking = _activeBookings[index];

                  final listing = _asMap(
                    booking['listing'] ?? booking['car'] ?? booking['vehicle'],
                  );
                  final carInfo = _asMap(
                    listing['carInfo'] ?? booking['carInfo'] ?? listing,
                  );

                  final carName =
                      '${carInfo['make'] ?? carInfo['brand'] ?? ''} ${carInfo['model'] ?? carInfo['name'] ?? ''}'
                          .trim();

                  final returnDate = _formatDate(
                    (booking['returnDate'] ??
                            booking['endDate'] ??
                            booking['dropoffDate'] ??
                            '')
                        .toString(),
                  );

                  final pricing = _asMap(booking['pricing']);
                  final amount =
                      pricing['totalAmount'] ??
                      booking['totalAmount'] ??
                      booking['totalPrice'] ??
                      0;

                  final host = _asMap(booking['host'] ?? booking['owner']);
                  final hostName =
                      host['name']?.toString() ??
                      host['fullName']?.toString() ??
                      'Host';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        _openActiveRental(booking);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 68,
                              width: 68,
                              decoration: BoxDecoration(
                                color: AppColors.softBg(context),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                color: AppColors.primary,
                                size: 34,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    carName.isEmpty ? 'Rental Car' : carName,
                                    style: TextStyle(
                                      color: AppColors.text1(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Host: $hostName',
                                    style: TextStyle(
                                      color: AppColors.text2(context),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Return: $returnDate',
                                    style: TextStyle(
                                      color: AppColors.text2(context),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. $amount',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _openActiveRental(Map<String, dynamic> booking) async {
    final bookingId = _bookingId(booking);
    var detailBooking = booking;

    if (bookingId.isNotEmpty) {
      final response = await RentalService.getActiveRentalDetails(bookingId);
      if (!mounted) return;

      if (response['success'] == true) {
        final data = _asMap(response['data']);
        detailBooking = _asMap(
          data['activeRental'] ??
              data['rental'] ??
              data['booking'] ??
              data['data'] ??
              data,
        );
        if (detailBooking.isEmpty) detailBooking = booking;
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveRentalScreen(booking: detailBooking),
      ),
    ).then((_) {
      if (mounted) _fetchActiveRentals();
    });
  }
}
