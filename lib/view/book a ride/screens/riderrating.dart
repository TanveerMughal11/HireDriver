import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';
import 'package:hire_driver/view/book a ride/provider/riderating.dart';
import 'package:provider/provider.dart';

class RideReviewScreen extends StatefulWidget {
  final String? rideId;

  const RideReviewScreen({super.key, this.rideId});

  @override
  State<RideReviewScreen> createState() => _RideReviewScreenState();
}

class _RideReviewScreenState extends State<RideReviewScreen> {
  final TextEditingController reviewController = TextEditingController();

  bool isLoadingRide = true;
  String riderName = 'Accepted rider';
  String passengerName = 'Passenger';
  String pickupAddress = 'Pickup location';
  String dropoffAddress = 'Destination';
  String tripText = '0 km - 0 min';
  String totalPaid = '0';
  String vehicleInfo = 'Ride completed';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRideDetails();
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadRideDetails() async {
    final rideId = widget.rideId;

    if (rideId == null || rideId.isEmpty) {
      if (!mounted) return;
      setState(() => isLoadingRide = false);
      return;
    }

    try {
      final result = await RideApiService.getRideRequest(rideId: rideId);
      final ride = _asMap(result['data']?['ride']);

      if (!mounted) return;

      final rider = _acceptedRiderFromRide(ride);
      final nestedUser = _asMap(
        rider['rider'] ?? rider['driver'] ?? rider['user'],
      );
      final passenger = _asMap(
        ride['user'] ?? ride['passenger'] ?? ride['customer'],
      );
      final pickup = _asMap(ride['pickup'] ?? ride['pickupLocation']);
      final dropoff = _asMap(
        ride['dropoff'] ?? ride['destination'] ?? ride['destinationLocation'],
      );
      final fareObject = ride['fare'];
      final fareFromObject = fareObject is Map
          ? _asMap(fareObject)['amount']
          : fareObject;
      final fare = ride['acceptedFare'] ?? ride['offeredFare'] ?? fareFromObject;
      final distance = ride['distanceKm'] ?? ride['distance'];
      final duration = ride['durationMinutes'] ?? ride['duration'];
      final vehicleDetails = [
        rider['vehicleName'],
        rider['vehicleColor'],
        rider['vehiclePlate'],
      ]
          .map((part) => part?.toString().trim() ?? '')
          .where((part) => part.isNotEmpty)
          .join(' / ');
      final vehicleType = ride['vehicleType']?.toString() ?? 'Ride';

      setState(() {
        riderName = _displayName(rider, nestedUser, fallback: 'Accepted rider');
        passengerName = _displayName(
          passenger,
          const <String, dynamic>{},
          fallback: 'Passenger',
        );
        pickupAddress = pickup['address']?.toString() ?? 'Pickup location';
        dropoffAddress = dropoff['address']?.toString() ?? 'Destination';
        tripText = [
          distance is num
              ? '${distance.toStringAsFixed(1)} km'
              : distance?.toString() ?? '0 km',
          duration is num
              ? '${duration.toInt()} min'
              : duration?.toString() ?? '0 min',
        ].join(' - ');
        totalPaid = fare is num
            ? fare.toInt().toString()
            : fare?.toString() ?? '0';
        vehicleInfo = [
          vehicleType.toUpperCase(),
          vehicleDetails,
        ].where((part) => part.trim().isNotEmpty).join(' - ');
        isLoadingRide = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingRide = false);
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  Map<String, dynamic> _acceptedRiderFromRide(Map<String, dynamic> ride) {
    final selectedRider = _asMap(ride['selectedRider']);
    if (selectedRider.isNotEmpty) return selectedRider;

    final offers = ride['driverOffers'];
    if (offers is List) {
      for (final offer in offers) {
        final offerMap = _asMap(offer);
        if (offerMap['status']?.toString().toLowerCase() == 'accepted') {
          return offerMap;
        }
      }
    }

    return {};
  }

  String _displayName(
    Map<String, dynamic> source,
    Map<String, dynamic> nested, {
    required String fallback,
  }) {
    final name = _firstString(
      source,
      const ['riderName', 'driverName', 'name', 'fullName', 'userName'],
      fallback: '',
    );
    if (name.isNotEmpty) return name;

    return _firstString(
      nested,
      const ['name', 'fullName', 'riderName', 'driverName', 'userName'],
      fallback: fallback,
    );
  }

  String _firstString(
    Map<String, dynamic> source,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = source[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  void _submitReview() {
    final provider = context.read<RideReviewProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThankYouRatingScreen(rating: provider.selectedRating),
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    final provider = context.read<RideReviewProvider>();

    final success = await provider.downloadReceipt(
      trip: tripText,
      rider: riderName,
      pickup: pickupAddress,
      dropoff: dropoffAddress,
      totalPaid: totalPaid,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Receipt downloaded' : 'Receipt download failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RideReviewProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              _ReceiptCard(
                isLoading: isLoadingRide,
                riderName: riderName,
                passengerName: passengerName,
                pickupAddress: pickupAddress,
                dropoffAddress: dropoffAddress,
                tripText: tripText,
                totalPaid: totalPaid,
                vehicleInfo: vehicleInfo,
                onDownload: provider.isDownloading
                    ? null
                    : () => _downloadReceipt(context),
              ),
              const SizedBox(height: 18),
              _RatingReviewCard(
                riderName: riderName,
                selectedRating: provider.selectedRating,
                controller: reviewController,
                onRatingTap: provider.selectRating,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.selectedRating == 0 ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.secondary.withOpacity(.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final bool isLoading;
  final String riderName;
  final String passengerName;
  final String pickupAddress;
  final String dropoffAddress;
  final String tripText;
  final String totalPaid;
  final String vehicleInfo;
  final VoidCallback? onDownload;

  const _ReceiptCard({
    required this.isLoading,
    required this.riderName,
    required this.passengerName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.tripText,
    required this.totalPaid,
    required this.vehicleInfo,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.softBg(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isLoading ? 'Loading receipt...' : "You've arrived!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 20),
          _ReceiptRow(icon: Icons.route_rounded, label: 'Trip', value: tripText),
          const SizedBox(height: 12),
          _ReceiptRow(
            icon: Icons.person_rounded,
            label: 'Rider',
            value: riderName,
          ),
          const SizedBox(height: 12),
          _ReceiptRow(
            icon: Icons.account_circle_rounded,
            label: 'User',
            value: passengerName,
          ),
          const SizedBox(height: 12),
          _ReceiptRow(
            icon: Icons.directions_car_rounded,
            label: 'Vehicle',
            value: vehicleInfo,
          ),
          const SizedBox(height: 12),
          _ReceiptRow(
            icon: Icons.my_location_rounded,
            label: 'Pickup',
            value: pickupAddress,
          ),
          const SizedBox(height: 12),
          _ReceiptRow(
            icon: Icons.location_on_rounded,
            label: 'Dropoff',
            value: dropoffAddress,
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.grey.withOpacity(.7), thickness: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Paid',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'PKR ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text2(context),
                      ),
                    ),
                    TextSpan(
                      text: totalPaid,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(
                Icons.download_rounded,
                color: AppColors.darkPrimary,
                size: 20,
              ),
              label: const Text(
                'Download Receipt',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withOpacity(.35)),
                backgroundColor: AppColors.softBg(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.text2(context)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingReviewCard extends StatelessWidget {
  final String riderName;
  final int selectedRating;
  final TextEditingController controller;
  final ValueChanged<int> onRatingTap;

  const _RatingReviewCard({
    required this.riderName,
    required this.selectedRating,
    required this.controller,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Rate $riderName',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text1(context),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= selectedRating;

              return GestureDetector(
                onTap: () => onRatingTap(starIndex),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 42,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          Text(
            'Write review',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(color: AppColors.text1(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Share your experience with the rider...',
              hintStyle: TextStyle(color: AppColors.text2(context), fontSize: 14),
              filled: true,
              fillColor: AppColors.softBg(context),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.secondary.withOpacity(.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.secondary.withOpacity(.5)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(color: AppColors.primary, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThankYouRatingScreen extends StatelessWidget {
  final int rating;

  const ThankYouRatingScreen({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        color: AppColors.softBg(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Thanks for the rating!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your feedback helps us improve\nride quality on HireDrive.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: AppColors.text2(context),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softBg(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Points Earned',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '+35 pts',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text1(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            rating >= 4
                                ? Icons.workspace_premium_rounded
                                : Icons.star_rounded,
                            size: 34,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
