import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/provider/available_drivers.dart';
import 'package:hire_driver/view/hiredriver/screens/confirmbooking.dart';
import 'package:provider/provider.dart';

class AvailableDriversScreen extends StatelessWidget {
  final String hireRequestId;

  const AvailableDriversScreen({
    super.key,
    required this.hireRequestId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AvailableDriversProvider(),
      child: _AvailableDriversBody(
        hireRequestId: hireRequestId,
      ),
    );
  }
}

class _AvailableDriversBody extends StatefulWidget {
  final String hireRequestId;

  const _AvailableDriversBody({
    required this.hireRequestId,
  });

  @override
  State<_AvailableDriversBody> createState() => _AvailableDriversBodyState();
}

class _AvailableDriversBodyState extends State<_AvailableDriversBody> {
  int selectedFilter = 0;
  bool isMapView = true;

  final List<String> filters = [
    'All',
    'Top Rated',
    'Cheapest',
    'Most Experienced',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDrivers();
    });
  }

  Future<void> _loadDrivers() async {
    final provider = context.read<AvailableDriversProvider>();

    try {
      await provider.loadDrivers(
        hireRequestId: widget.hireRequestId,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _filteredDrivers(
    List<Map<String, dynamic>> drivers,
  ) {
    List<Map<String, dynamic>> list = List.from(drivers);

    if (selectedFilter == 1) {
      list.sort(
        (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
      );
    } else if (selectedFilter == 2) {
      list.sort((a, b) {
        final aPrice = _extractPrice(a['price']);
        final bPrice = _extractPrice(b['price']);
        return aPrice.compareTo(bPrice);
      });
    } else if (selectedFilter == 3) {
      list.sort((a, b) {
        final aExp = _extractExperience(a['trips']);
        final bExp = _extractExperience(b['trips']);
        return bExp.compareTo(aExp);
      });
    }

    return list;
  }

  int _extractPrice(String price) {
    return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  int _extractExperience(String text) {
    return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _refreshDrivers() {
    _loadDrivers();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Drivers list refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _selectDriver(Map<String, dynamic> driver) async {
    final provider = context.read<AvailableDriversProvider>();

    final result = await provider.selectDriver(
      hireRequestId: widget.hireRequestId,
      driver: driver,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmBookingScreen(
            hireRequestId: widget.hireRequestId,
            selectedDriver: driver,
            selectedTrip: result['selectedTrip'] ?? {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to select driver'),
        ),
      );
    }
  }

  void _showDriverProfile(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: AppColors.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    driver['avatarInitial'] ?? 'D',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  driver['name'] ?? 'Driver',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB020),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${driver['rating'] ?? 0}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    if ((driver['apiBadge'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${driver['apiBadge']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text2(context),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.secondary.withOpacity(0.7)),
                const SizedBox(height: 10),
                _driverProfileRow(
                  Icons.directions_car_rounded,
                  'Vehicle',
                  driver['vehicleMakeModel'],
                ),
                _driverProfileRow(
                  Icons.confirmation_number_rounded,
                  'Plate',
                  driver['vehiclePlate'],
                ),
                _driverProfileRow(
                  Icons.phone_rounded,
                  'Phone',
                  driver['phone'],
                ),
                _driverProfileRow(
                  Icons.access_time_filled_rounded,
                  'ETA',
                  driver['eta'],
                ),
                _driverProfileRow(
                  Icons.payments_rounded,
                  'Fare',
                  driver['price'],
                ),
                _driverProfileRow(
                  Icons.work_history_rounded,
                  'Experience',
                  driver['experience'],
                ),
                _driverProfileRow(
                  Icons.local_taxi_rounded,
                  'Trips',
                  driver['trips'],
                ),
                _driverProfileRow(
                  Icons.language_rounded,
                  'Languages',
                  driver['languages'],
                ),
                _driverProfileRow(
                  Icons.verified_rounded,
                  'Status',
                  driver['status'],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _driverProfileRow(IconData icon, String title, dynamic value) {
    final textValue = (value == null || value.toString().trim().isEmpty)
        ? '-'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.text2(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              textValue,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.text1(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tripPickup(Map<String, dynamic>? selectedTrip) {
    return selectedTrip?['pickup']?['address'] ?? 'Pickup location';
  }

  String _tripDropoff(Map<String, dynamic>? selectedTrip) {
    return selectedTrip?['dropoff']?['address'] ?? 'Drop-off location';
  }

  String _tripDate(Map<String, dynamic>? selectedTrip) {
    return selectedTrip?['scheduledDate'] ?? '--/--/----';
  }

  String _tripTime(Map<String, dynamic>? selectedTrip) {
    return selectedTrip?['scheduledTime'] ?? '--:--';
  }

  String _tripVehicle(Map<String, dynamic>? selectedTrip) {
    return selectedTrip?['userVehicle']?['makeModel'] ?? 'Vehicle';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AvailableDriversProvider>(
      builder: (context, provider, _) {
        final driverList = _filteredDrivers(provider.drivers);

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  _buildTripSummaryCard(provider.selectedTrip),
                                  if (isMapView)
                                    _buildMapSection(provider.mapLabel),
                                  _buildControlsBar(),
                                  if (driverList.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Center(
                                        child: Text(
                                          'No drivers available',
                                          style: TextStyle(
                                            color: AppColors.text2(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        20,
                                      ),
                                      itemCount: driverList.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        return _buildDriverCard(
                                          driverList[index],
                                          provider.isSelectingDriver,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.bg(context),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
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
              'Available Drivers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text1(context),
              ),
            ),
          ),
          InkWell(
            onTap: _refreshDrivers,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(Map<String, dynamic>? selectedTrip) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Trip',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 28,
                      color: AppColors.secondary,
                    ),
                    Container(
                      height: 12,
                      width: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF7A30),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tripPickup(selectedTrip),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _tripDropoff(selectedTrip),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TripInfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: _tripDate(selectedTrip),
                ),
                _TripInfoChip(
                  icon: Icons.access_time_rounded,
                  label: _tripTime(selectedTrip),
                ),
                _TripInfoChip(
                  icon: Icons.directions_car_rounded,
                  label: _tripVehicle(selectedTrip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(String mapLabel) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      height: 220,
      width: double.infinity,
      color: AppColors.softBg(context),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 220),
            painter: _MiniMapPainter(
              backgroundColor: AppColors.softBg(context),
              roadColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.16)
                  : Colors.white.withOpacity(0.95),
              gridColor: AppColors.secondary.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.45,
              ),
            ),
          ),
          const Positioned(
            left: 55,
            top: 60,
            child: _DriverMapPin(
              color: Color(0xFF2F80ED),
              icon: Icons.local_taxi_rounded,
            ),
          ),
          const Positioned(
            left: 30,
            top: 120,
            child: _DriverMapPin(
              color: Color(0xFFFF7A2F),
              icon: Icons.location_on_rounded,
            ),
          ),
          const Positioned(
            right: 110,
            top: 105,
            child: _DriverMapPin(
              color: Color(0xFF2563EB),
              icon: Icons.local_taxi_rounded,
            ),
          ),
          const Positioned(
            right: 35,
            top: 52,
            child: _DriverMapPin(
              color: Color(0xFF19C37D),
              icon: Icons.local_taxi_rounded,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 8,
                      backgroundColor: Color(0xFF19C37D),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mapLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(
          top: BorderSide(color: AppColors.secondary.withOpacity(0.7)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final bool active = selectedFilter == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.primary : AppColors.card(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            active ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          index == 0
                              ? Icons.tune_rounded
                              : index == 1
                                  ? Icons.star_rounded
                                  : index == 2
                                      ? Icons.local_offer_rounded
                                      : Icons.workspace_premium_rounded,
                          size: 16,
                          color:
                              active ? Colors.white : AppColors.text2(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filters[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                active ? Colors.white : AppColors.text2(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _smallActionButton(
                    icon:
                        isMapView ? Icons.list_alt_rounded : Icons.map_rounded,
                    label: isMapView ? 'List View' : 'Map View',
                    onTap: () {
                      setState(() {
                        isMapView = !isMapView;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _smallActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Refresh',
                    onTap: _refreshDrivers,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard(
    Map<String, dynamic> driver,
    bool isSelectingDriver,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                child: ClipOval(
                  child: Container(
                    color: AppColors.softBg(context),
                    alignment: Alignment.center,
                    child: Text(
                      driver['avatarInitial'] ?? driver['name'][0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB020),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.card(context), width: 2),
                  ),
                  child: Text(
                    driver['badge'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        driver['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF55C27A),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${driver['experience']} · ${driver['trips']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text2(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  driver['languages'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text2(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _infoChip(
                      icon: Icons.access_time_filled_rounded,
                      text: driver['eta'],
                      bgColor: const Color(0xFFE8F0FF),
                      textColor: const Color(0xFF316BFF),
                    ),
                    _infoChip(
                      icon: Icons.payments_rounded,
                      text: driver['price'],
                      bgColor: const Color(0xFFE2F7EC),
                      textColor: const Color(0xFF19A567),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB020),
                          size: 18,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          driver['rating'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text1(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDriverProfile(driver),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'View Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSelectingDriver
                            ? null
                            : () {
                                _selectDriver(driver);
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSelectingDriver
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Select Driver',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TripInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.secondary.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text1(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverMapPin extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _DriverMapPin({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        Transform.rotate(
          angle: 0.78,
          child: Container(
            width: 12,
            height: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final Color backgroundColor;
  final Color roadColor;
  final Color gridColor;

  _MiniMapPainter({
    required this.backgroundColor,
    required this.roadColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bg);

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final road = Paint()
      ..color = roadColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    canvas.drawLine(
      Offset(0, size.height * 0.28),
      Offset(size.width, size.height * 0.28),
      road,
    );

    canvas.drawLine(
      Offset(size.width * 0.22, 0),
      Offset(size.width * 0.22, size.height),
      road,
    );

    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.18),
      Offset(size.width * 0.58, size.height),
      road,
    );

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.67),
      Offset(size.width * 0.92, size.height * 0.67),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.roadColor != roadColor ||
        oldDelegate.gridColor != gridColor;
  }
}