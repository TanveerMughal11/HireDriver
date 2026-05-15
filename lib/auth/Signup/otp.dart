import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hire_driver/view/intro/intro_survey.dart';
import 'package:hire_driver/service/otp.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/utils/textstyle.dart';
import 'package:hire_driver/view/intro/intro1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> verifyOtpCode() async {
    final otp = controller.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter OTP"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await OtpApiService.verifyOtp(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

if (result['success'] == true) {
  final data = result['data'];
  final token = data['token'];
  final user = data['user'];

  if (token == null || token.toString().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Token not found")),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setString('userData', jsonEncode(user));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(data['message'] ?? 'OTP verified'),
    ),
  );

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const RoleSelectionScreen(),
    ),
    (route) => false,
  );
}
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
              TopTag(
                text: "OTP Verification",
                bgColor: AppColors.secondary,
                textColor: AppColors.primary,
              ),
              const SizedBox(height: 25),
              Text(
                "Code sent to ${widget.email}",
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
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
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
              const SizedBox(height: 50),
              isLoading
                  ? Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : PrimaryButton(
                      text: "Verify",
                      startColor: AppColors.primary,
                      endColor: AppColors.primary.withOpacity(0.8),
                      onTap: verifyOtpCode,
                    ),
              const SizedBox(height: 20),
              SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
        ),
      );
    },
    child: const Text(
      "Resend OTP",
      style: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
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