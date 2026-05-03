import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/utils/textstyle.dart';
import 'package:hire_driver/auth/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPagerScreen extends StatefulWidget {
  const IntroPagerScreen({super.key});

  @override
  State<IntroPagerScreen> createState() => _IntroPagerScreenState();
}

class _IntroPagerScreenState extends State<IntroPagerScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final List<IntroData> pages = const [
    IntroData(
      badgeText: "Most Popular",
      title: "Hire\na Driver",
      description:
          "Travel in your OWN car while our background-verified driver handles the wheel. Relax and enjoy the ride.",
      emoji: "🚗",
      icon: Icons.person,
      chips: ["Verified Drivers", "GPS Tracked", "SOS Safety"],
      backgroundColor: AppColors.light,
      chipColor: AppColors.secondary,
      accentColor: AppColors.primary,
      buttonText: "Next",
      innerCircleColor: AppColors.white,
      outerCircleColor: AppColors.secondary,
    ),
    IntroData(
      badgeText: "Save Up to 40%",
      title: "Book\na Ride",
      description:
          "Set your own price and get matched with nearby drivers instantly. You're in control of what you pay.",
      emoji: "🛺",
      icon: Icons.directions_car,
      chips: ["Set Your Price", "Bid System", "Instant Match"],
      backgroundColor: AppColors.light,
      chipColor: AppColors.secondary,
      accentColor: AppColors.primary,
      buttonText: "Next",
      innerCircleColor: AppColors.white,
      outerCircleColor: AppColors.secondary,
    ),
    IntroData(
      badgeText: "Earn PKR 50K+/mo",
      title: "Rent\na Car",
      description:
          "Browse 200+ verified cars to rent, or list your own car and earn passive income — fully insured.",
      emoji: "🔑",
      icon: Icons.key,
      chips: ["200+ Cars", "Fully Insured", "Host Earn"],
      backgroundColor: AppColors.light,
      chipColor: AppColors.secondary,
      accentColor: AppColors.primary,
      buttonText: "Get Started",
      innerCircleColor: AppColors.white,
      outerCircleColor: AppColors.secondary,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

 Future<void> _finishIntro() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSeenIntro', true);

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}

void _nextPage() {
  if (currentIndex < pages.length - 1) {
    setState(() {
      currentIndex++;
    });
  } else {
    _finishIntro();
  }
}

void _skip() {
  _finishIntro();
}

  @override
  Widget build(BuildContext context) {
    final page = pages[currentIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: page.backgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 0.97, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _IntroContent(
                key: ValueKey(currentIndex),
                page: page,
                currentIndex: currentIndex,
                floatAnimation: _floatAnimation,
                onSkip: _skip,
                onNext: _nextPage,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroContent extends StatelessWidget {
  final IntroData page;
  final int currentIndex;
  final Animation<double> floatAnimation;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _IntroContent({
    super.key,
    required this.page,
    required this.currentIndex,
    required this.floatAnimation,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TopTag(
              text: page.badgeText,
              bgColor: page.chipColor,
              textColor: page.accentColor,
            ),
            GestureDetector(
              onTap: onSkip,
              child: TopTag(
                text: "Skip",
                bgColor: page.chipColor,
                textColor: page.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Spacer(),
        Center(
          child: AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatAnimation.value),
                child: child,
              );
            },
            child: CircleImage(
              outerColor: page.outerCircleColor,
              innerColor: page.innerCircleColor,
              child: Icon(
                page.icon,
                size: 60,
                color: page.accentColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: page.chips
                .map(
                  (chip) => FeatureChip(
                    text: chip,
                    bgColor: page.chipColor,
                    textColor: page.accentColor,
                  ),
                )
                .toList(),
          ),
        ),
        const Spacer(),
        Text(
          page.title,
          style: AppTextStyles.introTitle.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 10),
        Text(
          page.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.introDescription.copyWith(
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        PageIndicator(
          currentIndex: currentIndex,
          activeColor: page.accentColor,
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          text: page.buttonText,
          startColor: page.accentColor,
          endColor: page.accentColor.withOpacity(0.82),
          onTap: onNext,
        ),
      ],
    );
  }
}

class IntroData {
  final String badgeText;
  final String title;
  final String description;
  final String emoji;
  final IconData icon;
  final List<String> chips;
  final Color backgroundColor;
  final Color chipColor;
  final Color accentColor;
  final String buttonText;
  final Color innerCircleColor;
  final Color outerCircleColor;

  const IntroData({
    required this.badgeText,
    required this.title,
    required this.description,
    required this.emoji,
    required this.icon,
    required this.chips,
    required this.backgroundColor,
    required this.chipColor,
    required this.accentColor,
    required this.buttonText,
    required this.innerCircleColor,
    required this.outerCircleColor,
  });
}

class TopTag extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const TopTag({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.tagText(textColor),
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const FeatureChip({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.chipText(textColor),
      ),
    );
  }
}

class CircleImage extends StatelessWidget {
  final Widget child;
  final Color outerColor;
  final Color innerColor;

  const CircleImage({
    super.key,
    required this.child,
    required this.outerColor,
    required this.innerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outerColor,
      ),
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: innerColor,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final Color activeColor;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFFD0D4DD),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color startColor;
  final Color endColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}