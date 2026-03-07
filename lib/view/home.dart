import 'dart:ui';

import 'package:ecom_app/Singleton/singleton.dart';
import 'package:ecom_app/auth/login.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/features/catalog_core/presentation/catalog_providers.dart';
import 'package:ecom_app/view/settings/settings_page.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:ecom_app/widgets/drawer.dart';
import 'package:ecom_app/widgets/home_page_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tabIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteProductIdsProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: appDrawer(context),
      appBar: frostedTealAppBar(
        context: context,
        title: _titleForTab(_tabIndex),
        showLeading: _tabIndex == 0,
        leadingIcon: Icons.menu_rounded,
        onLeadingPressed: _tabIndex == 0
            ? () => _scaffoldKey.currentState?.openDrawer()
            : null,
        actions: _tabIndex == 0
            ? [
                IconButton(
                  onPressed: _showProfilePopup,
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/panda.jpg'),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ]
            : _tabIndex == 4
                ? [
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No new notifications')),
                        );
                      },
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ]
                : null,
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          HomeTabContent(
            searchController: _searchController,
            favorites: favorites,
            onFavoriteTap: (id) =>
                ref.read(favoriteProductIdsProvider.notifier).toggle(id),
          ),
          OffersTabContent(
            favorites: favorites,
            onFavoriteTap: (id) =>
                ref.read(favoriteProductIdsProvider.notifier).toggle(id),
          ),
          const CartTabContent(),
          FavoritesTabContent(
            favorites: favorites,
            onFavoriteTap: (id) =>
                ref.read(favoriteProductIdsProvider.notifier).toggle(id),
          ),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: FrostedBottomNav(
        currentIndex: _tabIndex,
        onTap: (value) => setState(() => _tabIndex = value),
      ),
    );
  }

  String _titleForTab(int index) {
    switch (index) {
      case 1:
        return 'Offers';
      case 2:
        return 'Cart';
      case 3:
        return 'Favorite';
      case 4:
        return 'Settings';
      default:
        return 'Glamoré';
    }
  }

  Future<void> _showProfilePopup() async {
    final local = UserSingleton().userModel;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (dialogContext) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: kToolbarHeight + 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.64),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: FutureBuilder(
                        future: ref.read(authRepositoryProvider).currentProfile(),
                        builder: (context, snapshot) {
                          final profile = snapshot.data ?? local;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage('assets/images/panda.jpg'),
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (profile?.name.isNotEmpty ?? false)
                                    ? profile!.name
                                    : 'Guest User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF124B48),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile?.email ?? 'No email available',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.65),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (profile?.phoneNumber.isNotEmpty ?? false)
                                    ? profile!.phoneNumber
                                    : 'Phone not added',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.65),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final rootContext = this.context;
                                    final dialogNavigator =
                                        Navigator.of(dialogContext);
                                    await ref.read(authRepositoryProvider).signOut();
                                    UserSingleton().clear();
                                    if (!mounted) return;
                                    if (!rootContext.mounted) return;
                                    dialogNavigator.pop();
                                    Navigator.pushAndRemoveUntil(
                                      rootContext,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Logout'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
