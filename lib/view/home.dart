import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hire_driver/customwidgets/custom_textfields.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/customwidgets/bottombar.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/bookaride.dart';
import 'package:hire_driver/view/car%20rental/screens/bookrental.dart';
import 'package:hire_driver/view/car%20rental/screens/carlisting.dart';
import 'package:hire_driver/view/forms/screen/carlistingform.dart';
import 'package:hire_driver/view/car%20rental/screens/carrentingdetail.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/drivertravling.dart';
import 'package:hire_driver/view/hiredriver/screens/avaibledrivers.dart';
import 'package:hire_driver/view/hiredriver/screens/hiredriver.dart';
import 'package:hire_driver/view/hiredriver/screens/onewaytrip.dart';
import 'package:hire_driver/view/history.dart';
import 'package:hire_driver/view/profile/screens/profile.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/offerrider.dart';
import 'package:hire_driver/view/car%20rental/carrenting.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/riderrating.dart';
import 'package:hire_driver/view/book%20a%20ride/screens/setprice.dart';
import 'package:hire_driver/view/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ride App UI',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleBottomBarTap(BuildContext context, int index) {
    if (index == 0) return;

    Widget screen;

    if (index == 1) {
      screen = const HistoryScreen();
    } else if (index == 2) {
      screen = const WalletScreen();
    } else {
      screen = const ProfileScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: const _HomeContent(),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _MapBackground(),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 10),
                      _TopHeader(),
                      SizedBox(height: 16),
                      SizedBox(height: 24),
                      _PromoCard(),
                      SizedBox(height: 18),
                      _SectionTitle(title: 'Our Services'),
                      SizedBox(height: 14),
                      _ServiceGrid(),
                      SizedBox(height: 20),
                      _RecentStatsCard(),
                      SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
      ),
      child: CustomPaint(
        painter: _MapPainter(
          backgroundColor: AppColors.softBg(context),
          roadColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.16)
              : Colors.white.withOpacity(0.92),
          laneColor: AppColors.secondary.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.20 : 0.55,
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Color backgroundColor;
  final Color roadColor;
  final Color laneColor;

  _MapPainter({
    required this.backgroundColor,
    required this.roadColor,
    required this.laneColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = roadColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final lane = Paint()
      ..color = laneColor
      ..strokeWidth = 1.2;

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lane);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lane);
    }

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.30),
      Offset(size.width * 0.92, size.height * 0.30),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.10),
      Offset(size.width * 0.18, size.height * 0.86),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.70, size.height * 0.00),
      Offset(size.width * 0.70, size.height * 0.72),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.02, size.height * 0.62),
      Offset(size.width * 0.58, size.height * 0.62),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.roadColor != roadColor ||
        oldDelegate.laneColor != laneColor;
  }
}

class _TopHeader extends StatefulWidget {
  const _TopHeader();

  @override
  State<_TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<_TopHeader> {
  String userName = "User";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else if (hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final user = jsonDecode(userString);

      setState(() {
        userName = user['name'] ?? "User";
      });
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1(context),
                ),
              ),
            ],
          ),
          const Spacer(),
          _CircleIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _openProfile(context),
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                userName.isNotEmpty ? userName[0] : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final goButtonWidth = screenWidth < 380 ? 64.0 : 76.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.text2(context), size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: SizedBox(
                height: 50,
                child: CustomTextField(
                  hintText: 'Where do you want to go?',
                  controller: controller,
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: goButtonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const FittedBox(
                  child: Text(
                    'GO',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatefulWidget {
  const _PromoCard();

  @override
  State<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<_PromoCard> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool bookRideOfferClaimed = false;

  @override
  void initState() {
    super.initState();
    _loadOfferStatus();
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  Future<void> _loadOfferStatus() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      bookRideOfferClaimed = prefs.getBool('book_ride_offer_claimed') ?? false;
    });
  }

  Future<void> _claimBookRideOffer() async {
    const code = 'RIDE25';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('book_ride_promo_code', code);
    await prefs.setBool('book_ride_offer_claimed', true);

    await Clipboard.setData(const ClipboardData(text: code));

    if (!mounted) return;

    setState(() {
      bookRideOfferClaimed = true;
      _currentPage = 0;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Offer Claimed'),
        content: const Text(
          'Your code is: RIDE25\n\nCode copied. Paste it in Set Price screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _autoScroll() {
    if (!mounted || !_controller.hasClients) return;

    if (bookRideOfferClaimed) return;

    _currentPage++;
    if (_currentPage > 1) _currentPage = 0;

    _controller.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = <Widget>[
      const _Banner1(),
      if (!bookRideOfferClaimed)
        _Banner2(
          onClaimOffer: _claimBookRideOffer,
        ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 152,
          child: PageView(
            controller: _controller,
            physics: bookRideOfferClaimed
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index;
                });
              }
            },
            children: banners,
          ),
        ),
        if (!bookRideOfferClaimed) ...[
          const SizedBox(height: 12),
          _PromoIndicator(activeIndex: _currentPage),
        ],
      ],
    );
  }
}

class _Banner1 extends StatelessWidget {
  const _Banner1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.darkPrimary],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -20,
              child: Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 50,
              top: -10,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.72,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.local_taxi_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'First 3 Rides FREE Petrol!',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'When you hire a driver this week',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Text(
                          'Claim Offer →',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner2 extends StatelessWidget {
  final VoidCallback onClaimOffer;

  const _Banner2({
    required this.onClaimOffer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClaimOffer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -20,
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 50,
                top: -10,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.72,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.directions_car_filled_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '25% OFF Book a Ride',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap to claim code · No minimum fare',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Text(
                            'Claim Offer →',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoIndicator extends StatelessWidget {
  final int activeIndex;

  const _PromoIndicator({
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(activeIndex == 0),
        const SizedBox(width: 6),
        _dot(activeIndex == 1),
      ],
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 6,
      width: active ? 22 : 6,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.text1(context),
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  void _openBookRide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookRideScreen(),
      ),
    );
  }

  void _openHireDriver(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HireDriverTypeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openHireDriver(context),
                  child: const _ServiceCard(
                    icon: Icons.local_taxi_rounded,
                    title: 'Hire a Driver',
                    subtitle: 'Use your own car',
                    availability: '8+ available nearby',
                    background: AppColors.light,
                    showPopular: true,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openBookRide(context),
                  child: const _ServiceCard(
                    icon: Icons.directions_car_filled_rounded,
                    title: 'Book a Ride',
                    subtitle: 'Driver brings car',
                    availability: '14+ available nearby',
                    background: AppColors.light,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CarRentingScreen(),
                ),
              );
            },
            child: const _WideServiceCard(),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String availability;
  final Color background;
  final bool showPopular;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.availability,
    required this.background,
    this.showPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30, color: AppColors.primary),
              const Spacer(),
              if (showPopular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.text2(context),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '● 8+ available nearby',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WideServiceCard extends StatelessWidget {
  const _WideServiceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, size: 34, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Car Rental',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rent or earn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text2(context),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '● 200+ available nearby',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 30,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _RecentStatsCard extends StatelessWidget {
  const _RecentStatsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.local_taxi_rounded,
                value: '5,200+',
                label: 'Drivers',
              ),
            ),
            _VerticalDividerSoft(),
            Expanded(
              child: _StatItem(
                icon: Icons.location_on_rounded,
                value: 'Lahore',
                label: 'Your City',
              ),
            ),
            _VerticalDividerSoft(),
            Expanded(
              child: _StatItem(
                icon: Icons.star_rounded,
                value: '4.8',
                label: 'Avg Rating',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.text1(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text2(context),
          ),
        ),
      ],
    );
  }
}

class _VerticalDividerSoft extends StatelessWidget {
  const _VerticalDividerSoft();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 1,
      color: AppColors.secondary,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? AppColors.primary : AppColors.text2(context),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.text2(context),
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card(context),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(icon, color: AppColors.text1(context)),
        ),
      ),
    );
  }
}

class _MapPinBubble extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapPinBubble({required this.color, required this.icon});

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
          transform: Matrix4.rotationZ(0.78),
        ),
      ],
    );
  }
}