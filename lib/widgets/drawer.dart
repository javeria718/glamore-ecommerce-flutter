import 'dart:ui';

import 'package:ecom_app/view/categories/bags.dart';
import 'package:ecom_app/view/categories/clothes.dart';
import 'package:ecom_app/view/categories/jewelery.dart';
import 'package:ecom_app/view/categories/shoes.dart';
import 'package:ecom_app/view/categories/watches.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/auth/login.dart';
import 'package:ecom_app/Singleton/singleton.dart';

Widget appDrawer(BuildContext context) {
  final user = UserSingleton().userModel;

  return Drawer(
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.84),
                const Color(0xFFE5F7F4).withValues(alpha: 0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.withValues(alpha: 0.92),
                        const Color(0xFF0A8E86).withValues(alpha: 0.86),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.34)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              AssetImage('assets/images/panda.jpg'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Guest User',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'email@example.com',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    children: [
                      _drawerItem(
                        context: context,
                        title: 'Clothes',
                        leadingIcon: Icons.checkroom_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Clothes()),
                          );
                        },
                      ),
                      _drawerItem(
                        context: context,
                        title: 'Watches',
                        leadingIcon: Icons.watch_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Watches()),
                          );
                        },
                      ),
                      _drawerItem(
                        context: context,
                        title: 'Shoes',
                        leadingIcon: Icons.hiking_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Shoes()),
                          );
                        },
                      ),
                      _drawerItem(
                        context: context,
                        title: 'Bags',
                        leadingIcon: Icons.work_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Bags()),
                          );
                        },
                      ),
                      _drawerItem(
                        context: context,
                        title: 'Jewellery',
                        leadingIcon: Icons.diamond_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Jewelery()),
                          );
                        },
                      ),
                      // _drawerItem(
                      //   context: context,
                      //   title: 'Your Cart',
                      //   leadingIcon: Icons.shopping_cart_outlined,
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => const AddToCart()),
                      //     );
                      //   },
                      // ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Divider(
                          color: Colors.teal.withValues(alpha: 0.25),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _drawerItem(
                        context: context,
                        title: 'Logout',
                        leadingIcon: Icons.logout,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _drawerItem({
  required BuildContext context,
  required String title,
  required IconData leadingIcon,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      boxShadow: [
        BoxShadow(
          color: Colors.teal.withValues(alpha: 0.07),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ListTile(
      onTap: onTap,
      leading: Icon(leadingIcon, color: const Color(0xFF0B6E69)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A3F3C),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.teal.withValues(alpha: 0.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
