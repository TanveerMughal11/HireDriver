import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/provider/my_car_listing.dart';
import 'package:provider/provider.dart';

class MyCarListingsScreen extends StatelessWidget {
  const MyCarListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyCarListingsProvider()..loadListings(),
      child: const _MyCarListingsBody(),
    );
  }
}

class _MyCarListingsBody extends StatelessWidget {
  const _MyCarListingsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCarListingsProvider>(
      builder: (context, provider, _) {
        if (provider.errorMessage.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage)),
            );
          });
        }

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          appBar: AppBar(
            backgroundColor: AppColors.bg(context),
            elevation: 0,
            title: Text(
              'My Car Listings',
              style: TextStyle(
                color: AppColors.text1(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.text1(context)),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.listings.isEmpty
                  ? Center(
                      child: Text(
                        'No car listings found',
                        style: TextStyle(
                          color: AppColors.text2(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.loadListings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.listings.length,
                        itemBuilder: (context, index) {
                          final item = provider.listings[index];
                          final car = item['carInfo'] ?? {};
                          final pricing = item['pricing'] ?? {};
                          final rating = item['rating'] ?? {};

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.directions_car_rounded,
                                        color: AppColors.primary,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${car['make'] ?? ''} ${car['model'] ?? ''}',
                                            style: TextStyle(
                                              color: AppColors.text1(context),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            car['plateNumber'] ??
                                                'No plate number',
                                            style: TextStyle(
                                              color: AppColors.text2(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusBadge(
                                      status:
                                          item['approvalStatus'] ?? 'pending',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _InfoRow(
                                  icon: Icons.calendar_month,
                                  title: 'Year',
                                  value: '${car['year'] ?? '-'}',
                                ),
                                _InfoRow(
                                  icon: Icons.color_lens,
                                  title: 'Color',
                                  value: '${car['color'] ?? '-'}',
                                ),
                                _InfoRow(
                                  icon: Icons.event_seat,
                                  title: 'Seats',
                                  value: '${car['seatingCapacity'] ?? '-'}',
                                ),
                                _InfoRow(
                                  icon: Icons.location_on,
                                  title: 'Location',
                                  value: '${car['locationArea'] ?? '-'}',
                                ),
                                _InfoRow(
                                  icon: Icons.local_gas_station,
                                  title: 'Fuel / Transmission',
                                  value:
                                      '${car['fuelType'] ?? '-'} / ${car['transmission'] ?? '-'}',
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SmallBox(
                                        title: 'Daily Rate',
                                        value: pricing['dailyRate'] == null
                                            ? 'Not set'
                                            : 'PKR ${pricing['dailyRate']}',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _SmallBox(
                                        title: 'Min Days',
                                        value: pricing['minRentalDays'] == null
                                            ? 'Not set'
                                            : '${pricing['minRentalDays']} day',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SmallBox(
                                        title: 'Rating',
                                        value:
                                            '${rating['avg'] ?? 0} (${rating['count'] ?? 0})',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _SmallBox(
                                        title: 'Published',
                                        value: item['isPublished'] == true
                                            ? 'Yes'
                                            : 'No',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Available Days: ${(pricing['availableDays'] as List?)?.join(', ') ?? 'Not set'}',
                                  style: TextStyle(
                                    color: AppColors.text2(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    if (status == 'approved') {
      color = Colors.green;
    } else if (status == 'rejected') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.text2(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBox extends StatelessWidget {
  final String title;
  final String value;

  const _SmallBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text1(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}