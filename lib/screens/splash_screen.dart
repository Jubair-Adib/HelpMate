import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppTheme.shadowLarge,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/helpmate_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // App Name
            Text(
              'HelpMate',
              style: AppTheme.heading1.copyWith(
                color: AppTheme.surfaceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),

            // Tagline
            Text(
              'Professional Services at Your Doorstep',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.surfaceColor.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.surfaceColor),
            ),
          ],
        ),
      ),
    );
  }
}
