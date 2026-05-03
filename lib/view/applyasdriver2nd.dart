import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hire_driver/utils/app_colors.dart';

class ApplyAsDriver extends StatefulWidget {
  const ApplyAsDriver({super.key});

  @override
  State<ApplyAsDriver> createState() =>
      _ApplyAsDriverState();
}

class _ApplyAsDriverState extends State<ApplyAsDriver> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool profileCaptured = false;
  bool cnicFrontCaptured = false;
  bool cnicBackCaptured = false;
  bool licenseFrontCaptured = false;
  bool licenseBackCaptured = false;

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _dummyCapture(String type) {
    setState(() {
      if (type == 'profile') profileCaptured = true;
      if (type == 'cnicFront') cnicFrontCaptured = true;
      if (type == 'cnicBack') cnicBackCaptured = true;
      if (type == 'licenseFront') licenseFrontCaptured = true;
      if (type == 'licenseBack') licenseBackCaptured = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type added')),
    );
  }

  void _submitDummy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('driver form submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBanner(),
                    const SizedBox(height: 22),
                    _buildProfilePhoto(),
                    const SizedBox(height: 22),

                    _sectionTitle('Personal Information'),
                    const SizedBox(height: 12),

                    _textField(
                      label: 'FULL NAME',
                      hint: 'e.g. Muhammad Ali',
                      controller: fullNameController,
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      label: 'AGE',
                      hint: 'e.g. 25',
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      label: 'PHONE NUMBER',
                      hint: 'e.g. 03001234567',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      label: 'EMAIL',
                      hint: 'e.g. driver@gmail.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Required Documents'),
                    const SizedBox(height: 12),

                    _uploadTile(
                      title: 'CNIC Front',
                      uploaded: cnicFrontCaptured,
                      onTap: () => _dummyCapture('cnicFront'),
                    ),
                    const SizedBox(height: 12),

                    _uploadTile(
                      title: 'CNIC Back',
                      uploaded: cnicBackCaptured,
                      onTap: () => _dummyCapture('cnicBack'),
                    ),
                    const SizedBox(height: 12),

                    _uploadTile(
                      title: 'License Front',
                      uploaded: licenseFrontCaptured,
                      onTap: () => _dummyCapture('licenseFront'),
                    ),
                    const SizedBox(height: 12),

                    _uploadTile(
                      title: 'License Back',
                      uploaded: licenseBackCaptured,
                      onTap: () => _dummyCapture('licenseBack'),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
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
            'Driver Form',
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
      ),
      child: const Row(
        children: [
          Icon(
            Icons.badge_rounded,
            color: Colors.amber,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'driver verification form',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _dummyCapture('profile'),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: profileCaptured
                  ? AppColors.primary.withOpacity(0.18)
                  : AppColors.secondary.withOpacity(0.4),
              child: Icon(
                profileCaptured
                    ? Icons.check_circle_rounded
                    : Icons.camera_alt_rounded,
                size: 38,
                color: profileCaptured
                    ? const Color(0xFF16A34A)
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Live Time Profile Picture',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profileCaptured ? 'captured ✓' : 'Tap to add photo',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.8),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF16A34A).withOpacity(0.7)
                : AppColors.secondary.withOpacity(0.7),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: uploaded
                    ? const Color(0xFFDCFCE7)
                    : AppColors.light,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                uploaded
                    ? Icons.check_circle_rounded
                    : Icons.camera_alt_rounded,
                color: uploaded
                    ? const Color(0xFF16A34A)
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              uploaded ? 'Added ✓' : 'Add →',
              style: TextStyle(
                color: uploaded
                    ? const Color(0xFF16A34A)
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
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
            onPressed: _submitDummy,
            child: const Text(
              'Submit Form',
              style: TextStyle(
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
}