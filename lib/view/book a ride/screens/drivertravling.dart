import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/riderrating.dart';
import 'package:hire_driver/view/book a ride/provider/drivertraling.dart';
import 'package:provider/provider.dart';

class OngoingRideScreen extends StatefulWidget {
  const OngoingRideScreen({super.key});

  @override
  State<OngoingRideScreen> createState() => _OngoingRideScreenState();
}

class _OngoingRideScreenState extends State<OngoingRideScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OngoingRideProvider>().startRideProgress();
    });
  }

  @override
  void dispose() {
    context.read<OngoingRideProvider>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OngoingRideProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: _MapArea(),
                  ),
                  const Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: _TripTopCard(),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _DriverInfoCard(),
                          const SizedBox(height: 14),
                          _FareProgressCard(progress: provider.rideProgress),
                          const SizedBox(height: 14),
                          const _SosButton(),
                          const SizedBox(height: 12),
                          const _EndRideButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripTopCard extends StatelessWidget {
  const _TripTopCard();

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
                  'Zain UI enroute to destination',
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
                  'Estimated 18 min remaining',
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
            '18m',
            style: TextStyle(
              fontSize: 22,
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
  const _DriverInfoCard();

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
          const _DriverAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zain UI Abideen',
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
                    const Icon(Icons.star_half_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '4.8',
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
                  'Honda Civic · Grey · LHR-5678',
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
  const _DriverAvatar();

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
              colors: [
                AppColors.primary,
                Colors.cyan.shade500,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Z',
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
            child: const Text(
              '★4.8',
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

class _FareProgressCard extends StatelessWidget {
  final double progress;

  const _FareProgressCard({
    required this.progress,
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
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.45),
        ),
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
                    const TextSpan(
                      text: '350',
                      style: TextStyle(
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
                  'En Route',
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
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF3A1F1F)
              : const Color(0xFFF8DCDC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFFF09A9A),
              width: 1.4,
            ),
          ),
        ),
        child: const Text(
          '🧍 SOS Emergency',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFA4A3C),
          ),
        ),
      ),
    );
  }
}

class _EndRideButton extends StatelessWidget {
  const _EndRideButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const RideReviewScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card(context),
          side: const BorderSide(
            color: Color(0xFF315EEC),
            width: 1.6,
          ),
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
  const _MapArea();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: _MapPainter(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        Positioned(
          left: 145,
          top: 220,
          child: _PinMarker(
            color: Colors.deepOrange.shade400,
            child: const Icon(
              Icons.circle,
              size: 10,
              color: AppColors.primary,
            ),
          ),
        ),
        Positioned(
          left: 245,
          top: 110,
          child: _PinMarker(
            color: const Color(0xFF315EEC),
            child: const Text('🚙', style: TextStyle(fontSize: 15)),
          ),
        ),
        Positioned(
          left: 105,
          top: 170,
          child: const Text('🚗', style: TextStyle(fontSize: 18)),
        ),
        Positioned(
          left: 215,
          top: 270,
          child: const Text('🚙', style: TextStyle(fontSize: 18)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _RoutePainter(),
          ),
        ),
      ],
    );
  }
}

class _PinMarker extends StatelessWidget {
  final Color color;
  final Widget child;

  const _PinMarker({
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
        Container(
          width: 12,
          height: 12,
          transform: Matrix4.rotationZ(0.8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const start = Offset(160, 230);
    const end = Offset(262, 126);

    _drawDashedLine(canvas, start, end, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 6.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = (dx * dx + dy * dy).sqrt();
    final angle = (end - start).direction;

    double drawn = 0;
    while (drawn < distance) {
      final from = Offset(
        start.dx + math.cos(angle) * drawn,
        start.dy + math.sin(angle) * drawn,
      );
      final to = Offset(
        start.dx + math.cos(angle) * (drawn + dashWidth).clamp(0, distance),
        start.dy + math.sin(angle) * (drawn + dashWidth).clamp(0, distance),
      );
      canvas.drawLine(from, to, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPainter extends CustomPainter {
  final bool isDark;

  _MapPainter({
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark
          ? AppColors.secondary.withOpacity(0.15)
          : const Color(0xFFBBC8B8).withOpacity(0.35)
      ..strokeWidth = 1;

    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.13) : Colors.white;

    final dashPaint = Paint()
      ..color =
          isDark ? Colors.white.withOpacity(0.25) : const Color(0xFFD0D4DD)
      ..strokeWidth = 2;

    final parkPaint = Paint()
      ..color = isDark ? const Color(0xFF20351F) : const Color(0xFFC3DDBB);

    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF121212) : AppColors.background;

    canvas.drawRect(Offset.zero & size, bgPaint);

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawRect(Rect.fromLTWH(0, 110, size.width, 14), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, 225, size.width, 14), roadPaint);
    canvas.drawRect(Rect.fromLTWH(72, 0, 14, size.height), roadPaint);
    canvas.drawRect(Rect.fromLTWH(252, 0, 14, size.height), roadPaint);

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 117), Offset(x + 16, 117), dashPaint);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 82, 290, 56, 38),
        const Radius.circular(12),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

extension on num {
  double sqrt() => math.sqrt(toDouble());
}