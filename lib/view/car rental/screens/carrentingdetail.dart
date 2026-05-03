import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/screens/bookrental.dart';
import 'package:hire_driver/view/car%20rental/provider/car_detail.dart';
import 'package:provider/provider.dart';


class CarDetailsScreen extends StatelessWidget {
  final String listingId;

  const CarDetailsScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarDetailsProvider()..fetchCarDetails(listingId),
      child: _CarDetailsScreenBody(listingId: listingId),
    );
  }
}

class _CarDetailsScreenBody extends StatefulWidget {
  final String listingId;

  const _CarDetailsScreenBody({
    required this.listingId,
  });

  @override
  State<_CarDetailsScreenBody> createState() => _CarDetailsScreenBodyState();
}

class _CarDetailsScreenBodyState extends State<_CarDetailsScreenBody> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageCarousel() {
    final provider = context.watch<CarDetailsProvider>();

    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: provider.carImages.length,
            onPageChanged: (index) {
              provider.updateCurrentImage(index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        provider.carImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.softBg(context),
                            child: const Icon(
                              Icons.directions_car,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.02),
                              Colors.black.withOpacity(0.20),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 16,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImage(
                                  imageUrl: provider.carImages[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 22,
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
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _TopIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                _TopIconButton(
                  icon: Icons.favorite_border_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                _TopIconButton(
                  icon: Icons.share_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              provider.carImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: provider.currentImage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: provider.currentImage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    final provider = context.watch<CarDetailsProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  provider.carName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text1(context),
                  ),
                ),
              ),
              Text(
                'PKR ',
                style: TextStyle(
                  color: AppColors.text2(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                provider.pricePerDay,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
              Text(
                '/day',
                style: TextStyle(
                  color: AppColors.text2(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            provider.subtitle,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                provider.ratingText,
                style: TextStyle(
                  color: AppColors.text1(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                provider.ratingCountText,
                style: TextStyle(
                  color: AppColors.text2(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: provider.isAvailable
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: provider.isAvailable
                    ? Colors.green.withOpacity(0.25)
                    : Colors.red.withOpacity(0.25),
              ),
            ),
            child: Text(
              provider.isAvailable ? '✓ Available Now' : '✕ Not Available',
              style: TextStyle(
                color: provider.isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid() {
    final provider = context.watch<CarDetailsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: provider.specs.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.02,
        ),
        itemBuilder: (context, index) {
          final item = provider.specs[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.secondary.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'],
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(height: 10),
                Text(
                  item['value'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHostCard() {
    final provider = context.watch<CarDetailsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                provider.ownerInitial,
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
                    provider.ownerName,
                    style: TextStyle(
                      color: AppColors.text1(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Car Owner · ${provider.rating['count'] ?? 0} reviews',
                    style: TextStyle(
                      color: AppColors.text2(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.softBg(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    final provider = context.watch<CarDetailsProvider>();

    Widget chip(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF059669),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softBg(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Days',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            provider.availableDays.isEmpty
                ? Text(
                    'No availability data',
                    style: TextStyle(
                      color: AppColors.text2(context),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        provider.availableDays.map((day) => chip(day)).toList(),
                  ),
            const SizedBox(height: 14),
            Text(
              'Minimum Rental Days: ${provider.pricing['minRentalDays'] ?? 0}',
              style: TextStyle(
                color: AppColors.text1(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    final provider = context.watch<CarDetailsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.softBg(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: CustomPaint(
                  painter: _SimpleMapPainter(isDark: isDark),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card(context).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${provider.carInfo['locationArea'] ?? 'Unknown location'}',
                      style: TextStyle(
                        color: AppColors.text1(context),
                        fontWeight: FontWeight.w800,
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

  Widget _buildDocumentsSection() {
    final provider = context.watch<CarDetailsProvider>();

    final insuranceDoc = provider.pricing['insuranceDocument']?.toString() ?? '';
    final registrationDoc =
        provider.pricing['vehicleRegistration']?.toString() ?? '';

    Widget docTile(String title, String value) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.isEmpty ? '$title not available' : title,
                style: TextStyle(
                  color: AppColors.text1(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          docTile('Insurance Document', insuranceDoc),
          docTile('Vehicle Registration', registrationDoc),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        color: AppColors.bg(context),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookRentalScreen(
                    listingId: widget.listingId,
                  ),
                ),
              );
            },
            child: const Text(
              'Rent This Car →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailsProvider>();

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: Center(
          child: Text(
            provider.errorMessage,
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(),
                  _buildTitleSection(),
                  _sectionTitle('Car Specs'),
                  _buildSpecsGrid(),
                  const SizedBox(height: 20),
                  _sectionTitle('Host Info'),
                  _buildHostCard(),
                  const SizedBox(height: 20),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 20),
                  _sectionTitle('Location on Map'),
                  _buildMapSection(),
                  const SizedBox(height: 20),
                  _sectionTitle('Documents'),
                  _buildDocumentsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card(context).withOpacity(0.92),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 42,
          width: 42,
          child: Icon(
            icon,
            color: AppColors.text1(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SimpleMapPainter extends CustomPainter {
  final bool isDark;

  _SimpleMapPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8EEF9);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.14) : Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final lane = Paint()
      ..color =
          isDark ? Colors.white.withOpacity(0.18) : const Color(0xFFCAD8F0)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.30),
      Offset(size.width * 0.95, size.height * 0.30),
      road,
    );

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.75),
      Offset(size.width * 0.88, size.height * 0.75),
      road,
    );

    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.05),
      Offset(size.width * 0.30, size.height * 0.95),
      road,
    );

    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.10),
      Offset(size.width * 0.72, size.height * 0.90),
      road,
    );

    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lane);
    }

    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lane);
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}