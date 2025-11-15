import 'package:go_router/go_router.dart';
import '../features/splash/splash_gate.dart';
import '../features/auth/login_page.dart';
import '../features/auth/registration_screen.dart';
import '../features/auth/forgot_password_page.dart';
import '../screens/home/home_owner_screen.dart';
import '../screens/home/home_pro_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/legal/privacy_policy_page.dart';
import '../screens/legal/terms_of_service_page.dart';
import '../admin/admin_home_screen.dart';

/// 🧭 ROUTER APPLICAZIONE MyPetCare
/// Gestisce la navigazione tra le schermate con GoRouter
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 🌟 Splash & Auth
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/forgot',
      builder: (_, __) => const ForgotPasswordPage(),
    ),
    
    // 🏠 Home Screens
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeOwnerScreen(),
    ),
    GoRoute(
      path: '/pro/dashboard',
      builder: (_, __) => const HomeProScreen(),
    ),
    
    // 💳 Subscription
    GoRoute(
      path: '/subscribe',
      builder: (_, __) => const SubscriptionScreen(),
    ),
    
    // 🛡️ Admin Panel (solo per utenti con admin=true)
    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminHomeScreen(),
    ),
    
    // 📄 Legal
    GoRoute(
      path: '/privacy',
      builder: (_, __) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/terms',
      builder: (_, __) => const TermsOfServicePage(),
    ),
  ],
);
