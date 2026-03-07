import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:ecom_app/widgets/custom_textfornfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _verifyingOld = false;
  bool _updating = false;
  bool _oldPasswordVerified = false;

  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;
  bool _hasMinLength = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPassword(String password) {
    setState(() {
      _hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      _hasLower = RegExp(r'[a-z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
      _hasMinLength = password.length >= 8;
    });
  }

  Future<void> _verifyOldPassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    if (oldPassword.isEmpty) {
      _show('Please enter your current password', true);
      return;
    }

    final client = ref.read(supabaseClientProvider);
    final email = client.auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      _show('Current account email not found. Please sign in again.', true);
      return;
    }

    setState(() => _verifyingOld = true);
    try {
      await client.auth.signInWithPassword(email: email, password: oldPassword);
      if (!mounted) return;
      setState(() => _oldPasswordVerified = true);
      _show('Current password verified', false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _oldPasswordVerified = false);
      _show(e.message, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _oldPasswordVerified = false);
      _show('Unable to verify current password: $e', true);
    } finally {
      if (mounted) {
        setState(() => _verifyingOld = false);
      }
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      _show('Please enter your current password', true);
      return;
    }
    if (!_oldPasswordVerified) {
      _show('Please verify your current password first', true);
      return;
    }
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _show('Please fill new password and confirm password', true);
      return;
    }
    if (!_hasUpper || !_hasLower || !_hasNumber || !_hasSpecial || !_hasMinLength) {
      _show(
        'Password must include uppercase, lowercase, number, special character, and 8+ length.',
        true,
      );
      return;
    }
    if (newPassword != confirmPassword) {
      _show('Passwords do not match', true);
      return;
    }
    if (newPassword == oldPassword) {
      _show('New password must be different from current password', true);
      return;
    }

    setState(() => _updating = true);
    try {
      await ref.read(supabaseClientProvider).auth.updateUser(
            UserAttributes(password: newPassword),
          );
      if (!mounted) return;
      _show('Password updated successfully', false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _show('Unable to update password: $e', true);
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(context: context, title: 'Change Password'),
      body: frostyLightBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: FrostedGlassCard(
                maxWidth: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Password must have uppercase, lowercase, number, special character, and at least 8 characters.',
                      style: TextStyle(color: Colors.black.withValues(alpha: 0.62)),
                    ),
                    const SizedBox(height: 14),
                    CustomTextFormField(
                      label: 'Current Password',
                      icon: Icons.lock_clock_outlined,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _oldPasswordController,
                      obscureText: !_showOld,
                      onChanged: (_) {
                        if (_oldPasswordVerified) {
                          setState(() => _oldPasswordVerified = false);
                        }
                      },
                      suffixIcon: IconButton(
                        icon: Icon(_showOld ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _showOld = !_showOld),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _oldPasswordVerified ? Colors.green : Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: _verifyingOld || _updating ? null : _verifyOldPassword,
                      child: _verifyingOld
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_oldPasswordVerified ? 'Verified' : 'Verify Current Password'),
                    ),
                    const SizedBox(height: 14),
                    AbsorbPointer(
                      absorbing: !_oldPasswordVerified || _verifyingOld || _updating,
                      child: Opacity(
                        opacity: _oldPasswordVerified ? 1 : 0.6,
                        child: CustomTextFormField(
                          label: 'New Password',
                          icon: Icons.lock_outline,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _newPasswordController,
                          obscureText: !_showNew,
                          onChanged: _checkPassword,
                          suffixIcon: IconButton(
                            icon: Icon(_showNew ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _showNew = !_showNew),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AbsorbPointer(
                      absorbing: !_oldPasswordVerified || _verifyingOld || _updating,
                      child: Opacity(
                        opacity: _oldPasswordVerified ? 1 : 0.6,
                        child: CustomTextFormField(
                          label: 'Confirm Password',
                          icon: Icons.lock_reset_outlined,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _showConfirm = !_showConfirm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 46),
                      ),
                      onPressed: _updating || _verifyingOld || !_oldPasswordVerified
                          ? null
                          : _updatePassword,
                      child: _updating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes'),
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

  void _show(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
