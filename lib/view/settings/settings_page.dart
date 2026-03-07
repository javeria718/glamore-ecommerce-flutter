import 'package:ecom_app/Singleton/singleton.dart';
import 'package:ecom_app/auth/login.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/view/settings/change_password_page.dart';
import 'package:ecom_app/view/settings/coupons_page.dart';
import 'package:ecom_app/view/settings/edit_profile_page.dart';
import 'package:ecom_app/view/settings/order_history_page.dart';
import 'package:ecom_app/view/settings/shipping_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final bool _darkMode = false;

  Future<void> _logout() async {
    await ref.read(authRepositoryProvider).signOut();
    UserSingleton().clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = UserSingleton().userModel;
    final optionTextColor =
        _darkMode ? const Color(0xFFE7FFFD) : const Color(0xFF1E4441);
    final subTextColor = _darkMode
        ? Colors.white.withValues(alpha: 0.70)
        : Colors.black.withValues(alpha: 0.58);
    final cardColor = _darkMode
        ? const Color(0xFF145955).withValues(alpha: 0.64)
        : Colors.white.withValues(alpha: 0.70);

    return frostyLightBackground(
      child: SafeArea(
        top: false,
        child: FutureBuilder(
          future: ref.read(authRepositoryProvider).currentProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data ?? local;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundImage:
                              AssetImage('assets/images/panda.jpg'),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (profile?.name.isNotEmpty ?? false)
                                    ? profile!.name
                                    : 'Guest User',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: optionTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile?.email ?? 'No email',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 4),
                  _SettingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    darkMode: _darkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order History',
                    darkMode: _darkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrderHistoryPage()),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Shipping Details',
                    darkMode: _darkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ShippingDetailsPage()),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.discount_outlined,
                    title: 'All Coupons',
                    darkMode: _darkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CouponsPage()),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    darkMode: _darkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage()),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    darkMode: _darkMode,
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Log out'),
                                content: const Text(
                                    'Do you want to log out from this account?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                        backgroundColor: Colors.teal),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;

                      if (!shouldLogout) return;
                      await _logout();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.darkMode,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool darkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = darkMode
        ? const Color(0xFF1A6B66).withValues(alpha: 0.66)
        : Colors.white.withValues(alpha: 0.70);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: darkMode ? Colors.white : const Color(0xFF0B6E69)),
        title: Text(
          title,
          style: TextStyle(
            color: darkMode ? Colors.white : const Color(0xFF1D4542),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color:
              darkMode ? Colors.white.withValues(alpha: 0.90) : Colors.black45,
        ),
      ),
    );
  }
}
