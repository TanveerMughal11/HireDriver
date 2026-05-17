import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/screens/carrentingdetail.dart';
import 'package:hire_driver/view/car%20rental/provider/browse_car.dart';
import 'package:provider/provider.dart';

class BrowseCarsScreen extends StatelessWidget {
  const BrowseCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrowseCarsProvider()..fetchCars(),
      child: const _BrowseCarsScreenBody(),
    );
  }
}

class _BrowseCarsScreenBody extends StatelessWidget {
  const _BrowseCarsScreenBody();

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate(BuildContext context, bool isPickup) async {
    final provider = context.read<BrowseCarsProvider>();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: AppColors.white,
                    surface: AppColors.darkCard,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.white,
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
    }
  }

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<BrowseCarsProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer<BrowseCarsProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.70,
                minChildSize: 0.45,
                maxChildSize: 0.92,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 5,
                            width: 55,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text1(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DropdownField(
                                label: 'City',
                                value: provider.selectedCity,
                                items: const [
                                  'Lahore',
                                  'Karachi',
                                  'Islamabad',
                                  'Multan',
                                ],
                                onChanged: (value) {
                                  provider.updateCity(value!);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropdownField(
                                label: 'Seats',
                                value: provider.selectedSeats,
                                items: const [
                                  '2 Seats',
                                  '4 Seats',
                                  '5 Seats',
                                  '7 Seats',
                                  '10 Seats',
                                ],
                                onChanged: (value) {
                                  provider.updateSeats(value!);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DropdownField(
                                label: 'Price',
                                value: provider.selectedPrice,
                                items: const [
                                  'Any Price',
                                  'Under 4,000',
                                  '4,000 - 6,000',
                                  'Above 6,000',
                                ],
                                onChanged: (value) {
                                  provider.updatePrice(value!);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropdownField(
                                label: 'Type',
                                value: provider.selectedCarType,
                                items: const ['All', 'Sedan', 'SUV', 'Van'],
                                onChanged: (value) {
                                  provider.updateType(value!);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              provider.fetchCars();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showSortSheet(BuildContext context) {
    final options = [
      'Recommended',
      'Price Low to High',
      'Price High to Low',
      'Top Rated',
      'Newest Model',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<BrowseCarsProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 55,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sort Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...options.map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text1(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: provider.selectedSort == item
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          provider.updateSort(item);
                          Navigator.pop(context);
                          provider.fetchCars();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getImage(Map<String, dynamic> car) {
    final photos = car['photos'];
    if (photos is Map<String, dynamic>) {
      return photos['front'] ??
          photos['sideView'] ??
          photos['back'] ??
          photos['interior'] ??
          'https://via.placeholder.com/640x360';
    }
    return 'https://via.placeholder.com/640x360';
  }

  String _getName(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return '${carInfo['make'] ?? ''} ${carInfo['model'] ?? ''}'.trim();
  }

  String _getPrice(Map<String, dynamic> car) {
    final pricing = car['pricing'] ?? {};
    return 'PKR ${pricing['dailyRate'] ?? 0}/day';
  }

  String _getLocation(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return carInfo['locationArea'] ?? 'Unknown location';
  }

  String _getYearColorSeats(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return '${carInfo['year'] ?? ''} · ${carInfo['color'] ?? ''} · ${carInfo['seatingCapacity'] ?? ''} seats';
  }

  String _getType(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return carInfo['carType'] ?? 'Car';
  }

  String _getRating(Map<String, dynamic> car) {
    final rating = car['rating'] ?? {};
    final avg = rating['avg'] ?? 0;
    return avg.toString();
  }

  bool _isAvailable(Map<String, dynamic> car) {
    return car['isPublished'] == true && car['approvalStatus'] == 'approved';
  }

  String _getFuelType(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return carInfo['fuelType'] ?? 'N/A';
  }

  String _getTransmission(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return carInfo['transmission'] ?? 'N/A';
  }

  bool _isInsured(Map<String, dynamic> car) {
    final carInfo = car['carInfo'] ?? {};
    return carInfo['isInsured'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BrowseCarsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg(context),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    children: [
                      Row(
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
                                border:
                                    Border.all(color: AppColors.secondary),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.text1(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Browse Cars',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text1(context),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _showSortSheet(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card(context),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.secondary),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.swap_vert_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sort',
                                    style: TextStyle(
                                      color: AppColors.text1(context),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.secondary),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: provider.searchController,
                                onSubmitted: (_) => provider.fetchCars(),
                                style: TextStyle(
                                  color: AppColors.text1(context),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search cars...',
                                  hintStyle: TextStyle(
                                    color: AppColors.text2(context),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showFilterSheet(context),
                              icon: const Icon(
                                Icons.tune_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DateCard(
                              title: 'PICKUP DATE',
                              value: _formatDate(provider.pickupDate),
                              titleColor: AppColors.primary,
                              onTap: () => _pickDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateCard(
                              title: 'RETURN DATE',
                              value: _formatDate(provider.returnDate),
                              titleColor: AppColors.darkPrimary,
                              onTap: () => _pickDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.carTypes.length + 4,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index < provider.carTypes.length) {
                              final type = provider.carTypes[index];
                              final selected =
                                  provider.selectedCarType == type;
                              return _TopChip(
                                label: type,
                                selected: selected,
                                onTap: () {
                                  provider.updateType(type);
                                  provider.fetchCars();
                                },
                              );
                            }

                            final extra = [
                              provider.selectedCity,
                              provider.selectedPrice,
                              provider.selectedSeats,
                              provider.selectedSort,
                            ][index - provider.carTypes.length];

                            return _TopChip(
                              label: extra,
                              selected: false,
                              onTap: index == provider.carTypes.length + 3
                                  ? () => _showSortSheet(context)
                                  : () => _showFilterSheet(context),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : provider.errorMessage.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      provider.errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: provider.fetchCars,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : provider.cars.isEmpty
                              ? Center(
                                  child: Text(
                                    'No cars found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text2(context),
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: provider.fetchCars,
                                  color: AppColors.primary,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      0,
                                      14,
                                      16,
                                    ),
                                    itemCount: provider.cars.length,
                                    itemBuilder: (context, index) {
                                      final car = provider.cars[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: _CarCard(
                                          image: _getImage(car),
                                          name: _getName(car),
                                          price: _getPrice(car),
                                          location: _getLocation(car),
                                          details: _getYearColorSeats(car),
                                          rating: _getRating(car),
                                          type: _getType(car),
                                          available: _isAvailable(car),
                                          fuelType: _getFuelType(car),
                                          transmission:
                                              _getTransmission(car),
                                          insured: _isInsured(car),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CarDetailsScreen(
                                                  listingId:
                                                      car['id'].toString(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateCard extends StatelessWidget {
  final String title;
  final String value;
  final Color titleColor;
  final VoidCallback onTap;

  const _DateCard({
    required this.title,
    required this.value,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text1(context),
                    ),
                  ),
                ],
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
    );
  }
}

class _TopChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card(context),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.secondary,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.text2(context),
          ),
        ),
      ),
    );
  }
}
class _CarCard extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final String location;
  final String details;
  final String rating;
  final String type;
  final bool available;
  final String fuelType;
  final String transmission;
  final bool insured;
  final VoidCallback onTap;

  const _CarCard({
    required this.image,
    required this.name,
    required this.price,
    required this.location,
    required this.details,
    required this.rating,
    required this.type,
    required this.available,
    required this.fuelType,
    required this.transmission,
    required this.insured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.network(
                image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.softBg(context),
                    child: const Icon(
                      Icons.directions_car,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '',
                    style: TextStyle(fontSize: 0),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text2(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text2(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(
                        rating,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1(context),
                        ),
                      ),
                      _MiniTag(
                        text: type,
                        bg: AppColors.softBg(context),
                        fg: AppColors.primary,
                      ),
                      _MiniTag(
                        text: available ? 'Available' : 'Booked',
                        bg: available
                            ? const Color(0xFFDDF5E8)
                            : const Color(0xFFF9E1E1),
                        fg: available
                            ? const Color(0xFF1E9B62)
                            : const Color(0xFFC84F4F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SpecTag(
                        icon: Icons.local_gas_station,
                        text: fuelType,
                      ),
                      _SpecTag(
                        icon: Icons.settings,
                        text: transmission,
                      ),
                      _SpecTag(
                        icon: Icons.verified_user_outlined,
                        text: insured ? 'Insured' : 'Not insured',
                      ),
                    ],
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

class _MiniTag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _MiniTag({
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpecTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SpecTag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.text2(context)),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text2(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: AppColors.card(context),
        style: TextStyle(
          color: AppColors.text1(context),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          labelStyle: TextStyle(
            color: AppColors.text2(context),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.text1(context),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text1(context),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}