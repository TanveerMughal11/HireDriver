import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/screens/review.dart';

class DriverArrivingScreen extends StatefulWidget {
  const DriverArrivingScreen({super.key});

  @override
  State<DriverArrivingScreen> createState() => _DriverArrivingScreenState();
}

class _DriverArrivingScreenState extends State<DriverArrivingScreen> {
  double tripProgress = 0.10;
  bool isDrawerExpanded = false;
  bool isTripStarted = false;
Duration tripElapsed = const Duration(minutes: 12, seconds: 35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _FullMapBackground(
  isTripStarted: isTripStarted,
),

SafeArea(
  child: Column(
    children: [
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
       child: isTripStarted
    ? _buildInProgressBanner()
    : _buildArrivalBanner(),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _buildBottomDrawer(),
        ),
      ),
    ],
  ),
),
        ],
      ),
    );
  }
Widget _buildInProgressBanner() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(
        color: AppColors.secondary.withOpacity(0.7),
      ),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip in Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Heading to Gulberg III, Lahore',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ETA 18 min',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildArrivalBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver has arrived!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Look for Toyota Corolla · LAH-1234',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 14,
            width: 14,
            decoration: const BoxDecoration(
              color: Color(0xFF18B777),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.my_location_rounded,
            color: Color(0xFFFF4D8D),
            size: 24,
          ),
        ],
      ),
    );
  }

Widget _buildBottomDrawer() {
  final double drawerHeight = isDrawerExpanded ? 520 : 260;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeInOut,
    width: double.infinity,
    height: drawerHeight,
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.10),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isDrawerExpanded = !isDrawerExpanded;
              });
            },
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDriverInfoCard(),
                  const SizedBox(height: 14),

                  Row(
                    children: const [
                      Expanded(
                        child: _LocationMiniCard(
                          title: 'PICKUP',
                          value: 'DHA Ph 5',
                          icon: Icons.location_on_rounded,
                          iconColor: Color(0xFFFF5B8A),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _LocationMiniCard(
                          title: 'DROP-OFF',
                          value: 'Gulberg III',
                          icon: Icons.flag_rounded,
                          iconColor: Color(0xFF6E6E6E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (!isTripStarted) ...[
                    _buildTripProgress(),
                    const SizedBox(height: 16),
                    _buildEtaShareRow(),
                    const SizedBox(height: 14),

                    _buildActionButton(
                      text: 'Simulate Trip Started',
                      onTap: () {
                        setState(() {
                          isTripStarted = true;
                          tripProgress = 0.35;
                        });
                      },
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.secondary,
                      icon: Icons.play_arrow_rounded,
                      iconColor: AppColors.primary,
                    ),
                  ] else ...[
                    _buildDestinationCard(),
                    const SizedBox(height: 14),
                    _buildTripTimerCard(),
                    const SizedBox(height: 14),

                    _buildActionButton(
                      text: 'SOS Emergency',
                      onTap: () {},
                      backgroundColor: const Color(0xFFFFE3E3),
                      textColor: const Color(0xFFFF4B4B),
                      borderColor: const Color(0xFFFFB6B6),
                      icon: Icons.sos_rounded,
                      iconColor: const Color(0xFFFF4B4B),
                    ),
                    const SizedBox(height: 12),

                    _buildActionButton(
                      text: 'End Trip',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TripCompletedScreen(),
                          ),
                        );
                      },
                      backgroundColor: Colors.white,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      icon: Icons.stop_circle_outlined,
                      iconColor: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildDestinationCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.secondary.withOpacity(0.8)),
    ),
    child: Row(
      children: const [
        Icon(
          Icons.flag_rounded,
          color: Color(0xFFFF7A30),
          size: 20,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Destination',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gulberg III, Lahore',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Text(
          '18 min',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
Widget _buildTripTimerCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.secondary.withOpacity(0.8)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.timer_outlined,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Trip Timer',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${tripElapsed.inMinutes}:${(tripElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
  Widget _buildDriverInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF5B8A),
                      Color(0xFFFF8A50),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB020),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '4.9',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ali Hassan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFB020),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFB020),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFB020),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFB020),
                    ),
                    SizedBox(width: 2),
                    Text(
                      '4.9',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Toyota Corolla · Silver · LAH-1234',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            children: [
              _squareActionIcon(
                icon: Icons.chat_bubble_rounded,
                bgColor: AppColors.light,
                iconColor: AppColors.primary,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _squareActionIcon(
                icon: Icons.call_rounded,
                bgColor: const Color(0xFF18B777),
                iconColor: Colors.white,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Trip Progress',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(tripProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: tripProgress,
              backgroundColor: AppColors.secondary.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaShareRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.8),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ETA 4 min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.8),
              ),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(18),
              child: const Row(
                children: [
                  Icon(
                    Icons.share_location_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Share Live Location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: 20),
        label: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }

  Widget _squareActionIcon({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(icon, color: iconColor, size: 21),
        ),
      ),
    );
  }
}

class _LocationMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _LocationMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullMapBackground extends StatelessWidget {
  final bool isTripStarted;

  const _FullMapBackground({
    required this.isTripStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFEFF3EC),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: _MapPainter(),
        ),

        if (!isTripStarted) ...[
          Positioned(
            left: 140,
            top: 155,
            child: _marker(
              color: const Color(0xFFFF7A30),
              icon: Icons.person_pin_circle_rounded,
              size: 50,
            ),
          ),
          Positioned(
            left: 215,
            top: 95,
            child: _marker(
              color: AppColors.primary,
              icon: Icons.local_taxi_rounded,
              size: 54,
            ),
          ),
          Positioned(
            left: 182,
            top: 126,
            child: Transform.rotate(
              angle: -0.72,
              child: SizedBox(
                width: 88,
                height: 4,
                child: CustomPaint(
                  painter: _DashedLinePainter(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ] else ...[
          Positioned(
            left: 85,
            top: 150,
            child: _marker(
              color: AppColors.primary,
              icon: Icons.local_taxi_rounded,
              size: 54,
            ),
          ),
          Positioned(
            left: 245,
            top: 95,
            child: _marker(
              color: const Color(0xFFFF7A30),
              icon: Icons.flag_rounded,
              size: 50,
            ),
          ),
          Positioned(
            left: 135,
            top: 128,
            child: Transform.rotate(
              angle: -0.35,
              child: SizedBox(
                width: 130,
                height: 4,
                child: CustomPaint(
                  painter: _DashedLinePainter(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _marker({
    required Color color,
    required IconData icon,
    required double size,
  }) {
    return Column(
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.38),
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

class _MiniCar extends StatelessWidget {
  const _MiniCar();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.local_taxi_rounded,
      color: Color(0xFF2F63E8),
      size: 20,
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEFF3EC);
    canvas.drawRect(Offset.zero & size, bg);

    final thinGrid = Paint()
      ..color = const Color(0xFFD9E3D5)
      ..strokeWidth = 0.7;

    final thickRoad = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final lane = Paint()
      ..color = const Color(0xFFC3C7C2)
      ..strokeWidth = 1.2;

    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinGrid);
    }

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thinGrid);
    }

    final verticals = [36.0, 86.0, 258.0];
    for (final x in verticals) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thickRoad);
      for (double y = 0; y < size.height; y += 28) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 12), lane);
      }
    }

    final horizontals = [118.0, 232.0];
    for (final y in horizontals) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thickRoad);
      for (double x = 0; x < size.width; x += 28) {
        canvas.drawLine(Offset(x, y), Offset(x + 12, y), lane);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double startX = 0;
    const dashWidth = 8;
    const dashSpace = 6;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}