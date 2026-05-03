import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book a ride/provider/book_a_ride.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/set_price.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/setprice.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BookRideScreen extends StatelessWidget {
  const BookRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookRideProvider(),
      child: const _BookRideScreenBody(),
    );
  }
}

class _BookRideScreenBody extends StatefulWidget {
  const _BookRideScreenBody();

  @override
  State<_BookRideScreenBody> createState() => _BookRideScreenBodyState();
}

class _BookRideScreenBodyState extends State<_BookRideScreenBody> {
  static const String _googleApiKey =
      'AIzaSyAVwtrR0dOb-BqWXdqTrvixlYh-TTV5Sj4';

  final Completer<GoogleMapController> _mapController = Completer();

  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();

  LatLng _mapCenter = const LatLng(31.5204, 74.3587);

  bool _isGettingCurrentLocation = false;
  bool _isSearchingPlaces = false;
  bool _isSearchMode = false;
  bool _isBottomSheetExpanded = false;

  Timer? _debounce;
  List<_PlaceSuggestion> _suggestions = [];

  final List<_VehicleItem> vehicles = const [
    _VehicleItem(
      type: 'bike',
      title: 'Bike',
      price: 'PKR 80–120',
      eta: '5 min',
      icon: Icons.moped_rounded,
    ),
    _VehicleItem(
      type: 'auto',
      title: 'Auto',
      price: 'PKR 120–180',
      eta: '4 min',
      icon: Icons.electric_rickshaw_rounded,
    ),
    _VehicleItem(
      type: 'mini',
      title: 'Mini',
      price: 'PKR 180–250',
      eta: '3 min',
      icon: Icons.directions_car_rounded,
    ),
    _VehicleItem(
      type: 'sedan',
      title: 'Sedan',
      price: 'PKR 250–350',
      eta: '3 min',
      icon: Icons.local_taxi_rounded,
    ),
    _VehicleItem(
      type: 'suv',
      title: 'SUV',
      price: 'PKR 400–600',
      eta: '6 min',
      icon: Icons.airport_shuttle_rounded,
    ),
    _VehicleItem(
      type: 'premium',
      title: 'Premium',
      price: 'PKR 600–900',
      eta: '5 min',
      icon: Icons.star_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _destinationFocusNode.addListener(() {
      if (!mounted) return;
      setState(() {
        if (!_destinationFocusNode.hasFocus &&
            _destinationController.text.trim().isEmpty) {
          _isSearchMode = false;
        }
        if (!_destinationFocusNode.hasFocus) {
          _suggestions = [];
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  Widget _buildMainLayout() {
    final provider = context.watch<BookRideProvider>();

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Stack(
            children: [
              if (!_isBottomSheetExpanded)
                Positioned.fill(
                  child: _RideMapPreview(
                    mapCenter: _mapCenter,
                    pickupLatLng: provider.pickupLatLng,
                    destinationLatLng: provider.destinationLatLng,
                    onMapCreated: (controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                  ),
                ),
              Positioned(
                left: 14,
                right: 14,
                top: 20,
                child: _LocationCard(
                  pickupText: provider.pickupText,
                  destinationText: provider.destinationText,
                  isGettingCurrentLocation: _isGettingCurrentLocation,
                  onPickupTap: _useCurrentLocation,
                  onDestinationTap: _openSearch,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBottomSheetExpanded = !_isBottomSheetExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    height: _isBottomSheetExpanded
                        ? MediaQuery.of(context).size.height * 0.65
                        : 270,
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
                    decoration: BoxDecoration(
                      color: AppColors.bg(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBottomSheetExpanded =
                                    !_isBottomSheetExpanded;
                              });
                            },
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: _isBottomSheetExpanded ? 0.5 : 0,
                              child: Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildTripTypeRow(),
                        const SizedBox(height: 18),
                        Text(
                          'Vehicle Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text1(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: _buildVehicleRow(),
                        ),
                        const SizedBox(height: 18),
                        _buildOfferButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchLayout() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 72),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _SuggestionsCard(
                suggestions: _suggestions,
                onSuggestionTap: _selectSuggestion,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _animateToLocation(LatLng target) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15.5),
      ),
    );
  }

  void _openSearch() {
    setState(() {
      _isSearchMode = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _destinationFocusNode.requestFocus();
      _destinationController.selection = TextSelection.fromPosition(
        TextPosition(offset: _destinationController.text.length),
      );
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearchMode = false;
      _suggestions = [];
    });
    _destinationFocusNode.unfocus();
  }

  Future<void> _useCurrentLocation() async {
    if (_isGettingCurrentLocation) return;

    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Please enable location services.');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('Location permission is required.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      String locationName = 'Current Location';

      try {
        final placemarks = await geo.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if ((p.name ?? '').trim().isNotEmpty) p.name!.trim(),
            if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          ];
          if (parts.isNotEmpty) {
            locationName = parts.join(', ');
          }
        }
      } catch (_) {}

      if (!mounted) return;

      context.read<BookRideProvider>().setPickup(
            latLng: currentLatLng,
            address: locationName,
            placeId: '',
          );

      setState(() {
        _mapCenter = currentLatLng;
      });

      await _animateToLocation(currentLatLng);
    } catch (_) {
      _showMessage('Unable to fetch current location.');
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  void _onDestinationChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _fetchPlaceSuggestions(value.trim());
    });
  }

  Future<void> _fetchPlaceSuggestions(String input) async {
    setState(() {
      _isSearchingPlaces = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey,
          'X-Goog-FieldMask':
              'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text,suggestions.placePrediction.structuredFormat.mainText.text,suggestions.placePrediction.structuredFormat.secondaryText.text',
        },
        body: jsonEncode({
          'input': input,
          'languageCode': 'en',
          'regionCode': 'PK',
        }),
      );

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _isSearchingPlaces = false;
        });
        _showMessage('Place suggestions not loading. Enable Places API.');
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List rawSuggestions = data['suggestions'] ?? [];

      final results = rawSuggestions
          .map<_PlaceSuggestion?>((item) {
            final placePrediction = item['placePrediction'];
            if (placePrediction == null) return null;

            final placeId = placePrediction['placeId']?.toString() ?? '';
            final mainText =
                placePrediction['structuredFormat']?['mainText']?['text']
                        ?.toString() ??
                    placePrediction['text']?['text']?.toString() ??
                    '';
            final secondaryText =
                placePrediction['structuredFormat']?['secondaryText']?['text']
                        ?.toString() ??
                    '';

            if (mainText.isEmpty) return null;

            return _PlaceSuggestion(
              placeId: placeId,
              title: mainText,
              subtitle: secondaryText,
            );
          })
          .whereType<_PlaceSuggestion>()
          .toList();

      if (!mounted) return;

      setState(() {
        _suggestions = results;
        _isSearchingPlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isSearchingPlaces = false;
      });
    }
  }

  Future<void> _selectSuggestion(_PlaceSuggestion suggestion) async {
    _destinationController.text = suggestion.fullText;

    setState(() {
      _suggestions = [];
      _isSearchingPlaces = false;
      _isSearchMode = false;
    });

    _destinationFocusNode.unfocus();

    try {
      final response = await http.get(
        Uri.parse(
          'https://places.googleapis.com/v1/places/${suggestion.placeId}'
          '?fields=id,displayName,formattedAddress,location',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey,
        },
      );

      if (response.statusCode != 200) {
        _showMessage('Place details not loading. Enable Places API.');
        return;
      }

      final data = jsonDecode(response.body);
      final location = data['location'];

      if (location == null ||
          location['latitude'] == null ||
          location['longitude'] == null) {
        _showMessage('Could not get place location.');
        return;
      }

      final selectedLatLng = LatLng(
        (location['latitude'] as num).toDouble(),
        (location['longitude'] as num).toDouble(),
      );

      final destinationAddress =
          data['formattedAddress']?.toString() ?? suggestion.fullText;

      if (!mounted) return;

 context.read<BookRideProvider>().setDestination(
            latLng: selectedLatLng,
            address: destinationAddress,
            placeId: suggestion.placeId,
          );

      setState(() {
        _mapCenter = selectedLatLng;
      });

      await _animateToLocation(selectedLatLng);
    } catch (e) {
      _showMessage('Could not find this location on map.');
    }
  }

  void _openManualLocationDialog() {
    final addressController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Manual Location"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    hintText: "Address name",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: latController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Latitude example: 31.5138",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lngController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Longitude example: 74.3308",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final address = addressController.text.trim();
                final lat = double.tryParse(latController.text.trim());
                final lng = double.tryParse(lngController.text.trim());

                if (address.isEmpty || lat == null || lng == null) {
                  _showMessage("Please enter valid address, lat and lng");
                  return;
                }

                final manualLatLng = LatLng(lat, lng);

       this.context.read<BookRideProvider>().setDestination(
  latLng: manualLatLng,
  address: address,
  placeId: "manual",
);

setState(() {
  _destinationController.text = address;
  _mapCenter = manualLatLng;
  _isSearchMode = false;
  _suggestions = [];
});

if (!mounted) return;
Navigator.pop(context);
              },
              child: const Text("Use Location"),
            ),
          ],
        );
      },
    );
  }

Future<void> _previewRideAndOpenSetPrice() async {
  final provider = context.read<BookRideProvider>();

  final result = await provider.previewRide();

  if (!mounted) return;

  if (result['success'] == true) {
    final data = result['data'];
    final booking = data['booking'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => SetPriceProvider(),
          child: SetYourPriceScreen(
            previewBooking: booking,
            selectedVehicleType: vehicles[provider.selectedVehicle].type,
          ),
        ),
      ),
    );
  } else {
    _showMessage(result['message'] ?? 'Ride preview failed');
  }
}

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.card(context).withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.55),
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
            _isSearchMode ? 'Search Destination' : 'Book a Ride',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.45),
          ),
        ),
        child: TextField(
          controller: _destinationController,
          focusNode: _destinationFocusNode,
          onChanged: _onDestinationChanged,
          autofocus: true,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.text1(context),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Where to go?',
            hintStyle: TextStyle(
              color: AppColors.text2(context),
              fontSize: 15,
            ),
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: _isSearchingPlaces
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _openManualLocationDialog,
                        icon: const Icon(
                          Icons.edit_location_alt_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: _closeSearch,
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.text2(context),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripTypeRow() {
    final provider = context.watch<BookRideProvider>();

    return Row(
      children: [
        Expanded(
          child: _TripTypeChip(
            title: 'One-Way',
            active: !provider.isReturn,
            onTap: () {
              provider.changeTripType(false);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TripTypeChip(
            title: 'Return',
            active: provider.isReturn,
            onTap: () {
              provider.changeTripType(true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleRow() {
    final provider = context.watch<BookRideProvider>();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          final isSelected = provider.selectedVehicle == index;

          return GestureDetector(
            onTap: () {
              provider.changeVehicle(index);
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: 10,
                left: index == 0 ? 2 : 0,
              ),
              child: SizedBox(
                width: 110,
                child: _VehicleCard(
                  vehicle: vehicle,
                  selected: isSelected,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferButton() {
    final provider = context.watch<BookRideProvider>();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            provider.isPreviewLoading ? null : _previewRideAndOpenSetPrice,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: provider.isPreviewLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Set My Price Offer',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _isSearchMode ? _buildSearchLayout() : _buildMainLayout(),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              left: 14,
              right: 14,
              top: _isSearchMode ? 70 : MediaQuery.of(context).size.height,
              child: Material(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isSearchMode ? 1 : 0,
                  child: _buildTopSearchField(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideMapPreview extends StatelessWidget {
  final LatLng mapCenter;
  final LatLng pickupLatLng;
  final LatLng? destinationLatLng;
  final ValueChanged<GoogleMapController> onMapCreated;

  const _RideMapPreview({
    required this.mapCenter,
    required this.pickupLatLng,
    required this.destinationLatLng,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: mapCenter,
          zoom: 14.8,
        ),
        onMapCreated: onMapCreated,
        markers: {
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
          ),
          if (destinationLatLng != null)
            Marker(
              markerId: const MarkerId('dropoff'),
              position: destinationLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        mapToolbarEnabled: false,
        compassEnabled: false,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        indoorViewEnabled: false,
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String pickupText;
  final String destinationText;
  final bool isGettingCurrentLocation;
  final VoidCallback onPickupTap;
  final VoidCallback onDestinationTap;

  const _LocationCard({
    required this.pickupText,
    required this.destinationText,
    required this.isGettingCurrentLocation,
    required this.onPickupTap,
    required this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              InkWell(
                onTap: onPickupTap,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: isGettingCurrentLocation
                      ? const Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                ),
              ),
              Container(
                width: 2,
                height: 42,
                color: AppColors.secondary,
              ),
              Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A3D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onPickupTap,
                  child: Text(
                    pickupText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1(context),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: onDestinationTap,
                  child: Text(
                    destinationText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: destinationText == 'Where to go?'
                          ? AppColors.text2(context)
                          : AppColors.text1(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onDestinationTap,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFE64980),
                  size: 18,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 34,
                width: 34,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  final List<_PlaceSuggestion> suggestions;
  final ValueChanged<_PlaceSuggestion> onSuggestionTap;

  const _SuggestionsCard({
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.45),
          ),
        ),
        child: Text(
          'No relevant locations found',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.text2(context),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: List.generate(suggestions.length, (index) {
          final suggestion = suggestions[index];

          return Column(
            children: [
              InkWell(
                onTap: () => onSuggestionTap(suggestion),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: AppColors.softBg(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.place_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1(context),
                              ),
                            ),
                            if (suggestion.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                suggestion.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text2(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index != suggestions.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: AppColors.secondary.withOpacity(0.28),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _TripTypeChip extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _TripTypeChip({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: active
              ? AppColors.softBg(context)
              : AppColors.card(context).withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.secondary,
            width: active ? 1.8 : 1.2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.text2(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final _VehicleItem vehicle;
  final bool selected;

  const _VehicleCard({
    required this.vehicle,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withOpacity(.12)
            : AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.secondary,
          width: selected ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            vehicle.icon,
            size: 28,
            color: selected ? AppColors.primary : AppColors.text2(context),
          ),
          const SizedBox(height: 8),
          Text(
            vehicle.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color:
                  selected ? AppColors.text1(context) : AppColors.text2(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.price,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.eta,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.text2(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleItem {
  final String type;
  final String title;
  final String price;
  final String eta;
  final IconData icon;

  const _VehicleItem({
    required this.type,
    required this.title,
    required this.price,
    required this.eta,
    required this.icon,
  });
}

class _PlaceSuggestion {
  final String placeId;
  final String title;
  final String subtitle;

  const _PlaceSuggestion({
    required this.placeId,
    required this.title,
    required this.subtitle,
  });

  String get fullText {
    if (subtitle.isEmpty) return title;
    return '$title, $subtitle';
  }
}