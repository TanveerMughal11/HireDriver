import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/provider/hire_monthly.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/screens/avaibledrivers.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
class MonthlyHireScreen extends StatefulWidget {
  final Map<String, dynamic> serviceOption;

  const MonthlyHireScreen({
    super.key,
    required this.serviceOption,
  });

  @override
  State<MonthlyHireScreen> createState() => _MonthlyHireScreenState();
}

class _MonthlyHireScreenState extends State<MonthlyHireScreen> {
  final TextEditingController pickupAreaController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? startDate;
  int selectedDuration = 1;
  int selectedHours = 8;

  final List<int> durationOptions = [1, 2, 3, 6];
  final List<int> hourOptions = [4, 6, 8, 12];
LatLng pickupLatLng = const LatLng(31.5204, 74.3587);

Timer? _searchDebounce;
bool _isSearchingPlaces = false;
List<_PlaceSuggestion> _placeSuggestions = [];
  @override
  void dispose() {
    pickupAreaController.dispose();
    notesController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
void _onPickupTextChanged(String value) {
  _searchDebounce?.cancel();

  if (value.trim().isEmpty) {
    setState(() {
      _placeSuggestions = [];
      _isSearchingPlaces = false;
    });
    return;
  }

  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
    _fetchPlaceSuggestions(value.trim());
  });
}

Future<void> _fetchPlaceSuggestions(String input) async {
  setState(() {
    _isSearchingPlaces = true;
  });

  try {
 final url = Uri.parse(
  'https://nominatim.openstreetmap.org/search'
  '?q=$input'
  '&format=json'
  '&addressdetails=1'
  '&limit=5'
  '&countrycodes=pk'
  '&accept-language=en',
);

final response = await http.get(
  url,
  headers: {
    'User-Agent': 'hire_driver_flutter_app',
    'Accept-Language': 'en',
  },
);

    if (response.statusCode != 200) {
      if (!mounted) return;
      setState(() {
        _placeSuggestions = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    final List data = jsonDecode(response.body);

    final results = data.map<_PlaceSuggestion>((item) {
      return _PlaceSuggestion(
        title: item['display_name']?.toString() ?? '',
        lat: double.tryParse(item['lat'].toString()),
        lng: double.tryParse(item['lon'].toString()),
      );
    }).where((e) {
      return e.title.isNotEmpty && e.lat != null && e.lng != null;
    }).toList();

    if (!mounted) return;

    setState(() {
      _placeSuggestions = results;
      _isSearchingPlaces = false;
    });
  } catch (_) {
    if (!mounted) return;
    setState(() {
      _placeSuggestions = [];
      _isSearchingPlaces = false;
    });
  }
}

void _selectPlaceSuggestion(_PlaceSuggestion suggestion) {
  if (suggestion.lat == null || suggestion.lng == null) return;

  setState(() {
    pickupLatLng = LatLng(suggestion.lat!, suggestion.lng!);
    pickupAreaController.text = suggestion.title;
    _placeSuggestions = [];
    _isSearchingPlaces = false;
  });

  FocusScope.of(context).unfocus();
}

Future<String> _getAddressFromLatLng(LatLng point) async {
  try {
    final placemarks = await geo.placemarkFromCoordinates(
      point.latitude,
      point.longitude,
    );

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      final parts = <String>[
        if ((p.name ?? '').trim().isNotEmpty) p.name!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
        if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
      ];

      if (parts.isNotEmpty) return parts.join(', ');
    }
  } catch (_) {}

  return '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
}

Future<LatLng?> _getCurrentLatLng() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enable location services')),
    );
    return null;
  }

  var permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location permission is required')),
    );
    return null;
  }

  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return LatLng(position.latitude, position.longitude);
}

Future<void> _useCurrentLocationForPickup() async {
  final point = await _getCurrentLatLng();
  if (point == null) return;

  final address = await _getAddressFromLatLng(point);

  if (!mounted) return;

  setState(() {
    pickupLatLng = point;
    pickupAreaController.text = address;
  });
}

Future<void> _openMapPicker() async {
  LatLng selectedPoint = pickupLatLng;

  final currentPoint = await _getCurrentLatLng();
  if (currentPoint != null) {
    selectedPoint = currentPoint;
  }

  if (!mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Pickup Area',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text1(context),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.text1(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedPoint,
                      initialZoom: 15.5,
                      onTap: (tapPosition, point) {
                        setSheetState(() {
                          selectedPoint = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.hire_driver',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedPoint,
                            width: 70,
                            height: 70,
                            child: const _GlowMapMarker(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        final address =
                            await _getAddressFromLatLng(selectedPoint);

                        if (!mounted) return;

                        setState(() {
                          pickupLatLng = selectedPoint;
                          pickupAreaController.text = address;
                        });

                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        'Save Location',
                        style: TextStyle(
                          color: AppColors.card(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
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
  Future<void> _createHireRequest(MonthlyHireProvider provider) async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date')),
      );
      return;
    }

    if (pickupAreaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup area')),
      );
      return;
    }

    final scheduledDate =
        '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';

    const scheduledTime = '09:00';

    final result = await provider.createHireRequest(
      serviceType: widget.serviceOption['id'],
      pickupAddress: pickupAreaController.text.trim(),
      dropoffAddress: pickupAreaController.text.trim(),
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AvailableDriversScreen(
            hireRequestId: result['hireRequestId'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error'),
        ),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkCard,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int _monthlyEstimate() {
    const ratePerHour = 120;
    const workingDays = 26;
    return selectedDuration * selectedHours * ratePerHour * workingDays;
  }

  @override
  Widget build(BuildContext context) {
    final estimate = _monthlyEstimate();

    return ChangeNotifierProvider(
      create: (_) => MonthlyHireProvider(),
      builder: (context, child) {
        final provider = context.watch<MonthlyHireProvider>();

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 18),
                        _buildSectionLabel('START DATE'),
                        const SizedBox(height: 8),
                        _buildDateField(),
                        const SizedBox(height: 18),
                        _buildSectionLabel('DURATION (MONTHS)'),
                        const SizedBox(height: 10),
                        Row(
                          children: durationOptions.map((month) {
                            final selected = selectedDuration == month;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right:
                                      month != durationOptions.last ? 10 : 0,
                                ),
                                child: _SelectionBox(
                                  label: '$month',
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      selectedDuration = month;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('DAILY WORKING HOURS'),
                        const SizedBox(height: 10),
                        Row(
                          children: hourOptions.map((hour) {
                            final selected = selectedHours == hour;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: hour != hourOptions.last ? 10 : 0,
                                ),
                                child: _SelectionBox(
                                  label: '${hour}h',
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      selectedHours = hour;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('PICKUP AREA'),
                        const SizedBox(height: 8),
_PickupAreaField(
  controller: pickupAreaController,
  hintText: 'Enter pickup area',
  onChanged: _onPickupTextChanged,
  onMapTap: _openMapPicker,
  onCurrentTap: _useCurrentLocationForPickup,
),

if (_isSearchingPlaces)
  const Padding(
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: AppColors.primary,
    ),
  ),

if (_placeSuggestions.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(top: 10),
    decoration: BoxDecoration(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: AppColors.secondary.withOpacity(0.6),
      ),
    ),
    child: Column(
      children: List.generate(_placeSuggestions.length, (index) {
        final item = _placeSuggestions[index];

        return InkWell(
          onTap: () => _selectPlaceSuggestion(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text1(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('NOTES TO DRIVER'),
                        const SizedBox(height: 8),
                        _NotesField(
                          controller: notesController,
                          hintText: 'Any timing, route, or work details...',
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.softBg(context),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.75),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MONTHLY ESTIMATE',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'PKR ',
                                    style: TextStyle(
                                      color: AppColors.text2(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    widget.serviceOption['monthlyRate'] != null
                                        ? '${widget.serviceOption['monthlyRate']}'
                                        : '$estimate',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$selectedDuration month · $selectedHours hrs/day · ${widget.serviceOption['rateLabel'] ?? '~PKR 120/hr'}',
                                style: TextStyle(
                                  color: AppColors.text2(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: AppColors.text2(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Includes: ',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'fuel negotiable, insurance optional',
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
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: provider.isSubmitting
                            ? null
                            : () => _createHireRequest(provider),
                        child: provider.isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Find Monthly Drivers →',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.card(context).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.7),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.text1(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.serviceOption['title'] ?? 'Monthly Hire',
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text1(context),
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickStartDate,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatDate(startDate),
                style: TextStyle(
                  color: startDate == null
                      ? AppColors.text2(context).withOpacity(0.8)
                      : AppColors.text1(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.text1(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.softBg(context)
              : AppColors.card(context).withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.secondary,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.text2(context),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _InputField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.text2(context).withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _NotesField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.text2(context).withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
class _PickupAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onMapTap;
  final VoidCallback onCurrentTap;

  const _PickupAreaField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onMapTap,
    required this.onCurrentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.text2(context).withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: AppColors.text1(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
const SizedBox(width: 8),

Column(
  children: [
    InkWell(
      onTap: onCurrentTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.softBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
          ),
        ),
        child: const Icon(
          Icons.gps_fixed_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    ),
    const SizedBox(height: 4),
    const Text(
      'Current',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    ),
  ],
),

const SizedBox(width: 10),

Column(
  children: [
    InkWell(
      onTap: onMapTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.softBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
          ),
        ),
        child: const Icon(
          Icons.map_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    ),
    const SizedBox(height: 4),
    const Text(
      'Map',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    ),
  ],
),

const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _GlowMapMarker extends StatefulWidget {
  const _GlowMapMarker();

  @override
  State<_GlowMapMarker> createState() => _GlowMapMarkerState();
}

class _GlowMapMarkerState extends State<_GlowMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
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
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 6,
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}

class _PlaceSuggestion {
  final String title;
  final double? lat;
  final double? lng;

  const _PlaceSuggestion({
    required this.title,
    this.lat,
    this.lng,
  });
}