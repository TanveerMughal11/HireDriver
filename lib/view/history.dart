import 'package:flutter/material.dart';
import 'package:hire_driver/customwidgets/bottombar.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';
import 'package:hire_driver/utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'All';

  bool isLoading = true;
  String errorMessage = '';
  List<_TripItem> trips = [];

  @override
  void initState() {
    super.initState();
    _loadMyRideRequests();
  }

  Future<void> _loadMyRideRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final rideResult = await RideApiService.getMyRideRequests();
    final hireResult = await RideApiService.getMyHireRequests();

    if (!mounted) return;

    final List<_TripItem> combinedTrips = [];

    if (rideResult['success'] == true) {
      final rides = rideResult['data']['rides'];

      if (rides is List) {
        combinedTrips.addAll(
          rides.map((e) => _TripItem.fromRide(Map<String, dynamic>.from(e))),
        );
      }
    }

    if (hireResult['success'] == true) {
      final hires = hireResult['data']['hireRequests'];

      if (hires is List) {
        combinedTrips.addAll(
          hires.map((e) => _TripItem.fromHire(Map<String, dynamic>.from(e))),
        );
      }
    }

    if (rideResult['success'] != true && hireResult['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage = rideResult['message'] ??
            hireResult['message'] ??
            'Failed to load history';
      });
      return;
    }

    combinedTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      trips = combinedTrips;
      isLoading = false;
    });
  }

  List<_TripItem> get filteredTrips {
    if (selectedFilter == 'Completed') {
      return trips.where((trip) => trip.status == 'completed').toList();
    }
    if (selectedFilter == 'Cancelled') {
      return trips.where((trip) {
        final status = trip.status.toLowerCase();
        return status == 'cancelled' ||
            status == 'declined' ||
            status == 'expired';
      }).toList();
    }
    return trips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 1,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadMyRideRequests,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip History',
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _FilterChipButton(
                      text: 'All',
                      active: selectedFilter == 'All',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'All';
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    _FilterChipButton(
                      text: 'Completed',
                      active: selectedFilter == 'Completed',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Completed';
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    _FilterChipButton(
                      text: 'Cancelled',
                      active: selectedFilter == 'Cancelled',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Cancelled';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (errorMessage.isNotEmpty)
                  _ErrorBox(
                    message: errorMessage,
                    onRetry: _loadMyRideRequests,
                  )
                else if (filteredTrips.isEmpty)
                  _EmptyBox(
                    text: selectedFilter == 'All'
                        ? 'No history found'
                        : 'No ${selectedFilter.toLowerCase()} history found',
                  )
                else
                  ...filteredTrips.map(
                    (trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TripCard(trip: trip),
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

class _FilterChipButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.secondary,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? AppColors.white : AppColors.text2(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final _TripItem trip;

  const _TripCard({
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final String statusLower = trip.status.toLowerCase();

    final bool isCompleted = statusLower == 'completed';
    final bool isCancelled = statusLower == 'cancelled' ||
        statusLower == 'declined' ||
        statusLower == 'expired';

    final bool showRebook = isCompleted || isCancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.softBg(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  trip.icon,
                  size: 24,
                  color: trip.iconColor,
                ),
              ),
              const SizedBox(width: 12),

              /// LEFT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text1(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.route,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text2(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (trip.distance.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        trip.distance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB6AFC7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// RIGHT SIDE
              SizedBox(
                width: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.amount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text1(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFC9EFD9)
                            : isCancelled
                                ? const Color(0xFFF8D9DA)
                                : const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trip.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCompleted
                              ? const Color(0xFF16935C)
                              : isCancelled
                                  ? const Color(0xFFE25757)
                                  : AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(
            height: 1,
            color: AppColors.secondary.withOpacity(0.45),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  trip.time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trip.rating > 0) ...[
                const SizedBox(width: 8),
                _RatingStars(rating: trip.rating),
              ],
              if (showRebook) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softBg(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Rebook',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.text2(context),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text2(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;

  const _EmptyBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.text2(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final int rating;

  const _RatingStars({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star_rounded,
              size: 16,
              color: index < rating
                  ? const Color(0xFFE2B63B)
                  : const Color(0xFF9C9AA3),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripItem {
  final String title;
  final String tag;
  final String amount;
  final String status;
  final String route;
  final String distance;
  final String time;
  final DateTime createdAt;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int rating;

  const _TripItem({
    required this.title,
    required this.tag,
    required this.amount,
    required this.status,
    required this.route,
    required this.distance,
    required this.time,
    required this.createdAt,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.rating,
  });

  factory _TripItem.fromRide(Map<String, dynamic> ride) {
    final pickup = Map<String, dynamic>.from(ride['pickup'] ?? {});
    final dropoff = Map<String, dynamic>.from(ride['dropoff'] ?? {});
    final routeData = Map<String, dynamic>.from(ride['route'] ?? {});
    final pricing = Map<String, dynamic>.from(ride['pricing'] ?? {});

    final pickupAddress = pickup['address']?.toString() ?? 'Pickup';
    final dropoffAddress = dropoff['address']?.toString() ?? 'Dropoff';

    final distanceKm = routeData['distanceKm'];
    final durationMinutes = routeData['durationMinutes'];

    final offeredFare = pricing['offeredFare'];
    final status = ride['status']?.toString() ?? 'draft';

    final createdAtString = ride['createdAt']?.toString() ?? '';

    return _TripItem(
      title: 'Book a Ride',
      tag: ride['vehicleLabel']?.toString() ??
          ride['vehicleType']?.toString() ??
          ride['tripType']?.toString() ??
          'Ride',
      amount: offeredFare is num ? 'PKR ${offeredFare.toInt()}' : 'PKR 0',
      status: status,
      route: '$pickupAddress → $dropoffAddress',
      distance: distanceKm is num
          ? '${distanceKm.toStringAsFixed(1)} km${durationMinutes is num ? ' • ${durationMinutes.toInt()} min' : ''}'
          : '',
      time: _formatDate(createdAtString),
      createdAt: _parseDate(createdAtString),
      icon: Icons.directions_car_filled_rounded,
      iconBg: AppColors.light,
      iconColor: AppColors.primary,
      rating: _ratingFromOffers(ride),
    );
  }

  factory _TripItem.fromHire(Map<String, dynamic> hire) {
    final pickup = Map<String, dynamic>.from(hire['pickup'] ?? {});
    final dropoff = Map<String, dynamic>.from(hire['dropoff'] ?? {});
    final routeData = Map<String, dynamic>.from(hire['route'] ?? {});
    final pricing = Map<String, dynamic>.from(hire['pricing'] ?? {});
    final serviceOption =
        Map<String, dynamic>.from(hire['serviceOption'] ?? {});

    final pickupAddress = pickup['address']?.toString() ?? 'Pickup';
    final dropoffAddress = dropoff['address']?.toString() ?? 'Dropoff';

    final distanceKm = routeData['estimatedDistanceKm'];
    final durationMinutes = routeData['estimatedDurationMinutes'];

    final totalFare = pricing['totalFare'];
    final status = hire['status']?.toString() ?? 'draft';

    final createdAtString = hire['createdAt']?.toString() ?? '';

    return _TripItem(
      title: 'Hire Driver',
      tag: serviceOption['title']?.toString() ??
          hire['serviceType']?.toString() ??
          'Hire',
      amount: totalFare is num ? 'PKR ${totalFare.toInt()}' : 'PKR 0',
      status: status,
      route: '$pickupAddress → $dropoffAddress',
      distance: distanceKm is num
          ? '${distanceKm.toStringAsFixed(1)} km${durationMinutes is num ? ' • ${durationMinutes.toInt()} min' : ''}'
          : '',
      time: _formatDate(createdAtString),
      createdAt: _parseDate(createdAtString),
      icon: Icons.local_taxi_rounded,
      iconBg: AppColors.light,
      iconColor: const Color(0xFFF2B42E),
      rating: _ratingFromHire(hire),
    );
  }

  static int _ratingFromOffers(Map<String, dynamic> ride) {
    final offers = ride['driverOffers'];
    if (offers is List && offers.isNotEmpty) {
      final selectedOfferId = ride['selectedOfferId']?.toString();

      Map<String, dynamic>? selectedOffer;

      for (final item in offers) {
        final offer = Map<String, dynamic>.from(item);
        if (offer['_id']?.toString() == selectedOfferId) {
          selectedOffer = offer;
          break;
        }
      }

      selectedOffer ??= Map<String, dynamic>.from(offers.first);

      final rating = selectedOffer['rating'];
      if (rating is num) {
        return rating.round().clamp(0, 5);
      }
    }
    return 0;
  }

  static int _ratingFromHire(Map<String, dynamic> hire) {
    final selectedDriver = hire['selectedDriver'];

    if (selectedDriver is Map) {
      final rating = selectedDriver['rating'];
      if (rating is num) {
        return rating.round().clamp(0, 5);
      }
    }

    final options = hire['driverOptions'];
    if (options is List && options.isNotEmpty) {
      final first = Map<String, dynamic>.from(options.first);
      final rating = first['rating'];
      if (rating is num) {
        return rating.round().clamp(0, 5);
      }
    }

    return 0;
  }

  static DateTime _parseDate(String isoDate) {
    if (isoDate.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    try {
      return DateTime.parse(isoDate).toLocal();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  static String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';

    try {
      final date = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final itemDay = DateTime(date.year, date.month, date.day);

      final difference = today.difference(itemDay).inDays;

      final hour = date.hour > 12
          ? date.hour - 12
          : date.hour == 0
              ? 12
              : date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final amPm = date.hour >= 12 ? 'PM' : 'AM';

      if (difference == 0) {
        return 'Today, $hour:$minute $amPm';
      }

      if (difference == 1) {
        return 'Yesterday, $hour:$minute $amPm';
      }

      return '$difference days ago';
    } catch (_) {
      return isoDate;
    }
  }
}