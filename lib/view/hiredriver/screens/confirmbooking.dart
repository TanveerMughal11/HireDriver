import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';

import 'package:hire_driver/view/hiredriver/provider/confirmbooking.dart';
import 'package:hire_driver/view/hiredriver/screens/waitinfdriveracceptance.dart';
import 'package:provider/provider.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final String hireRequestId;
  final Map<String, dynamic> selectedDriver;
  final Map<String, dynamic> selectedTrip;

  const ConfirmBookingScreen({
    super.key,
    required this.hireRequestId,
    required this.selectedDriver,
    required this.selectedTrip,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  int selectedPaymentIndex = 2;
  final TextEditingController promoController =
      TextEditingController(text: 'FIRST25');

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'jazzcash',
      'title': 'JazzCash',
      'subtitle': '0300-XXXXXXX',
      'icon': Icons.circle,
      'iconColor': const Color(0xFFFF8A50),
    },
    {
      'id': 'easypaisa',
      'title': 'EasyPaisa',
      'subtitle': '0312-XXXXXXX',
      'icon': Icons.circle,
      'iconColor': const Color(0xFF63D98B),
    },
    {
      'id': 'cash',
      'title': 'Cash',
      'subtitle': 'Pay on arrival',
      'icon': Icons.payments_rounded,
      'iconColor': const Color(0xFF27C46B),
    },
    {
      'id': 'wallet',
      'title': 'HD Wallet',
      'subtitle': 'PKR 3,250 available',
      'icon': Icons.credit_card_rounded,
      'iconColor': const Color(0xFF3BA7FF),
    },
  ];

  @override
  void dispose() {
    promoController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking(BuildContext context) async {
    final provider = context.read<ConfirmBookingProvider>();
    final selectedPayment = paymentMethods[selectedPaymentIndex];

    final result = await provider.confirmBooking(
      hireRequestId: widget.hireRequestId,
      paymentMethod: selectedPayment['id'],
      promoCode: promoController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AwaitingDriverAcceptanceScreen(
            waitingState: result['waitingState'] ?? {},
            hireRequest: result['hireRequest'] ?? {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to confirm booking'),
        ),
      );
    }
  }

  String _pickup() {
    return widget.selectedTrip['pickup']?['address'] ?? 'Pickup location';
  }

  String _dropoff() {
    return widget.selectedTrip['dropoff']?['address'] ?? 'Drop-off location';
  }

  String _time() {
    return widget.selectedTrip['scheduledTime'] ?? '--:--';
  }

  String _vehicle() {
    return widget.selectedTrip['userVehicle']?['makeModel'] ??
        widget.selectedDriver['vehicleMakeModel'] ??
        'Vehicle';
  }

  double _totalFare() {
    return double.tryParse(
          widget.selectedDriver['price']
              .toString()
              .replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final double totalFare = _totalFare();

    return ChangeNotifierProvider(
      create: (_) => ConfirmBookingProvider(),
      child: Consumer<ConfirmBookingProvider>(
        builder: (context, provider, _) {
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
                          _buildTripSummaryCard(totalFare),
                          const SizedBox(height: 16),
                          _buildDriverInfoCard(),
                          const SizedBox(height: 16),
                          _buildPaymentMethodCard(),
                          const SizedBox(height: 16),
                          _buildPromoCard(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isConfirming
                            ? null
                            : () => _confirmBooking(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: provider.isConfirming
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Confirm & Pay PKR ${totalFare.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
        Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.text1(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTripSummaryCard(double totalFare) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 18),
          _SummaryRow(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFFF5B8A),
            label: 'Pickup',
            value: _pickup(),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFF6E6E6E),
            label: 'Drop-off',
            value: _dropoff(),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.access_time_filled_rounded,
            iconColor: const Color(0xFF8E7CF7),
            label: 'Time',
            value: _time(),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF4B8DFF),
            label: 'Driver',
            value:
                '${widget.selectedDriver['name']} · ${widget.selectedDriver['rating']} ⭐',
          ),
          const SizedBox(height: 14),
          const _SummaryRow(
            icon: Icons.straighten_rounded,
            iconColor: Color(0xFF8B8FA8),
            label: 'Distance',
            value: '~12.4 km',
          ),
          const SizedBox(height: 14),
          const _SummaryRow(
            icon: Icons.timer_outlined,
            iconColor: Color(0xFFFF9D42),
            label: 'Est. Duration',
            value: '~45 minutes',
          ),
          const SizedBox(height: 18),
          Divider(color: AppColors.secondary.withOpacity(0.6), height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Base fare',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text2(context),
                ),
              ),
              const Spacer(),
              Text(
                'PKR ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text2(context),
                ),
              ),
              Text(
                totalFare.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text1(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.secondary.withOpacity(0.6), height: 1),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text1(context),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'PKR ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2(context),
                  ),
                ),
              ),
              Text(
                totalFare.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2F63E8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF756BB1), Color(0xFF4B3F99)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.selectedDriver['avatarInitial'] ?? 'D',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedDriver['name'] ?? 'Driver',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verified Driver · ${widget.selectedDriver['trips']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text2(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.selectedDriver['vehicleMakeModel'] ?? _vehicle()} · ${widget.selectedDriver['vehiclePlate'] ?? ''}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text2(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFFB020),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.selectedDriver['rating'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paymentMethods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = paymentMethods[index];
              final bool isSelected = selectedPaymentIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPaymentIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softBg(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2F63E8)
                          : AppColors.secondary.withOpacity(0.7),
                      width: isSelected ? 1.8 : 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        size: 22,
                        color: item['iconColor'],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text2(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promo Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text1(context),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.softBg(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.7),
                    ),
                  ),
                  child: TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(
                        color: AppColors.text2(context).withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    style: TextStyle(
                      color: AppColors.text1(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF2F63E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text(
                '💡',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(width: 6),
              Text(
                'Try: FIRST25',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F63E8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 14),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.text2(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
        ),
      ],
    );
  }
}