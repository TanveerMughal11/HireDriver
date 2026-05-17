import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/utils/textstyle.dart';
import 'package:hire_driver/view/intro/intro1.dart';
import 'package:hire_driver/view/profile/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String selectedGender = "Male";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final user = jsonDecode(userString);

      setState(() {
        fullNameController.text = user['name'] ?? "";
        phoneController.text = user['phone'] ?? "";
        email = user['email'] ?? "";
        selectedGender = user['gender'] ?? "Male";
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void saveChanges() {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid phone number")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileOtpScreen(
          email: email.isEmpty ? "your email" : email,
          fullName: fullName,
          phone: phone,
          password: password,
          gender: selectedGender,
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.light,

 body: SafeArea(
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondary),
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
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1(context),
                ),
              ),
            ),
          ],
        ),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update your profile information",
                style: AppTextStyles.introDescription,
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Column(
                  children: [
                    _field(
                      hint: "Full Name",
                      controller: fullNameController,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      hint: "Phone Number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      hint: "Password",
                      controller: passwordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      hint: "Confirm Password",
                      controller: confirmPasswordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedGender,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.softBg(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(value: "Female", child: Text("Female")),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedGender = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: "Save Changes",
                startColor: AppColors.primary,
                endColor: AppColors.primary.withOpacity(0.8),
                onTap: saveChanges,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ],
  ),
),
  );
}
  

  Widget _field({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class EditProfileOtpScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String phone;
  final String password;
  final String gender;

  const EditProfileOtpScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.gender,
  });

  @override
  State<EditProfileOtpScreen> createState() => _EditProfileOtpScreenState();
}

class _EditProfileOtpScreenState extends State<EditProfileOtpScreen> {
  final TextEditingController otpController = TextEditingController();

  final String correctOtp = "123456";

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    if (otp != correctOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Use 123456 for demo")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final oldUserString = prefs.getString('userData');

    Map<String, dynamic> user = {};

    if (oldUserString != null) {
      user = jsonDecode(oldUserString);
    }

    user['name'] = widget.fullName;
    user['phone'] = widget.phone;
    user['gender'] = widget.gender;

    await prefs.setString('userData', jsonEncode(user));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              TopTag(
                text: "OTP Verification",
                bgColor: AppColors.secondary,
                textColor: AppColors.primary,
              ),
              const SizedBox(height: 25),
              Text(
                "Enter OTP sent to your email",
                style: AppTextStyles.introTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: AppTextStyles.introDescription,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Enter OTP",
                    filled: true,
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              PrimaryButton(
                text: "Verify",
                startColor: AppColors.primary,
                endColor: AppColors.primary.withOpacity(0.8),
                onTap: verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}