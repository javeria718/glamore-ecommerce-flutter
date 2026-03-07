import 'package:ecom_app/Singleton/singleton.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/widgets/custom_textfornfield.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final local = UserSingleton().userModel;
    if (local != null) {
      _nameController.text = local.name;
      _emailController.text = local.email;
      _phoneController.text = local.phoneNumber;
    }
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(authRepositoryProvider).currentProfile();
      if (!mounted || profile == null) return;
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _phoneController.text = profile.phoneNumber;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _showMessage('Please fill all fields', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final updated = await ref.read(authActionControllerProvider.notifier).run(
            (repo) => repo.updateProfile(name: name, email: email, phoneNumber: phone),
          );
      UserSingleton().userModel = updated;
      if (!mounted) return;
      _showMessage('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Update failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(context: context, title: 'Edit Profile'),
      body: frostyLightBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: FrostedGlassCard(
                maxWidth: 520,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage('assets/images/panda.jpg'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 14),
                    CustomTextFormField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 14),
                    CustomTextFormField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 46),
                        ),
                        onPressed: _loading ? null : _saveProfile,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Changes'),
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

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
