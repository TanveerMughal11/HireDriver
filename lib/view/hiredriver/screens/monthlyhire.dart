import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/provider/hire_monthly.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/screens/avaibledrivers.dart';
import 'package:provider/provider.dart';

class MonthlyHireScreen extends StatefulWidget {
  final Map<String, dynamic> serviceOption;

  const MonthlyHireScreen({
    super.key,
    required this.serviceOption,
  });

  @override
  State<MonthlyHireScreen> createState() => _MonthlyHireScreenState();
}

class _MonthlyHireScreenState extends State<MonthlyHireScreen> {
  final TextEditingController pickupAreaController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? startDate;
  int selectedDuration = 1;
  int selectedHours = 8;

  final List<int> durationOptions = [1, 2, 3, 6];
  final List<int> hourOptions = [4, 6, 8, 12];

  @override
  void dispose() {
    pickupAreaController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _createHireRequest(MonthlyHireProvider provider) async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date')),
      );
      return;
    }

    if (pickupAreaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup area')),
      );
      return;
    }

    final scheduledDate =
        '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';

    const scheduledTime = '09:00';

    final result = await provider.createHireRequest(
      serviceType: widget.serviceOption['id'],
      pickupAddress: pickupAreaController.text.trim(),
      dropoffAddress: pickupAreaController.text.trim(),
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
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
          content: Text(result['message'] ?? 'Error'),
        ),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkCard,
                    onSurface: Colors.white,
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
      setState(() {
        startDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int _monthlyEstimate() {
    const ratePerHour = 120;
    const workingDays = 26;
    return selectedDuration * selectedHours * ratePerHour * workingDays;
  }

  @override
  Widget build(BuildContext context) {
    final estimate = _monthlyEstimate();

    return ChangeNotifierProvider(
      create: (_) => MonthlyHireProvider(),
      builder: (context, child) {
        final provider = context.watch<MonthlyHireProvider>();

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
                        const SizedBox(height: 18),
                        _buildSectionLabel('START DATE'),
                        const SizedBox(height: 8),
                        _buildDateField(),
                        const SizedBox(height: 18),
                        _buildSectionLabel('DURATION (MONTHS)'),
                        const SizedBox(height: 10),
                        Row(
                          children: durationOptions.map((month) {
                            final selected = selectedDuration == month;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right:
                                      month != durationOptions.last ? 10 : 0,
                                ),
                                child: _SelectionBox(
                                  label: '$month',
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      selectedDuration = month;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('DAILY WORKING HOURS'),
                        const SizedBox(height: 10),
                        Row(
                          children: hourOptions.map((hour) {
                            final selected = selectedHours == hour;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: hour != hourOptions.last ? 10 : 0,
                                ),
                                child: _SelectionBox(
                                  label: '${hour}h',
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      selectedHours = hour;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('PICKUP AREA'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: pickupAreaController,
                          hintText: 'Enter pickup area',
                        ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('NOTES TO DRIVER'),
                        const SizedBox(height: 8),
                        _NotesField(
                          controller: notesController,
                          hintText: 'Any timing, route, or work details...',
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.softBg(context),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.75),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MONTHLY ESTIMATE',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'PKR ',
                                    style: TextStyle(
                                      color: AppColors.text2(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    widget.serviceOption['monthlyRate'] != null
                                        ? '${widget.serviceOption['monthlyRate']}'
                                        : '$estimate',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$selectedDuration month · $selectedHours hrs/day · ${widget.serviceOption['rateLabel'] ?? '~PKR 120/hr'}',
                                style: TextStyle(
                                  color: AppColors.text2(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: AppColors.text2(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Includes: ',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'fuel negotiable, insurance optional',
                                    ),
                                  ],
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
                            : () => _createHireRequest(provider),
                        child: provider.isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Find Monthly Drivers →',
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
              color: AppColors.card(context).withOpacity(0.9),
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
          widget.serviceOption['title'] ?? 'Monthly Hire',
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickStartDate,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatDate(startDate),
                style: TextStyle(
                  color: startDate == null
                      ? AppColors.text2(context).withOpacity(0.8)
                      : AppColors.text1(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.text1(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.softBg(context)
              : AppColors.card(context).withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.secondary,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.text2(context),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
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
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.9),
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
            vertical: 16,
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

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _NotesField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.7),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.text2(context).withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}