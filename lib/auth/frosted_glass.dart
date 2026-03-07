import 'dart:ui';

import 'package:flutter/material.dart';

Widget frostyLightBackground({required Widget child}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF4FBF9),
          Color(0xFFE8F5F1),
          Color(0xFFF9FCFB),
        ],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          top: -70,
          left: -40,
          child: _softBlob(
            size: 220,
            color: const Color(0x6620B2AA),
          ),
        ),
        Positioned(
          bottom: -90,
          right: -40,
          child: _softBlob(
            size: 260,
            color: const Color(0x33A7E3DD),
          ),
        ),
        child,
      ],
    ),
  );
}

Widget _softBlob({required double size, required Color color}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}

class FrostedGlassCard extends StatelessWidget {
  const FrostedGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.maxWidth = 520,
  });

  final Widget child;
  final EdgeInsets padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: 0.58),
              border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
