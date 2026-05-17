import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/riderrating.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';
import 'package:hire_driver/view/book a ride/provider/drivertraling.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class OngoingRideScreen extends StatefulWidget {
  final String? rideId;

  const OngoingRideScreen({super.key, this.rideId});

  @override
  State<OngoingRideScreen> createState() => _OngoingRideScreenState();
}

class _OngoingRideScreenState extends State<OngoingRideScreen> {
  final MapController _mapController = MapController();
  Timer? _rideRefreshTimer;

  bool isLoadingRide = true;
  String riderInitial = 'R';
  String riderName = 'Accepted rider';
  String riderRating = '4.8';
  String vehicleInfo = 'Vehicle details will appear here';
  String passengerName = 'Passenger';
  String pickupAddress = 'Pickup location';
  String dropoffAddress = 'Destination';
  String tripType = 'Ride';
  String rideStatus = 'En Route';
  String fareAmount = '0';
  String distanceText = '0 km';
  String durationText = '0 min';

  LatLng? pickupPoint;
  LatLng? dropoffPoint;
  bool _hasNavigatedFromRideState = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OngoingRideProvider>().startRideProgress();
      _loadRideDetails();

      if (widget.rideId != null && widget.rideId!.isNotEmpty) {
        _rideRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
          if (mounted) _loadRideDetails();
        });
      }
    });
  }

  @override
  void dispose() {
    _rideRefreshTimer?.cancel();
    context.read<OngoingRideProvider>().clear();
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
      final ride = result['data']?['ride'];

      if (!mounted) return;

      final rideMap = _asMap(ride);
      final rider = _acceptedRiderFromRide(rideMap);
      final nestedUser = _asMap(
        rider['rider'] ?? rider['driver'] ?? rider['user'],
      );
      final passenger = _asMap(
        rideMap['user'] ?? rideMap['passenger'] ?? rideMap['customer'],
      );
      final pickup = _asMap(rideMap['pickup'] ?? rideMap['pickupLocation']);
      final dropoff = _asMap(
        rideMap['dropoff'] ??
            rideMap['destination'] ??
            rideMap['destinationLocation'],
      );
      final parsedPickup = _parseLatLng(pickup);
      final parsedDropoff = _parseLatLng(dropoff);
      final displayRiderName = _displayName(
        rider,
        nestedUser,
        fallback: 'Accepted rider',
      );
      final initialSource = _firstString(
        rider,
        const ['avatarInitial'],
        fallback: displayRiderName,
      );
      final vehicleDetails = [
        rider['vehicleName'],
        rider['vehicleColor'],
        rider['vehiclePlate'],
      ]
          .map((part) => part?.toString().trim() ?? '')
          .where((part) => part.isNotEmpty)
          .join(' / ');
      final vehicleType = rideMap['vehicleType']?.toString() ?? 'Ride';
      final fareObject = rideMap['fare'];
      final fareFromObject = fareObject is Map
          ? _asMap(fareObject)['amount']
          : fareObject;
      final fare =
          rideMap['acceptedFare'] ??
          rideMap['offeredFare'] ??
          fareFromObject;
      final distance = rideMap['distanceKm'] ?? rideMap['distance'];
      final duration = rideMap['durationMinutes'] ?? rideMap['duration'];
      final nextFareAmount = fare is num
          ? fare.toInt().toString()
          : fare?.toString() ?? '0';

      setState(() {
        riderName = displayRiderName;
        riderInitial = initialSource.isNotEmpty
            ? initialSource.substring(0, 1).toUpperCase()
            : 'R';
        riderRating = _ratingFrom(rider, nestedUser);
        vehicleInfo = [
          vehicleType.toUpperCase(),
          vehicleDetails,
        ].where((part) => part.trim().isNotEmpty).join(' - ');
        passengerName = _displayName(
          passenger,
          const <String, dynamic>{},
          fallback: 'Passenger',
        );
        pickupAddress = pickup['address']?.toString() ?? 'Pickup location';
        dropoffAddress = dropoff['address']?.toString() ?? 'Destination';
        tripType = rideMap['tripType']?.toString() ?? vehicleType;
        rideStatus = rideMap['status']?.toString() ?? 'En Route';
        fareAmount = nextFareAmount;
        distanceText = distance is num
            ? '${distance.toStringAsFixed(1)} km'
            : distance?.toString() ?? '0 km';
        durationText = duration is num
            ? '${duration.toInt()} min'
            : duration?.toString() ?? '0 min';
        pickupPoint = parsedPickup ?? pickupPoint;
        dropoffPoint = parsedDropoff ?? dropoffPoint;
        isLoadingRide = false;
      });

      final center = parsedPickup ?? parsedDropoff;
      if (center != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(center, 15.5);
        });
      }

      _handleRideStage(rideMap);
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

  String _ratingFrom(
    Map<String, dynamic> rider,
    Map<String, dynamic> nestedUser,
  ) {
    final rating =
        rider['rating'] ??
        rider['averageRating'] ??
        nestedUser['rating'] ??
        nestedUser['averageRating'];

    if (rating is num) return rating.toStringAsFixed(1);
    return '4.8';
  }

  LatLng? _parseLatLng(Map<String, dynamic> location) {
    final coordinates = _asMap(location['coordinates']);
    final lat =
        location['lat'] ??
        location['latitude'] ??
        coordinates['lat'] ??
        coordinates['latitude'];
    final lng =
        location['lng'] ??
        location['lon'] ??
        location['longitude'] ??
        coordinates['lng'] ??
        coordinates['lon'] ??
        coordinates['longitude'];

    if (lat is! num || lng is! num) return null;
    return LatLng(lat.toDouble(), lng.toDouble());
  }

  void _handleRideStage(Map<String, dynamic> ride) {
    if (_hasNavigatedFromRideState || !_isRideCompleted(ride)) return;

    _hasNavigatedFromRideState = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RideReviewScreen(rideId: widget.rideId),
        ),
      );
    });
  }

  bool _isRideCompleted(Map<String, dynamic> ride) {
    final status = ride['status']?.toString().toLowerCase() ?? '';
    final passengerUpdate = _asMap(ride['passengerUpdate']);
    final decision =
        passengerUpdate['decision']?.toString().toLowerCase() ?? '';

    return status == 'completed' ||
        status == 'complete' ||
        status == 'ended' ||
        status == 'finished' ||
        status == 'ride_completed' ||
        decision == 'completed' ||
        decision == 'ended' ||
        passengerUpdate['completed'] == true ||
        passengerUpdate['ended'] == true ||
        passengerUpdate['completedAt'] != null ||
        passengerUpdate['endedAt'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OngoingRideProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _MapArea(
                mapController: _mapController,
                pickupPoint: pickupPoint,
                dropoffPoint: dropoffPoint,
                pickupAddress: pickupAddress,
                dropoffAddress: dropoffAddress,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _TripTopCard(
                riderName: isLoadingRide ? 'Loading ride...' : riderName,
                durationText: durationText,
                status: rideStatus,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.35
                            : 0.06,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.64,
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DriverInfoCard(
                          isLoading: isLoadingRide,
                          initial: riderInitial,
                          name: riderName,
                          rating: riderRating,
                          vehicleInfo: vehicleInfo,
                        ),
                        const SizedBox(height: 12),
                        _RequestDetailsCard(
                          passengerName: passengerName,
                          pickupAddress: pickupAddress,
                          dropoffAddress: dropoffAddress,
                          tripType: tripType,
                          distanceText: distanceText,
                        ),
                        const SizedBox(height: 12),
                        _FareProgressCard(
                          progress: provider.rideProgress,
                          fareAmount: fareAmount,
                          status: rideStatus,
                        ),
                        const SizedBox(height: 12),
                        const _SosButton(),
                        const SizedBox(height: 12),
                        _EndRideButton(rideId: widget.rideId),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripTopCard extends StatelessWidget {
  final String riderName;
  final String durationText;
  final String status;

  const _TripTopCard({
    required this.riderName,
    required this.durationText,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$riderName enroute to destination',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.text2(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            durationText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.deepOrange.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final bool isLoading;
  final String initial;
  final String name;
  final String rating;
  final String vehicleInfo;

  const _DriverInfoCard({
    required this.isLoading,
    required this.initial,
    required this.name,
    required this.rating,
    required this.vehicleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _DriverAvatar(initial: initial, rating: rating),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? 'Loading accepted rider...' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const Icon(
                      Icons.star_half_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading ? 'Loading vehicle information...' : vehicleInfo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.text2(context),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _CircleActionButton(
            bgColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2222)
                : const Color(0xFFF4E8E8),
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.primary,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _CircleActionButton(
            bgColor: const Color(0xFF14C38E),
            icon: Icons.call_rounded,
            iconColor: AppColors.white,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  final String initial;
  final String rating;

  const _DriverAvatar({required this.initial, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.cyan.shade500],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.card(context), width: 2),
            ),
            child: Text(
              rating,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

class _RequestDetailsCard extends StatelessWidget {
  final String passengerName;
  final String pickupAddress;
  final String dropoffAddress;
  final String tripType;
  final String distanceText;

  const _RequestDetailsCard({
    required this.passengerName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.tripType,
    required this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          _DetailRow(icon: Icons.person_rounded, label: passengerName),
          const SizedBox(height: 8),
          _DetailRow(icon: Icons.my_location_rounded, label: pickupAddress),
          const SizedBox(height: 8),
          _DetailRow(icon: Icons.location_on_rounded, label: dropoffAddress),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoPill(label: tripType),
              const SizedBox(width: 8),
              _InfoPill(label: distanceText),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _FareProgressCard extends StatelessWidget {
  final double progress;
  final String fareAmount;
  final String status;

  const _FareProgressCard({
    required this.progress,
    required this.fareAmount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final int percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1D2B22)
            : const Color(0xFFEFFAF3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Agreed Fare',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
                        fontSize: 13,
                        color: AppColors.text2(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: fareAmount,
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2(context),
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 350),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2E3D33)
                      : const Color(0xFFD9EBDD),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 197, 34, 184),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.emergency_rounded, color: Color(0xFFFA4A3C)),
        label: const Text(
          'SOS Emergency',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFA4A3C),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF3A1F1F)
              : const Color(0xFFF8DCDC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFF09A9A), width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _EndRideButton extends StatelessWidget {
  final String? rideId;

  const _EndRideButton({required this.rideId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RideReviewScreen(rideId: rideId)),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card(context),
          side: const BorderSide(color: Color(0xFF315EEC), width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'End Ride',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF315EEC),
          ),
        ),
      ),
    );
  }
}

class _MapArea extends StatelessWidget {
  final MapController mapController;
  final LatLng? pickupPoint;
  final LatLng? dropoffPoint;
  final String pickupAddress;
  final String dropoffAddress;

  const _MapArea({
    required this.mapController,
    required this.pickupPoint,
    required this.dropoffPoint,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  @override
  Widget build(BuildContext context) {
    final centerPoint =
        pickupPoint ?? dropoffPoint ?? const LatLng(31.5204, 74.3587);
    final routePoints = [
      if (pickupPoint != null) pickupPoint!,
      if (dropoffPoint != null) dropoffPoint!,
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: 15.5,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.hire_driver',
            ),
            if (routePoints.length == 2)
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
                    child: const _MapPinBubble(
                      color: Colors.deepOrange,
                      icon: Icons.my_location_rounded,
                    ),
                  ),
                if (dropoffPoint != null)
                  Marker(
                    point: dropoffPoint!,
                    width: 70,
                    height: 70,
                    child: const _MapPinBubble(
                      color: Color(0xFF315EEC),
                      icon: Icons.location_on_rounded,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 92,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.28
                        : 0.10,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$pickupAddress to $dropoffAddress',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1(context),
                    ),
                  ),
                ),
              ],
            ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.white, size: 22),
        ),
        Container(
          width: 13,
          height: 13,
          transform: Matrix4.rotationZ(0.785398),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}
