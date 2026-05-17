import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/forms/provider/carlistingform.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ListMyCarFlowScreen extends StatelessWidget {
  const ListMyCarFlowScreen({super.key});

  Future<void> _showMessage(
    BuildContext context,
    Map<String, dynamic> res,
    String successMessage,
  ) async {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res['success'] == true
              ? successMessage
              : res['message'] ?? 'Something went wrong',
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(BuildContext context, ListMyCarProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return _CarInfoStep(
          onNext: () async {
            final res = await provider.handleCarSubmit();

            if (!context.mounted) return;

            if (res['success'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Car submit failed')),
              );
            }
          },
          carMakeController: provider.carMakeController,
          modelController: provider.modelController,
          yearController: provider.yearController,
          colorController: provider.colorController,
          plateController: provider.plateController,
          locationController: provider.locationController,
          seatingController: provider.seatingController,
        );

      case 1:
        return _PhotosStep(
          onNext: () async {
            final res = await provider.handlePhotoUpload();
            await _showMessage(context, res, 'Photos uploaded successfully');
          },
          photos: provider.photos,
          photoLabels: provider.photoLabels,
          onTogglePhoto: (index) async {
            await provider.pickPhoto(index);
          },
        );

      case 2:
        return _PricingStep(
          onSubmit: () async {
            final res = await provider.handlePricingSubmit();
            await _showMessage(context, res, 'Listing submitted successfully');
          },
          dailyRateController: provider.dailyRateController,
          minimumRentalDaysController: provider.minimumRentalDaysController,
          availability: provider.availability,
          onToggleDay: provider.toggleDay,
          insuranceUploaded: provider.insuranceUploaded,
          registrationUploaded: provider.registrationUploaded,
          onInsuranceTap: () async {
            await provider.pickInsurance();
          },
          onRegistrationTap: () async {
            await provider.pickRegistration();
          },
          monthlyEstimate: provider.monthlyEstimate,
          platformFee: provider.platformFee,
        );

      default:
        return const _SubmittedStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListMyCarProvider(),
      child: Consumer<ListMyCarProvider>(
        builder: (context, provider, _) {
          return _buildCurrentScreen(context, provider);
        },
      ),
    );
  }
}

class _CarInfoStep extends StatefulWidget {
  final VoidCallback onNext;
  final TextEditingController carMakeController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController colorController;
  final TextEditingController plateController;
  final TextEditingController locationController;
  final TextEditingController seatingController;

  const _CarInfoStep({
    required this.onNext,
    required this.carMakeController,
    required this.modelController,
    required this.yearController,
    required this.colorController,
    required this.plateController,
    required this.locationController,
    required this.seatingController,
  });

  @override
  State<_CarInfoStep> createState() => _CarInfoStepState();
}

class _CarInfoStepState extends State<_CarInfoStep> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopHeader(title: 'List My Car'),
                const SizedBox(height: 18),
                const _StepProgress(
                  currentStep: 1,
                  firstDone: false,
                  secondDone: false,
                ),
                const SizedBox(height: 22),
                const _FieldLabel(title: 'CAR MAKE'),
                _buildField(
                  controller: widget.carMakeController,
                  hint: 'e.g. Toyota',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter car make' : null,
                ),
                const SizedBox(height: 14),
                const _FieldLabel(title: 'MODEL'),
                _buildField(
                  controller: widget.modelController,
                  hint: 'e.g. Corolla',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter model' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(title: 'YEAR'),
                          _buildField(
                            controller: widget.yearController,
                            hint: 'e.g. 2020',
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter year';
                              }
                              if (v.length != 4) {
                                return 'Enter valid year';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(title: 'COLOR'),
                          _buildField(
                            controller: widget.colorController,
                            hint: 'e.g. Silver',
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter color' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _FieldLabel(title: 'PLATE NUMBER'),
                _buildField(
                  controller: widget.plateController,
                  hint: 'e.g. LEH-1123',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Plate number required';
                    }
                    final regex = RegExp(r'^[A-Z]{3}-\d{4}$');
                    if (!regex.hasMatch(v)) {
                      return 'Use correct format (LEH-1123)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const _FieldLabel(title: 'SEATING CAPACITY'),
                _buildField(
                  controller: widget.seatingController,
                  hint: 'e.g. 5',
                  keyboard: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter seating';
                    }
                    final num = int.tryParse(v);
                    if (num == null || num <= 0) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const _FieldLabel(title: 'LOCATION / AREA'),
                _buildField(
                  controller: widget.locationController,
                  hint: 'e.g. DHA Phase 5, Lahore',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter location' : null,
                ),
                const SizedBox(height: 24),
                _PrimaryActionButton(
                  title: 'Next: Add Photos →',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onNext();
                    }
                  },
                  color: const Color(0xFF2E64E8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text1(context),
        ),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.card(context).withOpacity(0.7),
          counterText: '',
          hintStyle: TextStyle(
            color: AppColors.text2(context).withOpacity(0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.secondary.withOpacity(0.65),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.secondary.withOpacity(0.65),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _PhotosStep extends StatelessWidget {
  final VoidCallback onNext;
  final List<String> photoLabels;
  final List<XFile?> photos;
  final Function(int) onTogglePhoto;

  const _PhotosStep({
    required this.onNext,
    required this.photoLabels,
    required this.photos,
    required this.onTogglePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopHeader(title: 'List My Car'),
              const SizedBox(height: 18),
              const _StepProgress(
                currentStep: 2,
                firstDone: true,
                secondDone: false,
              ),
              const SizedBox(height: 20),
              Text(
                'Add clear photos to get 3× more bookings. Minimum 4 required.',
                style: TextStyle(
                  color: AppColors.text2(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  itemCount: photoLabels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = photos[index] != null;

                    return GestureDetector(
                      onTap: () => onTogglePhoto(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.card(context).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary.withOpacity(0.7),
                            width: isSelected ? 2 : 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.photo_camera_rounded,
                              size: 34,
                              color: isSelected
                                  ? Colors.green
                                  : AppColors.text2(context),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              photoLabels[index],
                              style: TextStyle(
                                color: AppColors.text2(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _PrimaryActionButton(
                title: 'Next: Set Pricing →',
                onTap: onNext,
                color: const Color(0xFF2E64E8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingStep extends StatelessWidget {
  final VoidCallback onSubmit;
  final TextEditingController dailyRateController;
  final TextEditingController minimumRentalDaysController;
  final List<Map<String, dynamic>> availability;
  final Function(int) onToggleDay;
  final bool insuranceUploaded;
  final bool registrationUploaded;
  final VoidCallback onInsuranceTap;
  final VoidCallback onRegistrationTap;
  final int monthlyEstimate;
  final int platformFee;

  const _PricingStep({
    required this.onSubmit,
    required this.dailyRateController,
    required this.minimumRentalDaysController,
    required this.availability,
    required this.onToggleDay,
    required this.insuranceUploaded,
    required this.registrationUploaded,
    required this.onInsuranceTap,
    required this.onRegistrationTap,
    required this.monthlyEstimate,
    required this.platformFee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopHeader(title: 'List My Car'),
              const SizedBox(height: 18),
              const _StepProgress(
                currentStep: 3,
                firstDone: true,
                secondDone: true,
              ),
              const SizedBox(height: 22),
              const _FieldLabel(title: 'DAILY RATE (PKR)'),
              _SimpleField(
                controller: dailyRateController,
                hintText: 'Enter daily rate (PKR)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 14),
              const _FieldLabel(title: 'MINIMUM RENTAL DAYS'),
              _SimpleField(
                controller: minimumRentalDaysController,
                hintText: 'Enter minimum rental days',
                keyboardType: TextInputType.number,
                maxLength: 2,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 18),
              const _FieldLabel(title: 'AVAILABILITY SCHEDULE'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  availability.length,
                  (index) => GestureDetector(
                    onTap: () => onToggleDay(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: availability[index]['selected']
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.card(context).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: availability[index]['selected']
                              ? AppColors.primary
                              : AppColors.secondary.withOpacity(0.6),
                        ),
                      ),
                      child: Text(
                        availability[index]['day'],
                        style: TextStyle(
                          color: availability[index]['selected']
                              ? AppColors.primary
                              : AppColors.text2(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel(title: 'INSURANCE DOCUMENT'),
              const SizedBox(height: 8),
              _UploadCard(
                title: insuranceUploaded
                    ? 'Insurance document uploaded'
                    : 'Upload insurance document',
                uploaded: insuranceUploaded,
                onTap: onInsuranceTap,
              ),
              const SizedBox(height: 14),
              const _FieldLabel(title: 'VEHICLE REGISTRATION'),
              const SizedBox(height: 8),
              _UploadCard(
                title: registrationUploaded
                    ? 'Registration uploaded'
                    : 'Upload vehicle registration',
                uploaded: registrationUploaded,
                onTap: onRegistrationTap,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F3A2B)
                      : const Color(0xFFAEE7C9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.green.withOpacity(0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 POTENTIAL MONTHLY EARNINGS',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PKR ${monthlyEstimate.toString()}+',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Based on PKR ${dailyRateController.text}/day × 18 days/month',
                      style: TextStyle(
                        color: AppColors.text2(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Platform fee: 12% (just PKR $platformFee/mo)',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _PrimaryActionButton(
                title: 'Submit for Approval ✓',
                onTap: onSubmit,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmittedStep extends StatelessWidget {
  const _SubmittedStep();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 18),
              Text(
                'Listing Submitted!',
                style: TextStyle(
                  color: AppColors.text1(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Your car listing is under review. We'll verify it and notify you within 24 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text2(context),
                  fontSize: 17,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3A321C)
                      : const Color(0xFFF3E7B8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    _StatusRow(title: 'Listing Received', active: true),
                    Divider(),
                    _StatusRow(
                      title: 'Admin Review · In Progress',
                      active: true,
                    ),
                    Divider(),
                    _StatusRow(title: 'Approval', active: false),
                    Divider(),
                    _StatusRow(title: 'Go Live', active: false),
                  ],
                ),
              ),
              const Spacer(),
              _PrimaryActionButton(
                title: 'Back to Home',
                onTap: () {
                  Navigator.pop(context);
                },
                color: Color(0xFF2E64E8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String title;

  const _TopHeader({required this.title});

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: AppColors.secondary.withOpacity(0.6)),
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
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.text1(context),
          ),
        ),
      ],
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final bool firstDone;
  final bool secondDone;

  const _StepProgress({
    required this.currentStep,
    required this.firstDone,
    required this.secondDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _stepCircle(
              context: context,
              label: firstDone ? '✓' : '1',
              active: currentStep == 1,
              done: firstDone,
            ),
            _line(active: currentStep > 1),
            _stepCircle(
              context: context,
              label: secondDone ? '✓' : '2',
              active: currentStep == 2,
              done: secondDone,
            ),
            _line(active: currentStep > 2),
            _stepCircle(
              context: context,
              label: '3',
              active: currentStep == 3,
              done: false,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'CAR INFO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E64E8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'PHOTOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E64E8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'PRICING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E64E8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepCircle({
    required BuildContext context,
    required String label,
    required bool active,
    required bool done,
  }) {
    Color bg;
    if (done) {
      bg = Colors.green;
    } else if (active) {
      bg = const Color(0xFF2E64E8);
    } else {
      bg = Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFE4EAF6);
    }

    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: active || done
            ? [
                BoxShadow(
                  color: bg.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: done || active ? Colors.white : AppColors.text2(context),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _line({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? Colors.green : const Color(0xFFDCE3F1),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String title;

  const _FieldLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SimpleField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  const _SimpleField({
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.65)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text1(context),
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.text2(context).withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final bool uploaded;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.uploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context).withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploaded
                ? Colors.green
                : AppColors.secondary.withOpacity(0.65),
            width: uploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              uploaded ? Icons.check_circle : Icons.upload_file_rounded,
              color: uploaded ? Colors.green : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.text1(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _PrimaryActionButton({
    required this.title,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String title;
  final bool active;

  const _StatusRow({required this.title, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: active ? Colors.orange : const Color(0xFFD7DDE7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: active
                  ? AppColors.text1(context)
                  : AppColors.text2(context),
              fontSize: 16,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
