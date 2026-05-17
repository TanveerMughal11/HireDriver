import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/provider/book_rental.dart';
import 'package:hire_driver/view/home.dart';
import 'package:provider/provider.dart';

class BookRentalScreen extends StatelessWidget {
  final String listingId;

  const BookRentalScreen({
    super.key,
    required this.listingId,
  });

  Future<void> _requestRental(BuildContext context) async {
    final provider = context.read<BookRentalProvider>();

    try {
      final result = await provider.requestRental(listingId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Rental request sent successfully',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

Future<void> _pickDate(BuildContext context, bool isPickup) async {
  final provider = context.read<BookRentalProvider>();
  final now = DateTime.now();

  DateTime firstDate = isPickup ? now : (provider.pickupDate ?? now);

  DateTime initialDate;

  if (isPickup) {
    initialDate = provider.pickupDate ?? now;
  } else {
    initialDate = provider.returnDate ?? provider.pickupDate ?? now;
  }

  if (initialDate.isBefore(firstDate)) {
    initialDate = firstDate;
  }

  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: DateTime(now.year + 2),
    builder: (context, child) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: AppColors.darkCard,
                  onSurface: AppColors.darkTextPrimary,
                )
              : const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    if (isPickup) {
      provider.updatePickupDate(picked);
    } else {
      provider.updateReturnDate(picked);
    }

    if (provider.pickupDate != null && provider.returnDate != null) {
      provider.loadBookingPreview(listingId);
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookRentalProvider(),
      child: Consumer<BookRentalProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.bg(context),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _DateField(
                                  title: 'PICKUP DATE',
                                  value:
                                      provider.formatDate(provider.pickupDate),
                                  onTap: () => _pickDate(context, true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DateField(
                                  title: 'RETURN DATE',
                                  value:
                                      provider.formatDate(provider.returnDate),
                                  onTap: () => _pickDate(context, false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'DURATION',
                            style: TextStyle(
                              color: AppColors.text1(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _DurationChip(
                                label: '1d',
                                selected: provider.selectedDuration == 1,
                                onTap: () => provider.updateDuration(1),
                              ),
                              const SizedBox(width: 10),
                              _DurationChip(
                                label: '2d',
                                selected: provider.selectedDuration == 2,
                                onTap: () => provider.updateDuration(2),
                              ),
                              const SizedBox(width: 10),
                              _DurationChip(
                                label: '3d',
                                selected: provider.selectedDuration == 3,
                                onTap: () => provider.updateDuration(3),
                              ),
                              const SizedBox(width: 10),
                              _DurationChip(
                                label: '5d',
                                selected: provider.selectedDuration == 5,
                                onTap: () => provider.updateDuration(5),
                              ),
                              const SizedBox(width: 10),
                              _DurationChip(
                                label: '7d',
                                selected: provider.selectedDuration == 7,
                                onTap: () => provider.updateDuration(7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Pickup Method',
                            style: TextStyle(
                              color: AppColors.text1(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _PickupMethodCard(
                                  title: 'Self Pickup',
                                  subtitle: 'Collect from host location',
                                  priceText: 'Free',
                                  icon: Icons.person_pin_circle_outlined,
                                  selected: provider.selfPickup,
                                  onTap: () => provider.updateSelfPickup(true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickupMethodCard(
                                  title: 'Car Delivery',
                                  subtitle: 'Car delivered to you',
                                  priceText: '+PKR 300',
                                  icon: Icons.local_shipping_outlined,
                                  selected: !provider.selfPickup,
                                  onTap: () => provider.updateSelfPickup(false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card(context).withOpacity(0.75),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add Insurance',
                                        style: TextStyle(
                                          color: AppColors.text1(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '+PKR 500/day — Full coverage & emergency',
                                        style: TextStyle(
                                          color: AppColors.text2(context),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: provider.addInsurance,
                                  onChanged: provider.updateInsurance,
                                  activeThumbColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Coupon Code',
                            style: TextStyle(
                              color: AppColors.text1(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.7),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: provider.couponController,
                                    style: TextStyle(
                                      color: AppColors.text1(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter coupon code',
                                      hintStyle: TextStyle(
                                        color: AppColors.text2(context)
                                            .withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Apply',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (provider.isPreviewLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          if (provider.previewError.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                provider.previewError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.card(context).withOpacity(0.82),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price Summary (${provider.selectedDuration} days)',
                                  style: TextStyle(
                                    color: AppColors.text1(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _PriceRow(
                                  label:
                                      'PKR 3,500 × ${provider.selectedDuration} days',
                                  value:
                                      'PKR ${provider.shownBasePrice.toString()}',
                                  valueBold: true,
                                ),
                                const SizedBox(height: 14),
                                _PriceRow(
                                  label: provider.selfPickup
                                      ? 'Self Pickup'
                                      : 'Car Delivery',
                                  value: provider.selfPickup
                                      ? 'Free'
                                      : 'PKR ${provider.pickupCharges}',
                                ),
                                const SizedBox(height: 14),
                                _PriceRow(
                                  label: 'Insurance',
                                  value: provider.addInsurance
                                      ? 'PKR ${provider.insuranceCharges}'
                                      : 'Not added',
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(height: 1),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        color: AppColors.text1(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'PKR ',
                                      style: TextStyle(
                                        color: AppColors.text2(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      provider.shownTotalPrice.toString(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                          onPressed: provider.isBooking
                              ? null
                              : () => _requestRental(context),
                          child: provider.isBooking
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '✓ Request Rental',
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
        },
      ),
    );
  }
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
            color: AppColors.card(context).withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.6),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.text1(context),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Text(
        'Book Rental',
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _DateField extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.card(context).withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.65),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'mm/dd/yyyy'
                          ? AppColors.text2(context).withOpacity(0.8)
                          : AppColors.text1(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.text1(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.secondary.withOpacity(0.7),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.text2(context),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _PickupMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceText;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PickupMethodCard({
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : AppColors.secondary.withOpacity(0.7),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  selected ? const Color(0xFF2563EB) : AppColors.text2(context),
              size: 20,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: AppColors.text1(context),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.text2(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '',
              style: TextStyle(fontSize: 0),
            ),
            Text(
              priceText,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 15,
            fontWeight: valueBold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}