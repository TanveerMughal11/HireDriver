import 'package:flutter/material.dart';

import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/models/hire_driver_options.dart';

import 'package:hire_driver/view/hiredriver/provider/hire_driver_options.dart';

import 'package:hire_driver/view/hiredriver/screens/monthlyhire.dart';
import 'package:hire_driver/view/hiredriver/screens/onewaytrip.dart';
import 'package:hire_driver/view/hiredriver/screens/roundtrip.dart';
import 'package:provider/provider.dart';

class HireDriverTypeScreen extends StatelessWidget {
  const HireDriverTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HireDriverTypeProvider()..loadOptions(),
      child: const _HireDriverTypeScreenBody(),
    );
  }
}

class _HireDriverTypeScreenBody extends StatefulWidget {
  const _HireDriverTypeScreenBody();

  @override
  State<_HireDriverTypeScreenBody> createState() =>
      _HireDriverTypeScreenBodyState();
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HireDriverTypeScreenBodyState extends State<_HireDriverTypeScreenBody> {
  void _goNext(BuildContext context, HireDriverOptionModel selectedOption) {
    final optionMap = selectedOption.toJson();

    if (selectedOption.id == 'one-way') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OneWayTripScreen(
            serviceOption: optionMap,
          ),
        ),
      );
    } else if (selectedOption.id == 'round-trip') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoundTripScreen(
            serviceOption: optionMap,
          ),
        ),
      );
    } else if (selectedOption.id == 'monthly-hire') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MonthlyHireScreen(
            serviceOption: optionMap,
          ),
        ),
      );
    }
  }

  IconData _getIcon(String id) {
    if (id == 'one-way') {
      return Icons.arrow_forward_rounded;
    } else if (id == 'round-trip') {
      return Icons.sync_rounded;
    } else {
      return Icons.calendar_month_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HireDriverTypeProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (provider.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 18),
                          Text(
                            'We drive your car — you ride in comfort. All drivers are background verified.',
                            style: TextStyle(
                              color: AppColors.text2(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _FeatureChip(
                                icon: Icons.verified_user_rounded,
                                label: 'CNIC Verified',
                              ),
                              _FeatureChip(
                                icon: Icons.location_on_rounded,
                                label: 'GPS Tracked',
                              ),
                              _FeatureChip(
                                icon: Icons.sos_rounded,
                                label: 'SOS Safety',
                              ),
                              _FeatureChip(
                                icon: Icons.star_rounded,
                                label: 'Rated Drivers',
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Column(
                            children: provider.options.map((option) {
                              final selected =
                                  provider.selectedOption?.id == option.id;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _HireTypeCard(
                                  title: option.title,
                                  description: option.description,
                                  price: option.rateLabel,
                                  badgeText: option.badge,
                                  icon: _getIcon(option.id),
                                  iconBgColor: AppColors.softBg(context),
                                  accentColor: AppColors.primary,
                                  selected: selected,
                                  onTap: () {
                                    context
                                        .read<HireDriverTypeProvider>()
                                        .selectOption(option);
                                  },
                                ),
                              );
                            }).toList(),
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
                    onPressed: provider.selectedOption == null
                        ? null
                        : () {
                            _goNext(context, provider.selectedOption!);
                          },
                    child: const Text(
                      'Continue',
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
              color: AppColors.card(context),
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
          'Hire a Driver',
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HireTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String badgeText;
  final IconData icon;
  final Color iconBgColor;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _HireTypeCard({
    required this.title,
    required this.description,
    required this.price,
    required this.badgeText,
    required this.icon,
    required this.iconBgColor,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.secondary.withOpacity(0.55),
            width: selected ? 1.7 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(selected ? 0.10 : 0.04),
              blurRadius: selected ? 16 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 30,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 14),

            /// TEXT AREA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.text1(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (badgeText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.text2(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      price,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// RIGHT ICON
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.chevron_right_rounded,
              color: selected ? AppColors.primary : AppColors.secondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}