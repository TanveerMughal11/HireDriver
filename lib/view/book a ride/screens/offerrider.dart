import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/offerrider.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/drivercomingtoyou.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/drivertravling.dart';
import 'package:provider/provider.dart';

class DriverOffersScreen extends StatefulWidget {
  final String rideId;
  final int offeredFare;

  const DriverOffersScreen({
    super.key,
    required this.rideId,
    required this.offeredFare,
  });

  @override
  State<DriverOffersScreen> createState() => _DriverOffersScreenState();
}

class _DriverOffersScreenState extends State<DriverOffersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<DriverOffersProvider>();
      provider.startCountdown();
      _broadcastRide();
    });
  }

  Future<void> _broadcastRide() async {
    final provider = context.read<DriverOffersProvider>();

    final result = await provider.broadcastRide(
      rideId: widget.rideId,
    );

    if (!mounted) return;

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Ride broadcast failed'),
        ),
      );
    }
  }

  String _offerId(Map<String, dynamic> item) {
    return item['_id']?.toString() ?? '';
  }

  Future<void> _acceptOffer(Map<String, dynamic> item) async {
    final offerId = _offerId(item);

    if (offerId.isEmpty) {
      _showMessage('Offer ID not found');
      return;
    }

    final provider = context.read<DriverOffersProvider>();

    final result = await provider.acceptOffer(
      rideId: widget.rideId,
      offerId: offerId,
    );

    if (!mounted) return;

    _showMessage(result['message'] ?? 'Offer accepted');

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverComingScreen(),
        ),
      );
    }
  }

  Future<void> _declineOffer(Map<String, dynamic> item) async {
    final offerId = _offerId(item);

    if (offerId.isEmpty) {
      _showMessage('Offer ID not found');
      return;
    }

    final provider = context.read<DriverOffersProvider>();

    final result = await provider.declineOffer(
      rideId: widget.rideId,
      offerId: offerId,
    );

    if (!mounted) return;

    _showMessage(result['message'] ?? 'Offer declined');
  }

  Future<void> _showCounterDialog(Map<String, dynamic> item) async {
    final controller = TextEditingController(
      text: widget.offeredFare.toString(),
    );

    final int? counterAmount = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Counter Offer'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter counter amount',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text.trim());

                if (amount == null || amount <= 0) {
                  Navigator.pop(dialogContext, -1);
                  return;
                }

                Navigator.pop(dialogContext, amount);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted) return;

    if (counterAmount == null) return;

    if (counterAmount <= 0) {
      _showMessage('Enter valid counter amount');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    await _counterOffer(item, counterAmount);
  }

  Future<void> _counterOffer(
    Map<String, dynamic> item,
    int counterAmount,
  ) async {
    final offerId = _offerId(item);

    if (offerId.isEmpty) {
      _showMessage('Offer ID not found');
      return;
    }

    final provider = context.read<DriverOffersProvider>();

    final result = await provider.counterOffer(
      rideId: widget.rideId,
      offerId: offerId,
      counterAmount: counterAmount,
    );

    if (!mounted) return;

    _showMessage(result['message'] ?? 'Counter offer sent');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _driverName(Map<String, dynamic> item) {
    return item['driverName']?.toString() ?? 'Driver';
  }

  String _carInfo(Map<String, dynamic> item) {
    final vehicleName = item['vehicleName']?.toString() ?? 'Vehicle';
    final vehicleColor = item['vehicleColor']?.toString() ?? '';
    final vehiclePlate = item['vehiclePlate']?.toString() ?? '';

    final parts = [
      vehicleName,
      if (vehicleColor.isNotEmpty) vehicleColor,
      if (vehiclePlate.isNotEmpty) vehiclePlate,
    ];

    return parts.join(' • ');
  }

  String _eta(Map<String, dynamic> item) {
    final etaMinutes = item['etaMinutes'];
    if (etaMinutes is num) {
      return '${etaMinutes.toInt()} min';
    }
    return '0 min';
  }

  String _rating(Map<String, dynamic> item) {
    final rating = item['rating'];
    if (rating is num) {
      return rating.toStringAsFixed(1);
    }
    return '0.0';
  }

  String _amount(Map<String, dynamic> item) {
    final amount = item['amount'];
    if (amount is num) {
      return amount.toInt().toString();
    }
    return widget.offeredFare.toString();
  }

  String _avatarLetter(Map<String, dynamic> item) {
    final name = _driverName(item);
    if (name.isEmpty) return 'D';
    return name[0].toUpperCase();
  }

  bool _isCounterOffer(Map<String, dynamic> item) {
    final amount = item['amount'];
    if (amount is num) {
      return amount.toInt() != widget.offeredFare;
    }
    return false;
  }

  bool _isOfferDisabled(Map<String, dynamic> item) {
    final status = item['status']?.toString().toLowerCase() ?? '';
    return status == 'accepted' || status == 'declined';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverOffersProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                _buildMapSection(),
                Expanded(
                  child: Column(
                    children: [
                      _buildStatusBar(),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : provider.errorMessage.isNotEmpty
                                ? _buildErrorState()
                                : provider.offers.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          12,
                                          16,
                                          16,
                                        ),
                                        itemCount: provider.offers.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 14),
                                        itemBuilder: (context, index) {
                                          final item = provider.offers[index];
                                          final disabled =
                                              _isOfferDisabled(item);

                                          return DriverOfferCard(
                                            name: _driverName(item),
                                            carInfo: _carInfo(item),
                                            price: _amount(item),
                                            eta: _eta(item),
                                            rating: _rating(item),
                                            avatarLetter: _avatarLetter(item),
                                            showCounterOffer:
                                                _isCounterOffer(item),
                                            status: item['status']?.toString(),
                                            disabled: disabled,
                                            onAccept: () {
                                              if (!disabled) {
                                                _acceptOffer(item);
                                              }
                                            },
                                            onCounter: () {
                                              if (!disabled) {
                                                _showCounterDialog(item);
                                              }
                                            },
                                            onDecline: () {
                                              if (!disabled) {
                                                _declineOffer(item);
                                              }
                                            },
                                          );
                                        },
                                      ),
                      ),
                      _buildBottomButton(),
                    ],
                  ),
                ),
              ],
            ),
            if (provider.isActionLoading)
              Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final provider = context.watch<DriverOffersProvider>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.text2(context),
            ),
            const SizedBox(height: 10),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text2(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _broadcastRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No driver offers yet. Please wait...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text2(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<DriverOffersProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.text1(context),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Driver Offers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text1(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              provider.timerText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final provider = context.watch<DriverOffersProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? AppColors.darkCard : const Color(0xFFDDE4D7),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: MapPainter(isDark: isDark),
            ),
          ),
          const Positioned(
            left: 55,
            top: 70,
            child: AnimatedDriverPin(
              color: Color(0xFF10B981),
              icon: Icons.local_taxi_rounded,
              delay: 0,
            ),
          ),
          const Positioned(
            left: 138,
            top: 112,
            child: AnimatedDriverPin(
              color: Color(0xFFF97316),
              icon: Icons.location_on_rounded,
              delay: 150,
            ),
          ),
          const Positioned(
            right: 88,
            top: 48,
            child: AnimatedDriverPin(
              color: Color(0xFF3B82F6),
              icon: Icons.directions_car_filled_rounded,
              delay: 300,
            ),
          ),
          const Positioned(
            right: 50,
            top: 104,
            child: AnimatedDriverPin(
              color: Color(0xFF8B5CF6),
              icon: Icons.local_taxi_rounded,
              delay: 500,
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Broadcasting PKR ${widget.offeredFare} to nearby drivers...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1(context),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      provider.timerText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final provider = context.watch<DriverOffersProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Text(
            '${provider.respondedDrivers} drivers responded',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              provider.live ? 'Live' : 'Waiting',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Offer cancelled')),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary.withOpacity(.45)),
            backgroundColor: AppColors.card(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Cancel Offer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class DriverOfferCard extends StatelessWidget {
  final String name;
  final String carInfo;
  final String price;
  final String eta;
  final String rating;
  final String avatarLetter;
  final bool showCounterOffer;
  final String? status;
  final bool disabled;
  final VoidCallback onAccept;
  final VoidCallback onCounter;
  final VoidCallback onDecline;

  const DriverOfferCard({
    super.key,
    required this.name,
    required this.carInfo,
    required this.price,
    required this.eta,
    required this.rating,
    required this.avatarLetter,
    required this.showCounterOffer,
    required this.status,
    required this.disabled,
    required this.onAccept,
    required this.onCounter,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = status?.toLowerCase() ?? '';

    return Opacity(
      opacity: disabled ? 0.65 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPrimary.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarWithRating(
                  letter: avatarLetter,
                  rating: rating,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        carInfo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text2(context),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _SmallChip(
                            icon: Icons.access_time_filled_rounded,
                            label: eta,
                            bg: AppColors.softBg(context),
                            textColor: AppColors.darkPrimary,
                          ),
                          if (showCounterOffer)
                            const _PlainChip(
                              label: 'Counter',
                              bg: Color(0xFFFFE7B3),
                              textColor: Color(0xFFD97706),
                            ),
                          if (currentStatus.isNotEmpty)
                            _PlainChip(
                              label: currentStatus.toUpperCase(),
                              bg: currentStatus == 'accepted'
                                  ? const Color(0xFFD1FAE5)
                                  : currentStatus == 'declined'
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFEDE9FE),
                              textColor: currentStatus == 'accepted'
                                  ? const Color(0xFF059669)
                                  : currentStatus == 'declined'
                                      ? const Color(0xFFDC2626)
                                      : AppColors.darkPrimary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PKR $price',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    icon: Icons.check_rounded,
                    background: AppColors.primary,
                    textColor: AppColors.white,
                    onTap: disabled ? null : onAccept,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Counter',
                    icon: Icons.currency_exchange_rounded,
                    background: AppColors.secondary.withOpacity(.35),
                    textColor: AppColors.darkPrimary,
                    onTap: disabled ? null : onCounter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Decline',
                    icon: Icons.close_rounded,
                    background: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF3F4F6),
                    textColor: AppColors.text1(context),
                    onTap: disabled ? null : onDecline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithRating extends StatelessWidget {
  final String letter;
  final String rating;

  const _AvatarWithRating({
    required this.letter,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.darkPrimary,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.card(context), width: 2),
            ),
            child: Text(
              '★ $rating',
              style: const TextStyle(
                fontSize: 9,
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

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color textColor;

  const _SmallChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _PlainChip({
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15, color: textColor),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: background,
          disabledBackgroundColor: background.withOpacity(0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class AnimatedDriverPin extends StatefulWidget {
  final Color color;
  final IconData icon;
  final int delay;

  const AnimatedDriverPin({
    super.key,
    required this.color,
    required this.icon,
    required this.delay,
  });

  @override
  State<AnimatedDriverPin> createState() => _AnimatedDriverPinState();
}

class _AnimatedDriverPinState extends State<AnimatedDriverPin>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  Timer? delayTimer;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    animation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    delayTimer = Timer(Duration(milliseconds: widget.delay), () {
      controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    delayTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Column(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(.35),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.white,
                  size: 17,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                transform: Matrix4.rotationZ(math.pi / 4),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MapPainter extends CustomPainter {
  final bool isDark;

  MapPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final bgLine = Paint()
      ..color = isDark
          ? AppColors.secondary.withOpacity(.18)
          : const Color(0xFFB8C6B0).withOpacity(.35)
      ..strokeWidth = 1;

    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.14) : Colors.white;

    final dashPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.25)
          : const Color(0xFFD1D5DB)
      ..strokeWidth = 2;

    final blockPaint = Paint()
      ..color = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFC5D4BC);

    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), bgLine);
    }

    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), bgLine);
    }

    canvas.drawRect(Rect.fromLTWH(0, 76, size.width, 14), roadPaint);
    canvas.drawRect(Rect.fromLTWH(80, 0, 16, size.height), roadPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width - 110, 0, 16, size.height),
      roadPaint,
    );

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 83), Offset(x + 14, 83), dashPaint);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 18, 62, 40),
        const Radius.circular(12),
      ),
      blockPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 72, 12, 40, 34),
        const Radius.circular(12),
      ),
      blockPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 74, 118, 54, 34),
        const Radius.circular(12),
      ),
      blockPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}