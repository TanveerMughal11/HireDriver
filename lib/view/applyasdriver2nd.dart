import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyAsDriver extends StatefulWidget {
  const ApplyAsDriver({super.key});

  @override
  State<ApplyAsDriver> createState() => _ApplyAsDriverState();
}

class _ApplyAsDriverState extends State<ApplyAsDriver> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? profilePictureFile;
  XFile? cnicFrontFile;
  XFile? cnicBackFile;
  XFile? licenseFrontFile;
  XFile? licenseBackFile;

  String? fullNameError;
  String? ageError;
  String? phoneError;
  String? emailError;

  bool isLoadingStatus = true;
  bool isSubmitting = false;

  Map<String, dynamic>? statusData;

  bool get profileCaptured => profilePictureFile != null;
  bool get cnicFrontCaptured => cnicFrontFile != null;
  bool get cnicBackCaptured => cnicBackFile != null;
  bool get licenseFrontCaptured => licenseFrontFile != null;
  bool get licenseBackCaptured => licenseBackFile != null;

  bool get showStatusOnly {
    return statusData?['alreadyApplied'] == true ||
        statusData?['canApply'] == false;
  }

  @override
  void initState() {
    super.initState();
    _loadDriverStatus();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _loadDriverStatus() async {
    try {
      setState(() => isLoadingStatus = true);

      final res = await DriverVerificationApiService.getMyDriverVerification();
      statusData = res;

      final prefill = res['prefill'];
      final personalInfo = res['application']?['personalInfo'];

      fullNameController.text =
          personalInfo?['fullName'] ?? prefill?['fullName'] ?? '';

      phoneController.text =
          personalInfo?['phoneNumber'] ?? prefill?['phoneNumber'] ?? '';

      emailController.text = personalInfo?['email'] ?? prefill?['email'] ?? '';

      final age = personalInfo?['age'];

      if (age != null) {
        ageController.text = age.toString();
      }
    } catch (e) {
      debugPrint('Driver status error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingStatus = false);
      }
    }
  }

  Future<void> _captureProfilePicture() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() => profilePictureFile = picked);

      _showSnack('Profile picture captured');
    } catch (e) {
      _showSnack('Camera not available. Please test on real phone.');
    }
  }

  Future<void> _pickDocument(String type) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      if (type == 'cnicFront') cnicFrontFile = picked;
      if (type == 'cnicBack') cnicBackFile = picked;
      if (type == 'licenseFront') licenseFrontFile = picked;
      if (type == 'licenseBack') licenseBackFile = picked;
    });

    _showSnack('$type added');
  }

  Future<void> _submitDriverVerification() async {
    setState(() {
      fullNameError = null;
      ageError = null;
      phoneError = null;
      emailError = null;
    });

    bool hasError = false;

    final fullName = fullNameController.text.trim();
    final ageText = ageController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty) {
      fullNameError = 'Enter full name';
      hasError = true;
    } else if (fullName.length < 3) {
      fullNameError = 'Name must be at least 3 characters';
      hasError = true;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(fullName)) {
      fullNameError = 'Name cannot contain numbers or symbols';
      hasError = true;
    }

    final age = int.tryParse(ageText);

    if (ageText.isEmpty) {
      ageError = 'Enter age';
      hasError = true;
    } else if (age == null || age < 18 || age > 80) {
      ageError = 'Age must be between 18 and 80';
      hasError = true;
    }

    if (phone.isEmpty) {
      phoneError = 'Enter phone number';
      hasError = true;
    } else if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
      phoneError = 'Phone must start with 03 and be 11 digits';
      hasError = true;
    }

    if (email.isEmpty) {
      emailError = 'Enter email';
      hasError = true;
    } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      emailError = 'Enter valid email address';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    if (showStatusOnly) {
      _showSnack('Application already submitted');
      return;
    }

    if (profilePictureFile == null) {
      _showSnack('Capture live profile picture');
      return;
    }

    if (cnicFrontFile == null ||
        cnicBackFile == null ||
        licenseFrontFile == null ||
        licenseBackFile == null) {
      _showSnack('Upload all required documents');
      return;
    }

    try {
      setState(() => isSubmitting = true);

      final res = await DriverVerificationApiService.submitDriverVerification(
        fullName: fullName,
        age: ageText,
        phoneNumber: phone,
        email: email,
        profilePicture: profilePictureFile!,
        cnicFront: cnicFrontFile!,
        cnicBack: cnicBackFile!,
        licenseFront: licenseFrontFile!,
        licenseBack: licenseBackFile!,
      );

      if (res['success'] == true) {
        await _loadDriverStatus();

        _showSnack(
          res['message'] ?? 'Driver verification submitted successfully',
        );
      } else {
        _showSnack(res['message'] ?? 'Submit failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        await _loadDriverStatus();

        final backendMessage =
            e.response?.data?['message']?.toString() ??
            'Application already submitted';

        _showSnack(backendMessage);
      } else {
        _showSnack(
          e.response?.data?['message']?.toString() ??
              e.message ??
              'Something went wrong',
        );
      }
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoadingStatus
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      child: showStatusOnly
                          ? _buildStatusScreen()
                          : Column(
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
                                  errorText: fullNameError,
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
                                  errorText: ageError,
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
                                  errorText: phoneError,
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
                                  errorText: emailError,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 24),

                                _sectionTitle('Required Documents'),

                                const SizedBox(height: 12),

                                _uploadTile(
                                  title: 'CNIC Front',
                                  uploaded: cnicFrontCaptured,
                                  onTap: () => _pickDocument('cnicFront'),
                                ),

                                const SizedBox(height: 12),

                                _uploadTile(
                                  title: 'CNIC Back',
                                  uploaded: cnicBackCaptured,
                                  onTap: () => _pickDocument('cnicBack'),
                                ),

                                const SizedBox(height: 12),

                                _uploadTile(
                                  title: 'License Front',
                                  uploaded: licenseFrontCaptured,
                                  onTap: () => _pickDocument('licenseFront'),
                                ),

                                const SizedBox(height: 12),

                                _uploadTile(
                                  title: 'License Back',
                                  uploaded: licenseBackCaptured,
                                  onTap: () => _pickDocument('licenseBack'),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (!showStatusOnly) _buildBottomButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusScreen() {
    final application = statusData?['application'];
    final status = statusData?['applicationStatus']?.toString() ?? 'pending';

    final personal = application?['personalInfo'];
    final profilePicture = application?['profilePicture'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBanner(),
        const SizedBox(height: 22),

        Center(
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.secondary.withOpacity(0.4),
            backgroundImage: profilePicture != null
                ? NetworkImage(profilePicture)
                : null,
            child: profilePicture == null
                ? const Icon(Icons.person, size: 42, color: AppColors.primary)
                : null,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Driver Application Status',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              _statusBadge(status),

              const SizedBox(height: 18),

              _infoRow('Name', personal?['fullName']?.toString() ?? '-'),

              _infoRow('Age', personal?['age']?.toString() ?? '-'),

              _infoRow('Phone', personal?['phoneNumber']?.toString() ?? '-'),

              _infoRow('Email', personal?['email']?.toString() ?? '-'),

              const SizedBox(height: 12),

              _statusTile('Application Submitted', true),
              _statusTile('Waiting for Admin Review', status == 'pending'),
              _statusTile('Approved', status == 'approved'),
              _statusTile('Rejected', status == 'rejected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    String text = 'Pending';

    if (status == 'approved') {
      color = const Color(0xFF16A34A);
      text = 'Approved';
    } else if (status == 'rejected') {
      color = Colors.red;
      text = 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _statusTile(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF16A34A) : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
          Icon(Icons.badge_rounded, color: Colors.amber, size: 34),
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
            onTap: _captureProfilePicture,
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
    String? errorText,
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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.55),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
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
                color: uploaded ? const Color(0xFFDCFCE7) : AppColors.light,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                uploaded
                    ? Icons.check_circle_rounded
                    : Icons.photo_library_rounded,
                color: uploaded ? const Color(0xFF16A34A) : AppColors.primary,
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
              uploaded ? 'Added ✓' : 'Upload →',
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
            onPressed: isSubmitting ? null : _submitDriverVerification,
            child: isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
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

class DriverVerificationApiService {
  static const String baseUrl = 'https://hiredrive-fal0.onrender.com';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    return token;
  }

  static Future<Map<String, dynamic>> getMyDriverVerification() async {
    final token = await _getToken();

    final dio = Dio();

    final response = await dio.get(
      '$baseUrl/api/driver-verification/me',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> submitDriverVerification({
    required String fullName,
    required String age,
    required String phoneNumber,
    required String email,
    required XFile profilePicture,
    required XFile cnicFront,
    required XFile cnicBack,
    required XFile licenseFront,
    required XFile licenseBack,
  }) async {
    final token = await _getToken();

    final dio = Dio();

    final formData = FormData.fromMap({
      'fullName': fullName,
      'age': age,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePicture': await MultipartFile.fromFile(profilePicture.path),
      'cnicFront': await MultipartFile.fromFile(cnicFront.path),
      'cnicBack': await MultipartFile.fromFile(cnicBack.path),
      'licenseFront': await MultipartFile.fromFile(licenseFront.path),
      'licenseBack': await MultipartFile.fromFile(licenseBack.path),
    });

    final response = await dio.post(
      '$baseUrl/api/driver-verification/submit',
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return Map<String, dynamic>.from(response.data);
  }
}

