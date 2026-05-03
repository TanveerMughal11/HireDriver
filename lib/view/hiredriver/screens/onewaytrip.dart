import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/provider/hire_driver_request.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/screens/avaibledrivers.dart';
import 'package:provider/provider.dart';

class OneWayTripScreen extends StatefulWidget {
  final Map<String, dynamic> serviceOption;

  const OneWayTripScreen({
    super.key,
    required this.serviceOption,
  });

  @override
  State<OneWayTripScreen> createState() => _OneWayTripScreenState();
}

class _OneWayTripScreenState extends State<OneWayTripScreen> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController vehiclePlateController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    vehiclePlateController.dispose();
    super.dispose();
  }

  Future<void> _createHireRequest(BuildContext context) async {
    final provider = context.read<HireRequestProvider>();

    final result = await provider.createOneWayRequest(
      serviceOption: widget.serviceOption,
      pickupAddress: pickupController.text,
      dropoffAddress: dropoffController.text,
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      vehicleModel: vehicleModelController.text,
      vehicleColor: vehicleColorController.text,
      plateNumber: vehiclePlateController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AvailableDriversScreen(
            hireRequestId: result['hireRequestId'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Something went wrong'),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.card(context),
              surface: AppColors.card(context),
              onSurface: AppColors.text1(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.card(context),
              surface: AppColors.card(context),
              onSurface: AppColors.text1(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:-- --';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HireRequestProvider(),
      child: Consumer<HireRequestProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.bg(context),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 16),
                          _buildLocationCard(),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _PickerField(
                                  title: 'DATE',
                                  value: _formatDate(selectedDate),
                                  icon: Icons.calendar_today_outlined,
                                  onTap: _pickDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickerField(
                                  title: 'TIME',
                                  value: _formatTime(selectedTime),
                                  icon: Icons.access_time_rounded,
                                  onTap: _pickTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildSectionLabel('YOUR VEHICLE'),
                          const SizedBox(height: 10),
                          _InputField(
                            controller: vehicleModelController,
                            hintText: 'Vehicle model',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  controller: vehicleColorController,
                                  hintText: 'Color',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InputField(
                                  controller: vehiclePlateController,
                                  hintText: 'Plate number',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.75),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FARE ESTIMATE',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Final fare calculated after trip',
                                        style: TextStyle(
                                          color: AppColors.text2(context),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.serviceOption['rateLabel'] ??
                                      'PKR 150-200',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
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
                          onPressed: provider.isSubmitting
                              ? null
                              : () => _createHireRequest(context),
                          child: provider.isSubmitting
                              ? SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.card(context),
                                  ),
                                )
                              : Text(
                                  'Find Available Drivers →',
                                  style: TextStyle(
                                    color: AppColors.card(context),
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
              color: AppColors.card(context).withOpacity(0.75),
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
          widget.serviceOption['title'] ?? 'One-Way Trip',
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: Column(
        children: [
          _LocationRow(
            label: 'PICKUP',
            controller: pickupController,
            dotColor: AppColors.primary,
            hintText: 'Select pickup location',
            icon: Icons.my_location_rounded,
            onMapTap: () {},
          ),
          Divider(
            height: 1,
            color: AppColors.secondary.withOpacity(0.7),
          ),
          _LocationRow(
            label: 'DROP-OFF',
            controller: dropoffController,
            dotColor: const Color(0xFFFF7A30),
            hintText: 'Enter destination...',
            icon: Icons.place_rounded,
            onMapTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text1(context),
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color dotColor;
  final String hintText;
  final IconData icon;
  final VoidCallback onMapTap;

  const _LocationRow({
    required this.label,
    required this.controller,
    required this.dotColor,
    required this.hintText,
    required this.icon,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: dotColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.text2(context).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onMapTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.softBg(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: dotColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.title,
    required this.value,
    required this.icon,
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
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.card(context).withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.7),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value.contains('mm') || value.contains('--')
                          ? AppColors.text2(context).withOpacity(0.8)
                          : AppColors.text1(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 19,
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _InputField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.text2(context).withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}