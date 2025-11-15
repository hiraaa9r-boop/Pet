import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../features/auth/login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.primary,
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () => _goToLogin(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo centrale statico
                Container(
                  padding: const EdgeInsets.all(AppBrand.spacingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppBrand.borderRadius * 2),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/my_pet_care_splash_logo.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppBrand.spacingL),
                Text(
                  'MY PET CARE',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: AppBrand.spacingS),
                Text(
                  'Il tuo pet, il nostro impegno',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: AppBrand.spacingL),
                Text(
                  'Tocca il logo per continuare',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
