import 'package:ecom_app/auth/forgotpass/reset_pass.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  late final FocusNode _emailFocusNode;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _email.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      prefixIcon: Icon(icon, color: Colors.black54),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.black87,
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<List<String>> _getSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('login_emails') ?? <String>[];
  }

  Future<void> _submit() async {
    final input = _email.text.trim();

    if (input.isEmpty) {
      _showMsg('Please enter your email address.', error: true);
      return;
    }
    if (!_isValidEmail(input)) {
      _showMsg('Please enter a valid email address.', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(input);
      if (!mounted) return;
      _showMsg('Reset code sent! Please check your email.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(prefilledEmail: input)),
      );
    } on AuthException catch (e) {
      _showMsg(e.message, error: true);
    } catch (e) {
      _showMsg('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: frostyLightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: FrostedGlassCard(
                maxWidth: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset, size: 64, color: Colors.teal),
                    const SizedBox(height: 10),
                    const Text(
                      'Reset Your Password',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your email and we will send a recovery code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.70)),
                    ),
                    const SizedBox(height: 22),
                    FutureBuilder<List<String>>(
                      future: _getSavedEmails(),
                      builder: (context, snapshot) {
                        final emails = snapshot.data ?? <String>[];
                        return RawAutocomplete<String>(
                          textEditingController: _email,
                          focusNode: _emailFocusNode,
                          optionsBuilder: (TextEditingValue value) {
                            if (emails.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            final query = value.text.trim().toLowerCase();
                            if (query.isEmpty) return emails;
                            return emails
                                .where((e) => e.toLowerCase().contains(query));
                          },
                          fieldViewBuilder:
                              (context, textController, focusNode, _) {
                            return TextField(
                              controller: textController,
                              focusNode: focusNode,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _fieldDecoration(
                                label: 'Email Address',
                                icon: Icons.alternate_email,
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
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
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Send Reset Code'),
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
