import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../ui/widgets/brand_logo.dart';

/// 🎯 SCHERMATA LOGO STATICA MyPetCare
/// - Logo NON animato, NON auto-skip
/// - Funziona da BOTTONE: tap/click sul logo → vai a LOGIN
/// - Compatibile: Android, iOS, Web (click mouse)
/// - Design unificato con nuovo brand system
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});
  
  void _goToLogin(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🚀 Splash: Navigazione verso LOGIN');
    }
    context.go('/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.primary,
      body: SafeArea(
        child: InkWell(
          onTap: () => _goToLogin(context),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo con container bianco
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: const BrandLogo(
                        size: 200,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Nome app in bianco
                    Text(
                      'MyPetCare',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tutti i servizi per il tuo pet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Hint visivo
                    Text(
                      'Tocca per iniziare',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
}
