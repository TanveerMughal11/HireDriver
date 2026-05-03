import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hire_driver/view/forms/provider/applyasrider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hire_driver/utils/app_colors.dart';

class ApplyAsRiderScreen extends StatefulWidget {
  const ApplyAsRiderScreen({super.key});

  @override
  State<ApplyAsRiderScreen> createState() =>
      _ApplyAsRiderScreenState();
}

class _ApplyAsRiderScreenState extends State<ApplyAsRiderScreen> {
  final ImagePicker _picker = ImagePicker();

  final TextEditingController cnicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController vehicleController = TextEditingController();

  final TextEditingController plateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ApplyAsRiderProvider>().loadMyApplication(
            fullNameController: fullNameController,
            cnicController: cnicController,
            dobController: dobController,
            addressController: addressController,
            vehicleController: vehicleController,
            plateController: plateController,
          );
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    cnicController.dispose();
    dobController.dispose();
    addressController.dispose();
    vehicleController.dispose();
    plateController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String type) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked == null) return;

    if (!mounted) return;
    context.read<ApplyAsRiderProvider>().pickDocument(type, picked);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      if (!mounted) return;
      context.read<ApplyAsRiderProvider>().setDob(value, dobController);
    }
  }

  Future<void> _nextStep() async {
    final provider = context.read<ApplyAsRiderProvider>();

    final message = await provider.nextStep(
      fullNameController: fullNameController,
      cnicController: cnicController,
      dobController: dobController,
      addressController: addressController,
      vehicleController: vehicleController,
      plateController: plateController,
    );

    if (message != null && message.isNotEmpty) {
      _showSnack(message);
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplyAsRiderProvider>();

    if (provider.currentStep == 4) {
      return _ApplicationSubmittedScreen(
        onBackHome: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBanner(),
                    const SizedBox(height: 22),
                    _buildStepper(provider),
                    const SizedBox(height: 22),
                    if (provider.currentStep == 0)
                      _buildPersonalInfoStep(provider),
                    if (provider.currentStep == 1)
                      _buildDocumentsStep(provider),
                    if (provider.currentStep == 2) _buildVehicleStep(provider),
                    if (provider.currentStep == 3) _buildConsentStep(provider),
                  ],
                ),
              ),
            ),
            _buildBottomButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Apply as Rider',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPrimary, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.amber,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earn PKR 40,000–80,000/month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Work on your own schedule · No lease',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(ApplyAsRiderProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _EqualStepItem(
            index: 0,
            title: 'PERSONAL\nINFO',
            currentStep: provider.currentStep,
          ),
        ),
        Expanded(
          child: _EqualStepItem(
            index: 1,
            title: 'DOCUMENTS',
            currentStep: provider.currentStep,
          ),
        ),
        Expanded(
          child: _EqualStepItem(
            index: 2,
            title: 'VEHICLE',
            currentStep: provider.currentStep,
          ),
        ),
        Expanded(
          child: _EqualStepItem(
            index: 3,
            title: 'CONSENT',
            currentStep: provider.currentStep,
            isLast: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep(ApplyAsRiderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('FULL NAME'),
        const SizedBox(height: 8),
        _textField(
          controller: fullNameController,
          hint: 'e.g. Muhammad Ali',
          errorText: provider.fullNameError,
          keyboardType: TextInputType.name,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),
        const SizedBox(height: 14),
        _label('CNIC NUMBER'),
        const SizedBox(height: 8),
        _textField(
          controller: cnicController,
          hint: 'e.g. 3520212345671',
          errorText: provider.cnicError,
          keyboardType: TextInputType.number,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 14),
        _label('DATE OF BIRTH'),
        const SizedBox(height: 8),
        _dateField(
          controller: dobController,
          hint: 'e.g. 1998-05-21',
          errorText: provider.dobError,
          onTap: _pickDob,
        ),
        const SizedBox(height: 14),
        _label('HOME ADDRESS'),
        const SizedBox(height: 8),
        _textField(
          controller: addressController,
          hint: 'e.g. House 12, Street 5, Lahore',
          errorText: provider.addressError,
          keyboardType: TextInputType.streetAddress,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,.-]')),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsStep(ApplyAsRiderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Take clear photos using your camera. Gallery upload is not allowed.',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Make sure document text is clearly visible.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _uploadTile(
          title: 'Take CNIC Front Photo',
          uploaded: provider.cnicFrontFile != null,
          onTap: () => _pickDocument('cnicFront'),
        ),
        const SizedBox(height: 12),
        _uploadTile(
          title: 'Take CNIC Back Photo',
          uploaded: provider.cnicBackFile != null,
          onTap: () => _pickDocument('cnicBack'),
        ),
        const SizedBox(height: 12),
        _uploadTile(
          title: 'Take Profile Photo',
          uploaded: false,
          onTap: () {
            _showSnack('Profile photo feature coming soon');
          },
        ),
        const SizedBox(height: 12),
        _uploadTile(
          title: 'Take Driving License Front Photo',
          uploaded: provider.licenseFrontFile != null,
          onTap: () => _pickDocument('licenseFront'),
        ),
        const SizedBox(height: 12),
        _uploadTile(
          title: 'Take Driving License Back Photo',
          uploaded: provider.licenseBackFile != null,
          onTap: () => _pickDocument('licenseBack'),
        ),
      ],
    );
  }

  Widget _buildVehicleStep(ApplyAsRiderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('VEHICLE MAKE & MODEL'),
        const SizedBox(height: 8),
        _textField(
          controller: vehicleController,
          hint: 'e.g. Toyota Corolla 2020',
          errorText: provider.vehicleError,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
          ],
        ),
        const SizedBox(height: 14),
        _label('PLATE NUMBER'),
        const SizedBox(height: 8),
        _textField(
          controller: plateController,
          hint: 'e.g. LEA-1234',
          errorText: provider.plateError,
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
        ),
        const SizedBox(height: 18),
        const Text(
          "Services You'll Provide",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _serviceOption(
          selected: provider.hireDriverService,
          title: "Hire a Rider (use passenger's car)",
          onTap: provider.toggleHireDriverService,
        ),
        const SizedBox(height: 12),
        _serviceOption(
          selected: provider.bookRideService,
          title: 'Book a Ride (use my own car)',
          onTap: provider.toggleBookRideService,
        ),
        if (provider.serviceError != null) ...[
          const SizedBox(height: 8),
          Text(
            provider.serviceError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConsentStep(ApplyAsRiderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.secondary.withOpacity(0.6)),
          ),
          child: Text(
            "By applying as a Rider on HireDrive, you consent to a background check, CNIC verification, and agree to our Rider Terms of Service.",
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.88),
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: provider.toggleConsent,
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color:
                      provider.consentAccepted ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: provider.consentAccepted
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
                child: provider.consentAccepted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'I agree to the terms and consent',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (provider.consentError != null) ...[
          const SizedBox(height: 8),
          Text(
            provider.consentError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomButton(ApplyAsRiderProvider provider) {
    final List<String> buttonTexts = [
      'Next: Documents →',
      'Next: Vehicle Info →',
      'Next: Review & Sign →',
      'Submit Application ✓',
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: provider.isLoading ? null : _nextStep,
            child: provider.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    buttonTexts[provider.currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : AppColors.secondary.withOpacity(0.8),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.55),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _dateField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: errorText != null
                    ? Colors.red
                    : AppColors.secondary.withOpacity(0.8),
              ),
            ),
            child: IgnorePointer(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _uploadTile({
    required String title,
    required bool uploaded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF16A34A).withOpacity(0.6)
                : AppColors.secondary.withOpacity(0.7),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                uploaded ? Icons.check_circle : Icons.camera_alt_rounded,
                color: uploaded ? const Color(0xFF16A34A) : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              uploaded ? 'Captured ✓' : 'Camera →',
              style: TextStyle(
                color: uploaded
                    ? const Color(0xFF16A34A)
                    : AppColors.textSecondary.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceOption({
    required bool selected,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                selected ? AppColors.primary : AppColors.secondary.withOpacity(0.65),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
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

class _ApplicationSubmittedScreen extends StatelessWidget {
  final VoidCallback onBackHome;

  const _ApplicationSubmittedScreen({
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'title': 'Application Received', 'done': true, 'icon': Icons.check_circle},
      {'title': 'Document Review', 'done': true, 'icon': Icons.hourglass_bottom},
      {
        'title': 'Background Check',
        'done': false,
        'icon': Icons.verified_user_outlined
      },
      {'title': 'CNIC Verification', 'done': false, 'icon': Icons.badge_outlined},
      {
        'title': 'Approval & Activation',
        'done': false,
        'icon': Icons.celebration_outlined
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 26),
              Container(
                height: 86,
                width: 86,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Application Submitted!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Our team will review your application and verify your documents within 24–48 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.85),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.light.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: AppColors.secondary.withOpacity(0.6)),
                ),
                child: Column(
                  children: List.generate(steps.length, (index) {
                    final step = steps[index];
                    final done = step['done'] as bool;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        border: index != steps.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: AppColors.secondary.withOpacity(0.5),
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppColors.primary
                                  : AppColors.secondary.withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step['title'] as String,
                              style: TextStyle(
                                color: done
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.75),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            step['icon'] as IconData,
                            size: 16,
                            color: done
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: onBackHome,
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EqualStepItem extends StatelessWidget {
  final int index;
  final int currentStep;
  final String title;
  final bool isLast;

  const _EqualStepItem({
    required this.index,
    required this.currentStep,
    required this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = index < currentStep;
    final bool isActive = index == currentStep;

    final Color activeGreen = const Color(0xFF10B981);
    final Color pendingPurple = const Color(0xFF6E68B6);
    final Color inactiveLine = AppColors.secondary.withOpacity(0.8);

    final Color circleColor = isCompleted
        ? activeGreen
        : isActive
            ? pendingPurple
            : AppColors.secondary.withOpacity(0.75);

    final Color labelColor = isCompleted
        ? activeGreen
        : isActive
            ? pendingPurple
            : AppColors.textSecondary.withOpacity(0.75);

    return Column(
      children: [
        SizedBox(
          height: 34,
          child: Row(
            children: [
              if (index != 0)
                Expanded(
                  child: Container(
                    height: 3,
                    color: index < currentStep ? activeGreen : inactiveLine,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 3,
                    color:
                        index < currentStep - 1 ? activeGreen : inactiveLine,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}