import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book%20a%20ride/services/bookaride.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/drivercomingtoyou.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/drivertravling.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/riderrating.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class DriverComingScreen extends StatefulWidget {
  final String? rideId;

  const DriverComingScreen({super.key, this.rideId});

  @override
  State<DriverComingScreen> createState() => _DriverComingScreenState();
}

class _DriverComingScreenState extends State<DriverComingScreen> {
  String? selectedCancelReason;
  final TextEditingController otherReasonController = TextEditingController();
  final MapController _mapController = MapController();
  Timer? _rideRefreshTimer;
  bool isLoadingRide = true;
  String riderInitial = 'R';
  String riderName = 'Rider';
  String riderRating = '4.8';
  String vehicleInfo = 'Vehicle details will appear here';
  String riderStatus = 'Preparing your pickup details';
  String pickupAddress = 'Pickup location';
  LatLng pickupPoint = const LatLng(31.5204, 74.3587);
  bool hasPickupLocation = false;
  bool _hasNavigatedFromRideState = false;

  final List<String> cancelReasons = [
    "Driver is too far away",
    "Driver is taking too long",
    "Wrong pickup location",
    "Fare is too high",
    "Booked by mistake",
    "Driver asked me to cancel",
    "I found another ride",
    "Other",
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DriverComingProvider>().startDriverComing();
      _loadRideDetails();
      _rideRefreshTimer?.cancel();
      if (widget.rideId != null && widget.rideId!.isNotEmpty) {
        _rideRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (mounted) {
            _loadRideDetails();
          }
        });
      }
    });

  }

  @override
  void dispose() {
    _rideRefreshTimer?.cancel();
    context.read<DriverComingProvider>().clear();
    otherReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadRideDetails() async {
    final rideId = widget.rideId;

    if (rideId == null || rideId.isEmpty) {
      if (!mounted) return;
      setState(() {
        isLoadingRide = false;
      });
      return;
    }

    try {
      final result = await RideApiService.getRideRequest(rideId: rideId);
      final ride = result['data']?['ride'];

      if (!mounted) return;

      final rideMap = _asMap(ride);
      final selectedRider = _acceptedRiderFromRide(rideMap);
      final pickup = _asMap(rideMap['pickup']);
      final vehicleType = rideMap['vehicleType']?.toString() ?? 'Ride';
      final nextPickupAddress =
          pickup['address']?.toString().trim().isNotEmpty == true
          ? pickup['address'].toString()
          : 'Pickup location';
      final parsedPickup = _parseLatLng(pickup);
      final nextRiderName = _firstString(
        selectedRider,
        const ['riderName', 'driverName', 'name', 'fullName'],
        fallback: 'Accepted rider',
      );
      final nestedUser = _asMap(
        selectedRider['rider'] ?? selectedRider['driver'] ?? selectedRider['user'],
      );
      final displayRiderName = nextRiderName == 'Accepted rider'
          ? _firstString(
              nestedUser,
              const ['name', 'fullName', 'riderName', 'driverName'],
              fallback: nextRiderName,
            )
          : nextRiderName;
      final initialSource = _firstString(
        selectedRider,
        const ['avatarInitial'],
        fallback: displayRiderName,
      );
      final nextRating = _ratingFrom(selectedRider, nestedUser);
      final etaMinutes = selectedRider['etaMinutes'] ?? nestedUser['etaMinutes'];
      final vehicleDetails = [
        selectedRider['vehicleName'],
        selectedRider['vehicleColor'],
        selectedRider['vehiclePlate'],
      ]
          .map((part) => part?.toString().trim() ?? '')
          .where((part) => part.isNotEmpty)
          .join(' / ');
      final vehicleParts = [
        vehicleType.toUpperCase(),
        vehicleDetails,
        if (etaMinutes != null) '$etaMinutes min away',
        'Pickup: $nextPickupAddress',
      ].where((part) => part.trim().isNotEmpty).toList();

      setState(() {
        riderInitial = initialSource.isNotEmpty
            ? initialSource.substring(0, 1).toUpperCase()
            : 'R';
        riderName = displayRiderName;
        riderRating = nextRating;
        vehicleInfo = vehicleParts.join(' - ');
        riderStatus =
            rideMap['passengerUpdate']?['message']?.toString() ??
            'Rider accepted your ride and is coming.';
        pickupAddress = nextPickupAddress;
        if (parsedPickup != null) {
          pickupPoint = parsedPickup;
          hasPickupLocation = true;
        }
        isLoadingRide = false;
      });

      if (parsedPickup != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(parsedPickup, 16);
        });
      }

      _handleRideStage(rideMap);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoadingRide = false;
      });
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  Map<String, dynamic> _acceptedRiderFromRide(dynamic ride) {
    final rideMap = _asMap(ride);
    final selectedRider = _asMap(rideMap['selectedRider']);
    if (selectedRider.isNotEmpty) return selectedRider;

    final offers = rideMap['driverOffers'];
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

  void _handleRideStage(Map<String, dynamic> ride) {
    if (_hasNavigatedFromRideState) return;

    if (_isRideCompleted(ride)) {
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
      return;
    }

    if (_isRideStarted(ride)) {
      _hasNavigatedFromRideState = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OngoingRideScreen(rideId: widget.rideId),
          ),
        );
      });
    }
  }

  bool _isRideStarted(Map<String, dynamic> ride) {
    final status = ride['status']?.toString().toLowerCase() ?? '';
    final passengerUpdate = _asMap(ride['passengerUpdate']);
    final decision =
        passengerUpdate['decision']?.toString().toLowerCase() ?? '';

    return status == 'started' ||
        status == 'ongoing' ||
        status == 'in_progress' ||
        status == 'in-progress' ||
        status == 'traveling' ||
        status == 'travelling' ||
        status == 'enroute' ||
        status == 'en_route' ||
        status == 'onride' ||
        status == 'on_ride' ||
        status == 'on_trip' ||
        status == 'picked_up' ||
        status == 'active' ||
        decision == 'started' ||
        decision == 'ride_started' ||
        passengerUpdate['started'] == true ||
        passengerUpdate['rideStarted'] == true ||
        passengerUpdate['startedAt'] != null;
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

  Future<void> _refreshRideDetailsManually() async {
    await _loadRideDetails();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ride status refreshed')));
  }

  void _showCancelReasonSheet() {
    selectedCancelReason = null;
    otherReasonController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final showOther = selectedCancelReason == "Other";

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Cancel Ride",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text1(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Please select a reason",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text2(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...cancelReasons.map((reason) {
                    return RadioListTile<String>(
                      value: reason,
                      groupValue: selectedCancelReason,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        reason,
                        style: TextStyle(
                          color: AppColors.text1(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedCancelReason = value;
                        });
                      },
                    );
                  }),

                  if (showOther) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: otherReasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write your reason",
                        filled: true,
                        fillColor: AppColors.card(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _showCancelReasonSheet,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Cancel Ride",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverComingProvider>();
    final percent = (provider.driverProgress * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _MapArea(
                mapController: _mapController,
                pickupPoint: pickupPoint,
                pickupAddress: pickupAddress,
                hasPickupLocation: hasPickupLocation,
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _TopStatusCard(
                percent: percent,
                onRefresh: _refreshRideDetailsManually,
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
                            : 0.08,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DriverInfoCard(
                      isLoading: isLoadingRide,
                      riderInitial: riderInitial,
                      riderName: riderName,
                      riderRating: riderRating,
                      vehicleInfo: vehicleInfo,
                      riderStatus: riderStatus,
                    ),
                    const SizedBox(height: 14),
                    _PickupProgressCard(progress: provider.driverProgress),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OngoingRideScreen(rideId: widget.rideId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Start Ride",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _showCancelReasonSheet,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Cancel Ride",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStatusCard extends StatelessWidget {
  final int percent;
  final VoidCallback onRefresh;

  const _TopStatusCard({required this.percent, required this.onRefresh});

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
          Icon(Icons.local_taxi_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Driver is coming to pick you",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Arriving soon at your pickup location",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.text2(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$percent%",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.deepOrange.shade400,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Refresh status',
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.text1(context),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final bool isLoading;
  final String riderInitial;
  final String riderName;
  final String riderRating;
  final String vehicleInfo;
  final String riderStatus;

  const _DriverInfoCard({
    required this.isLoading,
    required this.riderInitial,
    required this.riderName,
    required this.riderRating,
    required this.vehicleInfo,
    required this.riderStatus,
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
          _DriverAvatar(initial: riderInitial, rating: riderRating),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? 'Loading rider details...' : riderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const Icon(
                      Icons.star_half_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      riderRating,
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
                  isLoading ? 'Loading ride information...' : vehicleInfo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.text2(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading ? '' : riderStatus,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

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

class _PickupProgressCard extends StatelessWidget {
  final double progress;

  const _PickupProgressCard({required this.progress});

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
                  "Pickup Status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
              ),
              Text(
                "5 min",
                style: TextStyle(
                  fontSize: 22,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  "Driver moving to your pickup point",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2(context),
                  ),
                ),
              ),
              Text(
                "$percent%",
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
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2E3D33)
                  : const Color(0xFFD9EBDD),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 197, 34, 184),
              ),
            ),
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
            style: TextStyle(
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
              style: TextStyle(
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

class _MapArea extends StatelessWidget {
  final MapController mapController;
  final LatLng pickupPoint;
  final String pickupAddress;
  final bool hasPickupLocation;

  const _MapArea({
    required this.mapController,
    required this.pickupPoint,
    required this.pickupAddress,
    required this.hasPickupLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: pickupPoint,
            initialZoom: 16,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.hire_driver',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pickupPoint,
                  width: 82,
                  height: 82,
                  alignment: Alignment.center,
                  child: _MapPickupMarker(hasPickupLocation: hasPickupLocation),
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
                const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pickupAddress,
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
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(child: Center(child: _MapCenterRing())),
        ),
      ],
    );
  }
}

class _MapPickupMarker extends StatelessWidget {
  final bool hasPickupLocation;

  const _MapPickupMarker({required this.hasPickupLocation});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: hasPickupLocation ? Colors.deepOrange.shade400 : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (hasPickupLocation
                        ? Colors.deepOrange.shade400
                        : Colors.grey)
                    .withOpacity(0.35),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.person_pin_circle_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
        Container(
          width: 13,
          height: 13,
          transform: Matrix4.rotationZ(0.785398),
          decoration: BoxDecoration(
            color: hasPickupLocation ? Colors.deepOrange.shade400 : Colors.grey,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

class _MapCenterRing extends StatelessWidget {
  const _MapCenterRing();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.12),
        border: Border.all(color: AppColors.primary.withOpacity(0.28)),
      ),
    );
  }
}
