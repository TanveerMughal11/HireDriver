import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/provider/my_booking.dart';
import 'package:provider/provider.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(rawDate).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _getCarName(Map<String, dynamic> booking) {
    final listing = booking['listing'] ?? {};
    final carInfo = listing['carInfo'] ?? {};
    return '${carInfo['make'] ?? ''} ${carInfo['model'] ?? ''}'.trim();
  }

  String _getCarImage(Map<String, dynamic> booking) {
    final listing = booking['listing'] ?? {};
    final photos = listing['photos'] ?? {};
    return photos['front'] ??
        photos['sideView'] ??
        photos['back'] ??
        photos['interior'] ??
        '';
  }

  String _getLocation(Map<String, dynamic> booking) {
    final listing = booking['listing'] ?? {};
    final carInfo = listing['carInfo'] ?? {};
    return carInfo['locationArea'] ?? 'Unknown location';
  }

  String _getHostName(Map<String, dynamic> booking) {
    final host = booking['host'] ?? {};
    return host['name'] ?? 'Host';
  }

  String _getBookingCode(Map<String, dynamic> booking) {
    return booking['bookingCode'] ?? 'N/A';
  }

  String _getStatus(Map<String, dynamic> booking) {
    return booking['status'] ?? 'unknown';
  }

  String _getPaymentStatus(Map<String, dynamic> booking) {
    return booking['paymentStatus'] ?? 'unknown';
  }

  String _getPickupMethod(Map<String, dynamic> booking) {
    final method = booking['pickupMethod'] ?? '';
    if (method == 'self_pickup') return 'Self Pickup';
    if (method == 'delivery') return 'Delivery';
    return method.toString();
  }

  String _getTotalAmount(Map<String, dynamic> booking) {
    final pricing = booking['pricing'] ?? {};
    return '${pricing['totalAmount'] ?? 0}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyBookingsProvider()..fetchBookings(),
      child: Consumer<MyBookingsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.bg(context),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.secondary),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: AppColors.text1(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'My Bookings',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text1(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : provider.errorMessage.isNotEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        provider.errorMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: provider.fetchBookings,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : provider.bookings.isEmpty
                                ? Center(
                                    child: Text(
                                      'No bookings found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text2(context),
                                      ),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: provider.fetchBookings,
                                    color: AppColors.primary,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        20,
                                      ),
                                      itemCount: provider.bookings.length,
                                      itemBuilder: (context, index) {
                                        final booking =
                                            provider.bookings[index];
                                        final status = _getStatus(booking);

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: AppColors.card(context),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color: AppColors.secondary
                                                  .withOpacity(0.7),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withOpacity(0.04),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(24),
                                                ),
                                                child: _getCarImage(booking)
                                                        .isEmpty
                                                    ? Container(
                                                        height: 180,
                                                        width: double.infinity,
                                                        color:
                                                            AppColors.softBg(
                                                          context,
                                                        ),
                                                        child: const Icon(
                                                          Icons.directions_car,
                                                          size: 56,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      )
                                                    : Image.network(
                                                        _getCarImage(booking),
                                                        height: 180,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, _, _) {
                                                          return Container(
                                                            height: 180,
                                                            width:
                                                                double.infinity,
                                                            color: AppColors
                                                                .softBg(
                                                              context,
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .directions_car,
                                                              size: 56,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            _getCarName(
                                                              booking,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: AppColors
                                                                  .text1(
                                                                context,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                _statusColor(
                                                              status,
                                                            ).withOpacity(
                                                              0.12,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              30,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            status
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              color:
                                                                  _statusColor(
                                                                status,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Booking Code: ${_getBookingCode(booking)}',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.text2(
                                                          context,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 16,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            _getLocation(
                                                              booking,
                                                            ),
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .text2(
                                                                context,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        _InfoChip(
                                                          icon: Icons
                                                              .calendar_today_outlined,
                                                          text:
                                                              '${_formatDate(booking['pickupDate'])} - ${_formatDate(booking['returnDate'])}',
                                                        ),
                                                        _InfoChip(
                                                          icon: Icons
                                                              .person_outline,
                                                          text: _getHostName(
                                                            booking,
                                                          ),
                                                        ),
                                                        _InfoChip(
                                                          icon: Icons
                                                              .local_shipping_outlined,
                                                          text:
                                                              _getPickupMethod(
                                                            booking,
                                                          ),
                                                        ),
                                                        _InfoChip(
                                                          icon: Icons
                                                              .payments_outlined,
                                                          text:
                                                              _getPaymentStatus(
                                                            booking,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 14),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 14,
                                                        vertical: 12,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.softBg(
                                                          context,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Total Amount',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .text1(
                                                                context,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                            'PKR ${_getTotalAmount(booking)}',
                                                            style:
                                                                const TextStyle(
                                                              color: AppColors
                                                                  .primary,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.text2(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}