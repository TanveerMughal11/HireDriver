import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book a ride/provider/set_price.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/offerrider.dart';
import 'package:provider/provider.dart';

class SetYourPriceScreen extends StatefulWidget {
  final Map<String, dynamic> previewBooking;
  final String selectedVehicleType;

  const SetYourPriceScreen({
    super.key,
    required this.previewBooking,
    required this.selectedVehicleType,
  });

  @override
  State<SetYourPriceScreen> createState() => _SetYourPriceScreenState();
}

class _SetYourPriceScreenState extends State<SetYourPriceScreen> {
  final TextEditingController promoController = TextEditingController();

  List<Map<String, dynamic>> get vehicleOptions {
    final options = widget.previewBooking['vehicleOptions'];
    if (options is List) {
      return options.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Map<String, dynamic> get selectedVehicleOption {
    final found = vehicleOptions.where(
      (e) => e['type'] == widget.selectedVehicleType,
    );

    if (found.isNotEmpty) return found.first;
    if (vehicleOptions.isNotEmpty) return vehicleOptions.first;

    return {
      'type': widget.selectedVehicleType,
      'label': 'Car',
      'minFare': 280,
      'suggestedFare': 350,
      'maxFare': 480,
      'currency': 'PKR',
    };
  }

  Map<String, dynamic> get pickup =>
      Map<String, dynamic>.from(widget.previewBooking['pickup'] ?? {});

  Map<String, dynamic> get dropoff =>
      Map<String, dynamic>.from(widget.previewBooking['dropoff'] ?? {});

  Map<String, dynamic> get route =>
      Map<String, dynamic>.from(widget.previewBooking['route'] ?? {});

  String get tripType =>
      widget.previewBooking['tripType']?.toString() ?? 'one-way';

  String get vehicleLabel =>
      selectedVehicleOption['label']?.toString() ?? 'Car';

  double get distanceKm {
    final value = route['distanceKm'];
    if (value is num) return value.toDouble();
    return 0.0;
  }

  int get durationMinutes {
    final value = route['durationMinutes'];
    if (value is num) return value.toInt();
    return 0;
  }

  String get pickupAddress =>
      pickup['address']?.toString() ?? 'Current Location';

  String get dropoffAddress =>
      dropoff['address']?.toString() ?? 'Destination';

  int get suggestedFare =>
      (selectedVehicleOption['suggestedFare'] as num?)?.toInt() ?? 350;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<SetPriceProvider>();
      provider.initFare(selectedVehicleOption);

      final savedCode = await provider.loadAppliedPromo();

      if (!mounted) return;
      promoController.text = savedCode;
    });
  }

  @override
  void dispose() {
    promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode() async {
    final provider = context.read<SetPriceProvider>();
    await provider.applyPromoCode(promoController.text);
  }

  Future<void> _createRideAndGoToOffers() async {
    final provider = context.read<SetPriceProvider>();

    final result = await provider.createRide(
      pickup: pickup,
      dropoff: dropoff,
      tripType: tripType,
      vehicleType:
          selectedVehicleOption['type']?.toString() ?? widget.selectedVehicleType,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      final ride = data['ride'];
      final rideId = ride?['id']?.toString();

      if (rideId == null || rideId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride ID not found')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverOffersScreen(
            rideId: rideId,
            offeredFare: provider.finalFare,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Ride create failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SetPriceProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: AppColors.softBg(context),
                        borderRadius: BorderRadius.circular(14),
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
                    "Set Your Price",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// LOCATION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(3),
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
                                pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text1(context),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                dropoffAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text1(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(color: AppColors.grey),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _TripInfo(
                          icon: Icons.straighten,
                          label: "~${distanceKm.toStringAsFixed(1)} km",
                        ),
                        _TripInfo(
                          icon: Icons.access_time,
                          label: "~$durationMinutes min",
                        ),
                        _TripInfo(
                          icon: Icons.local_taxi,
                          label: vehicleLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                "Suggested Fares",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1(context),
                ),
              ),

              const SizedBox(height: 14),

              /// FARE CARDS
              Row(
                children: [
                  Expanded(
                    child: FareCard(
                      price: "Rs${provider.minFare}",
                      title: "Economy",
                      subtitle: "More drivers",
                      selected: provider.selectedFare == provider.minFare,
                      onTap: () => provider.selectFare(provider.minFare),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FareCard(
                      price: "Rs$suggestedFare",
                      title: "Suggested",
                      subtitle: "Recommended",
                      selected: provider.selectedFare == suggestedFare,
                      onTap: () => provider.selectFare(suggestedFare),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FareCard(
                      price: "Rs${provider.maxFare}",
                      title: "Premium",
                      subtitle: "Fastest match",
                      selected: provider.selectedFare == provider.maxFare,
                      onTap: () => provider.selectFare(provider.maxFare),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// MARKET RANGE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "MARKET RANGE",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text2(context),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Good match rate",
                              style: TextStyle(
                                color: AppColors.text1(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            color: AppColors.grey,
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 6,
                            width: MediaQuery.of(context).size.width *
                                0.75 *
                                provider.rangeValue,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "PKR ${provider.minFare}",
                          style: TextStyle(color: AppColors.text1(context)),
                        ),
                        const Spacer(),
                        Text(
                          "PKR ${provider.maxFare}",
                          style: TextStyle(color: AppColors.text1(context)),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// PROMO CODE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Promo Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promoController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: "Paste code here",
                              filled: true,
                              fillColor: AppColors.softBg(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _applyPromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Apply"),
                        ),
                      ],
                    ),
                    if (provider.promoMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.promoMessage,
                        style: TextStyle(
                          color:
                              provider.promoApplied ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// CUSTOM PRICE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Text(
                      "PKR ",
                      style: TextStyle(
                        color: AppColors.text2(context),
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${provider.finalFare}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text1(context),
                      ),
                    ),
                    if (provider.promoApplied) ...[
                      const SizedBox(width: 10),
                      Text(
                        "was ${provider.selectedFare}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.text2(context),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed:
                      provider.isCreatingRide ? null : _createRideAndGoToOffers,
                  child: provider.isCreatingRide
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          " Broadcast Offer of PKR ${provider.finalFare}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
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

class _TripInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TripInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: AppColors.text2(context)),
        ),
      ],
    );
  }
}

class FareCard extends StatelessWidget {
  final String price;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const FareCard({
    super.key,
    required this.price,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selected ? AppColors.primary : AppColors.text1(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.text1(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text2(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}