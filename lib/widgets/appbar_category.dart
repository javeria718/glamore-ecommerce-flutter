import 'package:ecom_app/view/cart/cart_side_panel.dart';
import 'package:ecom_app/view/home.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

PreferredSizeWidget frostedTealAppBar({
  required BuildContext context,
  required String title,
  VoidCallback? onLeadingPressed,
  IconData leadingIcon = Icons.navigate_before,
  bool showLeading = true,
  List<Widget>? actions,
  bool centerTitle = true,
}) {
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    leading: showLeading
        ? IconButton(
            onPressed: onLeadingPressed ??
                () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                },
            icon: Icon(
              leadingIcon,
              color: Colors.white,
            ),
          )
        : null,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.withValues(alpha: 0.93),
                const Color(0xFF0A8E86).withValues(alpha: 0.90),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.26)),
            ),
          ),
        ),
      ),
    ),
    titleTextStyle: const TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(title),
    centerTitle: centerTitle,
    actions: actions,
  );
}

PreferredSizeWidget categoryBar(BuildContext context, String barTitle,
    [IconData? iconn]) {
  return frostedTealAppBar(
    context: context,
    title: barTitle,
    actions: iconn == null
        ? null
        : [
            IconButton(
              onPressed: () {
                showGeneralDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Cart',
                  barrierColor: Colors.black.withValues(alpha: 0.20),
                  transitionDuration: const Duration(milliseconds: 260),
                  pageBuilder: (_, __, ___) {
                    final width = MediaQuery.of(context).size.width;
                    final panelWidth = width > 1024
                        ? 430.0
                        : width > 700
                            ? 390.0
                            : width * 0.92;

                    return SafeArea(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: panelWidth,
                          height: double.infinity,
                          child: const CartSidePanel(),
                        ),
                      ),
                    );
                  },
                  transitionBuilder: (context, animation, _, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: FadeTransition(
                        opacity: curved,
                        child: child,
                      ),
                    );
                  },
                );
              },
              icon: Icon(iconn, color: Colors.white),
            ),
          ],
  );
}
