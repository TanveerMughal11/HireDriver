import 'package:flutter/material.dart';
import 'package:hire_driver/auth/Signup/otp.dart';
import 'package:hire_driver/service/signup.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/utils/textstyle.dart';
import 'package:hire_driver/view/intro/intro1.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedGender = "Male";
  bool showPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signupUser() async {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await ApiService.signup(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      gender: selectedGender,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Signup failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TopTag(
                    text: "Create Account",
                    bgColor: AppColors.secondary,
                    textColor: AppColors.primary,
                  ),
                ],
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _field("Full Name", nameController),
                    const SizedBox(height: 12),
                    _field("Email", emailController),
                    const SizedBox(height: 12),
                    _field("Phone Number", phoneController),
                    const SizedBox(height: 12),
                  _field(
  "Password",
  passwordController,
  obscure: !showPassword,
  isPassword: true,
),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _genderBtn("Male"),
                        const SizedBox(width: 8),
                        _genderBtn("Female"),
                        const SizedBox(width: 8),
                        _genderBtn("Other"),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              isLoading
                  ? Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : PrimaryButton(
                      text: "Sign Up",
                      startColor: AppColors.primary,
                      endColor: AppColors.primary.withOpacity(0.8),
                      onTap: signupUser,
                    ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTextStyles.introDescription,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
                      style: AppTextStyles.chipText(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _field(
  String hint,
  TextEditingController controller, {
  bool obscure = false,
  bool isPassword = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: AppTextStyles.introDescription.copyWith(
      color: AppColors.textPrimary,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.introDescription.copyWith(
        color: AppColors.textSecondary.withOpacity(0.5),
      ),
      filled: true,
      fillColor: AppColors.light.withOpacity(0.5),

      /// ❌ REMOVE THIS
      // prefixIcon: ...

      /// ✅ ADD THIS (RIGHT SIDE)
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primary,
              ),
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
            )
          : null,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

  Widget _genderBtn(String text) {
    bool isSelected = selectedGender == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = text),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.light,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.secondary.withOpacity(0.6),
              width: isSelected ? 2 : 1.3,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.chipText(
                isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}