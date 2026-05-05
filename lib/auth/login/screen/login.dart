import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hire_driver/auth/Signup/signup.dart';
import 'package:hire_driver/auth/login/services/login.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/utils/textstyle.dart';
import 'package:hire_driver/view/home.dart';
import 'package:hire_driver/view/intro/intro1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final userEmail = email.text.trim();
    final userPass = pass.text.trim();

    if (userEmail.isEmpty || userPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await LoginApiService.login(
      email: userEmail,
      password: userPass,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      final data = result['data'];
      final token = data['token'];
      final user = data['user'];
      print("LOGIN TOKEN: $token");

      if (token == null || token.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Token not found in login response"),
          ),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);
      await prefs.setString('userData', jsonEncode(user));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Login successful'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login failed'),
        ),
      );
    }
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordEmailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TopTag(
                text: "Welcome Back",
                bgColor: AppColors.secondary,
                textColor: AppColors.primary,
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/logo.jpeg"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Hiredrive",
                      style: AppTextStyles.introTitle.copyWith(
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _field("Email", email),
                    const SizedBox(height: 12),
                    _field(
                      "Password",
                      pass,
                      obscure: !showPassword,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                      text: "Log In",
                      startColor: AppColors.primary,
                      endColor: AppColors.primary.withOpacity(0.8),
                      onTap: loginUser,
                    ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _openForgotPassword,
                  child: Text(
                    "Forgot Password?",
                    style: AppTextStyles.chipText(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have account? ",
                    style: AppTextStyles.introDescription,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: AppTextStyles.chipText(AppColors.primary),
                    ),
                  )
                ],
              ),
              const Spacer(),
              const SizedBox(height: 20),
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
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.light,

      /// ❌ REMOVE prefixIcon
      // prefixIcon: ...

      /// ✅ ADD suffixIcon (RIGHT SIDE)
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
}

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final userEmail = emailController.text.trim();

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await LoginApiService.requestForgotPasswordOtp(
      email: userEmail,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Something went wrong'),
      ),
    );

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: userEmail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: "Forgot Password",
      subtitle: "Enter your email to receive verification code",
      children: [
        _AuthTextField(
          hint: "Email",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
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
            : _AuthButton(
                text: "Send",
                onTap: _sendCode,
              ),
      ],
    );
  }
}

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;
  bool isResending = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter 6 digit code"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await LoginApiService.verifyForgotPasswordOtp(
      email: widget.email,
      otp: code,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Something went wrong'),
      ),
    );

    if (result['success'] == true) {
      final data = result['data'];

      final resetToken =
          data['resetToken'] ?? data['token'] ?? data['data']?['resetToken'];

      if (resetToken == null || resetToken.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reset token not found in response"),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            resetToken: resetToken.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      isResending = true;
    });

    final result = await LoginApiService.resendForgotPasswordOtp(
      email: widget.email,
    );

    if (!mounted) return;

    setState(() {
      isResending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Something went wrong'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: "Verify Code",
      subtitle: "Enter the 6 digit code sent to ${widget.email}",
      children: [
        _AuthTextField(
          hint: "6 Digit Code",
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 20),
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
            : _AuthButton(
                text: "Verify",
                onTap: _verifyCode,
              ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: isResending ? null : _resendCode,
          child: Text(
            isResending ? "Resending..." : "Resend Code",
            style: AppTextStyles.chipText(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _confirmPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter password"),
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await LoginApiService.resetForgotPassword(
      email: widget.email,
      resetToken: widget.resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Something went wrong'),
      ),
    );

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthFlowScaffold(
      title: "Reset Password",
      subtitle: "Create a new password for your account",
      children: [
        _AuthTextField(
          hint: "New Password",
          controller: newPasswordController,
          obscure: !showNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              showNewPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                showNewPassword = !showNewPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _AuthTextField(
          hint: "Confirm Password",
          controller: confirmPasswordController,
          obscure: !showConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              showConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                showConfirmPassword = !showConfirmPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
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
            : _AuthButton(
                text: "Confirm",
                onTap: _confirmPassword,
              ),
      ],
    );
  }
}

class _AuthFlowScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _AuthFlowScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
              const SizedBox(height: 30),
              const SizedBox(height: 35),
              Text(
                title,
                style: AppTextStyles.introTitle.copyWith(
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.introDescription,
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final int? maxLength;
  final Widget? suffixIcon;

  const _AuthTextField({
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        filled: true,
        fillColor: AppColors.light,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AuthButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      startColor: AppColors.primary,
      endColor: AppColors.primary.withOpacity(0.8),
      onTap: onTap,
    );
  }
}