import 'package:ecom_app/Singleton/singleton.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/auth/login.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/widgets/custom_textfornfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildPasswordRule(String text, bool isValid) {
  final okColor = Colors.green.shade700;
  final idleColor = Colors.black.withValues(alpha: 0.55);

  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? okColor : idleColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isValid ? okColor : idleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void checkPassword(String password) {
    setState(() {
      hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      hasLower = RegExp(r'[a-z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
      hasMinLength = password.length >= 8;
    });
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String mobile,
  ) async {
    try {
      setState(() => isLoading = true);

      final userModel =
          await ref.read(authActionControllerProvider.notifier).run(
                (repo) => repo.signUp(
                  email: email,
                  password: password,
                  fullName: fullName,
                  phoneNumber: mobile,
                ),
              );

      UserSingleton().userModel = userModel;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup Successful! Redirecting to Login...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      showError('Signup failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void validateAndSignUp() {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (fullName.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showError('Please fill all fields.');
    } else if (!email.contains('@')) {
      showError('Please enter a valid email address.');
    } else if (!emailRegex.hasMatch(email)) {
      showError('Please enter a valid email address.');
    } else if (mobile.length < 10) {
      showError('Enter a valid mobile number.');
    } else if (!hasUpper ||
        !hasLower ||
        !hasNumber ||
        !hasSpecial ||
        !hasMinLength) {
      showError(
          'Password must include uppercase, lowercase, number, special character, and 8+ length.');
    } else if (password != confirmPassword) {
      showError('Passwords do not match.');
    } else {
      signUp(email, password, fullName, mobile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      // appBar: frostedTealAppBar(
      //   context: context,
      //   title: 'Sign Up',
      //   actions: const [],
      // ),
      body: frostyLightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: FrostedGlassCard(
                maxWidth: 560,
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF006D6F), // Deep Teal
                          Color(0xFF00A8A8), // Bright Teal
                          Color(0xFF5FE3E3), // Soft Teal Highlight
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'Glamoré',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    // const Text(
                    //   'Glamore',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 30,
                    //     fontWeight: FontWeight.w800,
                    //     color: Colors.black87,
                    //     letterSpacing: 1,
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.70),
                      ),
                    ),
                    const SizedBox(height: 26),
                    CustomTextFormField(
                      controller: fullNameController,
                      keyboardType: TextInputType.name,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      label: 'Mobile Number',
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !showPassword,
                      onChanged: checkPassword,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildPasswordRule('Uppercase letter', hasUpper),
                        buildPasswordRule('Lowercase letter', hasLower),
                        buildPasswordRule('Number', hasNumber),
                        buildPasswordRule('Special character', hasSpecial),
                        buildPasswordRule('8 characters or more', hasMinLength),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !showConfirmPassword,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => showConfirmPassword = !showConfirmPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isLoading ? null : validateAndSignUp,
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.70),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.teal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
