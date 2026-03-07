import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/view/welcome/welcome.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    splashMethod();
  }

  Future<void> splashMethod() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final brandSize = (screenWidth * 0.065).clamp(30.0, 38.0);
    final subtitleSize = (screenWidth * 0.025).clamp(13.0, 15.0);
    final cardPadding = (screenWidth * 0.05).clamp(20.0, 28.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: frostyLightBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FrostedGlassCard(
                maxWidth: 420,
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF006D6F),
                          Color(0xFF00A8A8),
                          Color(0xFF5FE3E3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Glamoré',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: brandSize,
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Luxury, curated for you',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.black.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: Colors.teal),
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
