import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/auth/forgotpass/password_updated.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.prefilledEmail});

  final String? prefilledEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController emailCtrl;
  late final TextEditingController codeCtrl;
  late final TextEditingController pass1Ctrl;
  late final TextEditingController pass2Ctrl;

  bool loading = false;
  bool showPass1 = false;
  bool showPass2 = false;

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: widget.prefilledEmail ?? '');
    codeCtrl = TextEditingController();
    pass1Ctrl = TextEditingController();
    pass2Ctrl = TextEditingController();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    codeCtrl.dispose();
    pass1Ctrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 1.8),
      ),
    );
  }

  void _showMsg(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.black87,
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String p) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(p);
    final hasNumber = RegExp(r'\d').hasMatch(p);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(p);
    return p.length >= 8 && hasLetter && hasNumber && hasSymbol;
  }

  ({String value, bool isTokenHash}) _parseRecoveryInput(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return (value: '', isTokenHash: false);

    Uri? uri;
    try {
      uri = Uri.parse(cleaned);
    } catch (_) {
      uri = null;
    }

    if (uri == null || !uri.hasScheme) {
      return (value: cleaned.replaceAll(' ', ''), isTokenHash: false);
    }

    final query = uri.queryParameters;
    final fragmentQuery = uri.fragment.contains('?')
        ? Uri.splitQueryString(uri.fragment.split('?').last)
        : <String, String>{};

    String? pickFrom(Map<String, String> src, List<String> keys) {
      for (final key in keys) {
        final value = src[key];
        if (value != null && value.trim().isNotEmpty) return value.trim();
      }
      return null;
    }

    final tokenHash = pickFrom(query, const ['token_hash']) ??
        pickFrom(fragmentQuery, const ['token_hash']);
    if (tokenHash != null) {
      return (value: tokenHash, isTokenHash: true);
    }

    final token = pickFrom(query, const ['code', 'token']) ??
        pickFrom(fragmentQuery, const ['code', 'token']);
    if (token != null) {
      return (value: token, isTokenHash: false);
    }

    return (value: cleaned.replaceAll(' ', ''), isTokenHash: false);
  }

  Future<void> _reset() async {
    final email = emailCtrl.text.trim();
    final parsed = _parseRecoveryInput(codeCtrl.text);
    final code = parsed.value;
    final p1 = pass1Ctrl.text.trim();
    final p2 = pass2Ctrl.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      _showMsg('Please enter a valid email.', error: true);
      return;
    }
    if (code.isEmpty) {
      _showMsg('Please enter the reset code from email.', error: true);
      return;
    }
    if (p1 != p2) {
      _showMsg('Passwords do not match.', error: true);
      return;
    }
    if (!_isStrongPassword(p1)) {
      _showMsg('Password must be at least 8 chars with letters, numbers, symbols.', error: true);
      return;
    }

    setState(() => loading = true);
    try {
      final supabase = Supabase.instance.client;
      if (parsed.isTokenHash) {
        await supabase.auth.verifyOTP(
          tokenHash: code,
          type: OtpType.recovery,
        );
      } else {
        await supabase.auth.verifyOTP(
          email: email,
          token: code,
          type: OtpType.recovery,
        );
      }

      await supabase.auth.updateUser(UserAttributes(password: p1));
      await supabase.auth.signOut();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PasswordUpdatedScreen()),
      );
    } on AuthException catch (e) {
      _showMsg(e.message, error: true);
    } catch (e) {
      _showMsg('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(
        context: context,
        title: 'Reset Password',
        actions: const [],
      ),
      body: frostyLightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: FrostedGlassCard(
                maxWidth: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email, reset code, and new password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.70)),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(label: 'Email Address', icon: Icons.alternate_email),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: codeCtrl,
                      keyboardType: TextInputType.text,
                      decoration: _fieldDecoration(label: 'Reset Code', icon: Icons.verified),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: pass1Ctrl,
                      obscureText: !showPass1,
                      decoration: _fieldDecoration(
                        label: 'New Password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () => setState(() => showPass1 = !showPass1),
                          icon: Icon(showPass1 ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: pass2Ctrl,
                      obscureText: !showPass2,
                      decoration: _fieldDecoration(
                        label: 'Confirm Password',
                        icon: Icons.lock,
                        suffix: IconButton(
                          onPressed: () => setState(() => showPass2 = !showPass2),
                          icon: Icon(showPass2 ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: loading ? null : _reset,
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Update Password'),
                      ),
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
