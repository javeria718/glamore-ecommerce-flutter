import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/auth/login.dart';
import 'package:ecom_app/widgets/custombotton.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final heroHeight = (screenWidth * 0.38).clamp(170.0, 260.0);
    final titleSize = (screenWidth * 0.047).clamp(22.0, 30.0);
    final subtitleSize = (screenWidth * 0.027).clamp(13.0, 16.0);
    final horizontalPadding = (screenWidth * 0.04).clamp(18.0, 28.0);
    final verticalPadding = (screenWidth * 0.045).clamp(22.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: frostyLightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: FrostedGlassCard(
                maxWidth: 560,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/girlshopping.jpeg',
                      height: heroHeight,
                    ),
                    const SizedBox(height: 20),
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
                        'Welcome to Glamoré',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Find Your Style. Shop Your Dreams.',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.black.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: 'Get Started',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
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
