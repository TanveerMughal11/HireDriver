import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/provider/roundtrip.dart';
import 'package:hire_driver/view/hiredriver/screens/avaibledrivers.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoundTripScreen extends StatefulWidget {
  final Map<String, dynamic> serviceOption;

  const RoundTripScreen({
    super.key,
    required this.serviceOption,
  });

  @override
  State<RoundTripScreen> createState() => _RoundTripScreenState();
}

class _RoundTripScreenState extends State<RoundTripScreen> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController vehiclePlateController = TextEditingController();

  DateTime? departureDate;
  TimeOfDay? departureTime;
  DateTime? returnDate;
  TimeOfDay? returnTime;
LatLng pickupLatLng = const LatLng(31.5204, 74.3587);
LatLng dropoffLatLng = const LatLng(31.5204, 74.3587);

Timer? _searchDebounce;
bool _isSearchingPlaces = false;
bool _isPickupSearching = true;
List<_PlaceSuggestion> _placeSuggestions = [];
  @override
  void dispose() {
    pickupController.dispose();
    _searchDebounce?.cancel();
    dropoffController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    vehiclePlateController.dispose();
    super.dispose();
  }
void _onLocationTextChanged({
  required String value,
  required bool isPickup,
}) {
  _searchDebounce?.cancel();

  if (value.trim().isEmpty) {
    setState(() {
      _placeSuggestions = [];
      _isSearchingPlaces = false;
    });
    return;
  }

  setState(() {
    _isPickupSearching = isPickup;
  });

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

  final point = LatLng(suggestion.lat!, suggestion.lng!);

  setState(() {
    if (_isPickupSearching) {
      pickupLatLng = point;
      pickupController.text = suggestion.title;
    } else {
      dropoffLatLng = point;
      dropoffController.text = suggestion.title;
    }

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
    pickupController.text = address;
  });
}

Future<void> _openMapPicker({required bool isPickup}) async {
  LatLng selectedPoint = isPickup ? pickupLatLng : dropoffLatLng;

  final currentPoint = await _getCurrentLatLng();
  if (currentPoint != null) selectedPoint = currentPoint;

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
                          isPickup
                              ? 'Select Pickup Location'
                              : 'Select Drop-off Location',
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
                            child: _GlowMapMarker(
                              color: isPickup
                                  ? AppColors.primary
                                  : const Color(0xFFFF7A30),
                              icon: isPickup
                                  ? Icons.my_location_rounded
                                  : Icons.place_rounded,
                            ),
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
                          if (isPickup) {
                            pickupLatLng = selectedPoint;
                            pickupController.text = address;
                          } else {
                            dropoffLatLng = selectedPoint;
                            dropoffController.text = address;
                          }
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
Future<void> _createHireRequest(RoundTripProvider provider) async {
  if (departureDate == null || departureTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select departure date and time')),
    );
    return;
  }

  if (returnDate == null || returnTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select return date and time')),
    );
    return;
  }

  if (pickupController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter pickup location')),
    );
    return;
  }

  if (dropoffController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter drop-off location')),
    );
    return;
  }

  final scheduledDate =
      '${departureDate!.year}-${departureDate!.month.toString().padLeft(2, '0')}-${departureDate!.day.toString().padLeft(2, '0')}';

  final scheduledTime =
      '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}';

  final result = await provider.createHireRequest(
    serviceType: widget.serviceOption['id'],
    pickupAddress: pickupController.text.trim(),
    dropoffAddress: dropoffController.text.trim(),
    scheduledDate: scheduledDate,
    scheduledTime: scheduledTime,
    vehicleModel: vehicleModelController.text.trim(),
    vehicleColor: vehicleColorController.text.trim(),
    plateNumber: vehiclePlateController.text.trim(),
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
        content: Text(result['message'] ?? 'Something went wrong'),
      ),
    );
  }
}

  Future<void> _pickDepartureDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: departureDate ?? now,
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
        departureDate = picked;
        if (returnDate != null && returnDate!.isBefore(picked)) {
          returnDate = picked;
        }
      });
    }
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: departureTime ?? TimeOfDay.now(),
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
        departureTime = picked;
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final now = departureDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: returnDate ?? now,
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
        returnDate = picked;
      });
    }
  }

  Future<void> _pickReturnTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: returnTime ?? TimeOfDay.now(),
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
        returnTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:-- --';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
return ChangeNotifierProvider(
  create: (_) => RoundTripProvider(),
  builder: (context, child) {
    final provider = context.watch<RoundTripProvider>();

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
                          const SizedBox(height: 16),
                          _buildLocationCard(),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _PickerField(
                                  title: 'DATE',
                                  value: _formatDate(departureDate),
                                  icon: Icons.calendar_today_outlined,
                                  onTap: _pickDepartureDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickerField(
                                  title: 'TIME',
                                  value: _formatTime(departureTime),
                                  icon: Icons.access_time_rounded,
                                  onTap: _pickDepartureTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _PickerField(
                                  title: 'RETURN DATE',
                                  value: _formatDate(returnDate),
                                  icon: Icons.event_repeat_rounded,
                                  onTap: _pickReturnDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickerField(
                                  title: 'RETURN TIME',
                                  value: _formatTime(returnTime),
                                  icon: Icons.schedule_rounded,
                                  onTap: _pickReturnTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildSectionLabel('YOUR VEHICLE'),
                          const SizedBox(height: 10),
                          _InputField(
                            controller: vehicleModelController,
                            hintText: 'Vehicle model',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  controller: vehicleColorController,
                                  hintText: 'Color',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InputField(
                                  controller: vehiclePlateController,
                                  hintText: 'Plate number',
                                ),
                              ),
                            ],
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'FARE ESTIMATE',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Same as One-Way + return trip timing included',
                                        style: TextStyle(
                                          color: AppColors.text2(context),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.serviceOption['rateLabel'] ??
                                      'PKR 350-500',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
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
                                  'Find Available Drivers →',
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
          widget.serviceOption['title'] ?? 'Round Trip',
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

Widget _buildLocationCard() {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.7),
          ),
        ),
        child: Column(
          children: [
            _LocationRow(
              label: 'PICKUP',
              controller: pickupController,
              dotColor: AppColors.primary,
              hintText: 'Select pickup location',
              icon: Icons.my_location_rounded,
              onCurrentTap: _useCurrentLocationForPickup,
              onMapTap: () => _openMapPicker(isPickup: true),
              onChanged: (value) => _onLocationTextChanged(
                value: value,
                isPickup: true,
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.secondary.withOpacity(0.7),
            ),
            _LocationRow(
              label: 'DROP-OFF',
              controller: dropoffController,
              dotColor: const Color(0xFFFF7A30),
              hintText: 'Enter destination...',
              icon: Icons.place_rounded,
              onCurrentTap: null,
              onMapTap: () => _openMapPicker(isPickup: false),
              onChanged: (value) => _onLocationTextChanged(
                value: value,
                isPickup: false,
              ),
            ),
          ],
        ),
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
                      Icon(
                        Icons.location_on_rounded,
                        color: _isPickupSearching
                            ? AppColors.primary
                            : const Color(0xFFFF7A30),
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
}

class _LocationRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color dotColor;
  final String hintText;
  final IconData icon;
  final VoidCallback? onCurrentTap;
  final VoidCallback onMapTap;
  final ValueChanged<String> onChanged;

  const _LocationRow({
    required this.label,
    required this.controller,
    required this.dotColor,
    required this.hintText,
    required this.icon,
    required this.onCurrentTap,
    required this.onMapTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: dotColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.text2(context).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
const SizedBox(width: 8),

if (onCurrentTap != null) ...[
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
              color: dotColor.withOpacity(0.25),
            ),
          ),
          child: Icon(
            Icons.gps_fixed_rounded,
            color: dotColor,
            size: 22,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Current',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: dotColor,
        ),
      ),
    ],
  ),

  const SizedBox(width: 10),
],

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
            color: dotColor.withOpacity(0.25),
          ),
        ),
        child: Icon(
          Icons.map_rounded,
          color: dotColor,
          size: 22,
        ),
      ),
    ),
    const SizedBox(height: 4),
    Text(
      'Map',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: dotColor,
      ),
    ),
  ],
),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    value,
                    style: TextStyle(
                      color: value.contains('mm') || value.contains('--')
                          ? AppColors.text2(context).withOpacity(0.8)
                          : AppColors.text1(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 19,
                  color: AppColors.text1(context),
                ),
              ],
            ),
          ),
        ),
      ],
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
      height: 54,
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
            vertical: 15,
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
class _GlowMapMarker extends StatefulWidget {
  final Color color;
  final IconData icon;

  const _GlowMapMarker({
    required this.color,
    required this.icon,
  });

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
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
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