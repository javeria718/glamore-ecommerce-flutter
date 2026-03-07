import 'package:ecom_app/Singleton/singleton.dart';
import 'package:ecom_app/auth/forgotpass/screen1.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/auth/signup.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/view/home.dart';
import 'package:ecom_app/widgets/custom_textfornfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const _emailsKey = 'login_emails';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  List<String> _savedEmails = const <String>[];
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmails();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList(_emailsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _savedEmails = emails);
  }

  Future<void> _saveEmailSuggestion(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_emailsKey) ?? <String>[];
    final normalized = email.trim().toLowerCase();
    final updated = <String>[
      normalized,
      ...current.where((e) => e.toLowerCase() != normalized),
    ];
    final limited = updated.take(6).toList();
    await prefs.setStringList(_emailsKey, limited);
    if (!mounted) return;
    setState(() => _savedEmails = limited);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> login(String email, String password) async {
    try {
      setState(() => isLoading = true);

      final userModel =
          await ref.read(authActionControllerProvider.notifier).run(
                (repo) => repo.signIn(email: email, password: password),
              );

      UserSingleton().userModel = userModel;
      await _saveEmailSuggestion(email);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showError('Login failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void validateAndLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError('Please fill all fields.');
    } else if (!email.contains('@')) {
      showError('Enter a valid email.');
    } else if (password.length < 8) {
      showError('Password must be at least 8 characters.');
    } else {
      login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final brandSize = (screenWidth * 0.06).clamp(30.0, 40.0);
    final headingSize = (screenWidth * 0.038).clamp(20.0, 24.0);
    final bodySize = (screenWidth * 0.022).clamp(12.0, 14.0);
    final cardPadding = (screenWidth * 0.045).clamp(20.0, 30.0);
    final buttonHeight = (screenWidth * 0.08).clamp(44.0, 50.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: frostyLightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: FrostedGlassCard(
                padding: EdgeInsets.all(cardPadding),
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
                      child: Text(
                        'Glamoré',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: brandSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: headingSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: Colors.black.withValues(alpha: 0.60),
                      ),
                    ),
                    const SizedBox(height: 22),
                    RawAutocomplete<String>(
                      textEditingController: emailController,
                      focusNode: _emailFocusNode,
                      optionsBuilder: (TextEditingValue value) {
                        if (_savedEmails.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        final query = value.text.trim().toLowerCase();
                        if (query.isEmpty) return _savedEmails;
                        return _savedEmails
                            .where((e) => e.toLowerCase().contains(query));
                      },
                      fieldViewBuilder: (context, controller, focusNode, _) {
                        return CustomTextFormField(
                          controller: controller,
                          keyboardType: TextInputType.emailAddress,
                          label: 'Email',
                          icon: Icons.email_outlined,
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              constraints: const BoxConstraints(
                                  maxHeight: 220, maxWidth: 420),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.98),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 6)),
                                ],
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,
                                    title: Text(option,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !showPassword,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: buttonHeight,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isLoading ? null : validateAndLogin,
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.70),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
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
