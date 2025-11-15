# 🔌 MyPetCare - UI Integration Guide

## 📋 Obiettivo

Questa guida spiega come integrare le nuove schermate UI create con il sistema di routing esistente dell'app MyPetCare.

---

## 🚀 Quick Start

### **Situazione Attuale:**
L'app MyPetCare usa **go_router** per la gestione delle route, configurato in `lib/router/app_router.dart`.

### **Nuove Schermate Create:**
Sono state create 11 nuove schermate complete con Material Design 3:
- Splash, Login, Registration, Forgot Password
- Home Owner (3 tabs), Home Pro (4 tabs)
- Subscription, Privacy, Terms

---

## 🔧 Step di Integrazione

### **STEP 1: Aggiornare app_router.dart**

Apri `lib/router/app_router.dart` e aggiungi le nuove route:

```dart
import 'package:go_router/go_router.dart';
import '../ui/screens/splash_logo_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/registration_screen.dart';
import '../ui/screens/forgot_password_screen.dart';
import '../ui/screens/home_owner_screen.dart';
import '../ui/screens/home_pro_screen.dart';
import '../ui/screens/subscription_screen.dart';
import '../ui/screens/privacy_screen.dart';
import '../ui/screens/terms_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash', // Cambia da '/' a '/splash'
  routes: [
    // Splash Screen (entry point)
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashLogoScreen(),
    ),
    
    // Authentication
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/forgot',
      name: 'forgot',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Home Screens
    GoRoute(
      path: '/homeOwner',
      name: 'homeOwner',
      builder: (context, state) => const HomeOwnerScreen(),
    ),
    GoRoute(
      path: '/homePro',
      name: 'homePro',
      builder: (context, state) => const HomeProScreen(),
    ),
    
    // Subscription
    GoRoute(
      path: '/subscribe',
      name: 'subscribe',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    
    // Legal
    GoRoute(
      path: '/privacy',
      name: 'privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsScreen(),
    ),
    
    // TODO: Aggiungi qui le route esistenti (booking, pro_detail, etc.)
  ],
);
```

---

### **STEP 2: Aggiornare Navigazione nelle Schermate**

Le nuove schermate usano `Navigator.of(context).pushNamed()`. Per usare go_router, sostituisci con:

**PRIMA (Navigator):**
```dart
Navigator.of(context).pushNamed('/login');
```

**DOPO (go_router):**
```dart
import 'package:go_router/go_router.dart';
context.go('/login');
// oppure
context.push('/login');
```

**File da aggiornare:**
- `lib/ui/screens/splash_logo_screen.dart` (linea ~14)
- `lib/ui/screens/login_screen.dart` (linee ~56, ~117, ~121, ~125, ~129)
- `lib/ui/screens/registration_screen.dart` (linee ~113, ~117, ~147, ~151)
- `lib/ui/screens/forgot_password_screen.dart` (linea ~36)

**Esempio pratico:**

```dart
// SPLASH SCREEN
void _goToLogin(BuildContext context) {
  context.go('/login'); // Invece di Navigator.of(context).pushReplacementNamed('/login');
}

// LOGIN SCREEN
void _goToRegister() {
  context.push('/register'); // Invece di Navigator.of(context).pushNamed('/register');
}

// Dopo login con successo
if (_selectedRole == 'pro') {
  context.go('/homePro'); // Invece di Navigator.of(context).pushReplacementNamed('/homePro');
} else {
  context.go('/homeOwner');
}
```

---

### **STEP 3: Integrare Widget Esistenti**

Le Home Screens hanno placeholder (TODO) da sostituire con i widget esistenti.

#### **A. Home Owner - Mappa**

**File:** `lib/ui/screens/home_owner_screen.dart`  
**Location:** `_OwnerMapScreen` widget  
**Sostituire:**

```dart
// PRIMA
class _OwnerMapScreen extends StatelessWidget {
  const _OwnerMapScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mappa PRO (collega al widget esistente di map + filtri)'),
    );
  }
}

// DOPO
class _OwnerMapScreen extends StatelessWidget {
  const _OwnerMapScreen();

  @override
  Widget build(BuildContext context) {
    return YourExistingMapWidget(); // ← Il tuo widget mappa esistente
  }
}
```

#### **B. Home Owner - Lista PRO**

**File:** `lib/ui/screens/home_owner_screen.dart`  
**Location:** `_OwnerListScreen` widget  
**Sostituire con il tuo widget lista professionisti**

#### **C. Home Pro - Calendario**

**File:** `lib/ui/screens/home_pro_screen.dart`  
**Location:** `_ProCalendarScreen` widget  
**Sostituire con il tuo widget calendario/slot**

#### **D. Home Pro - Prenotazioni**

**File:** `lib/ui/screens/home_pro_screen.dart`  
**Location:** `_ProBookingsScreen` widget  
**Sostituire con il tuo widget lista bookings**

---

### **STEP 4: Configurare Assets**

Aggiungi il logo dell'app a `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/logo_mypetcare.png
```

Se non hai ancora il logo, il `BrandLogo` widget mostrerà automaticamente un fallback icon (pets).

---

### **STEP 5: Test Navigazione**

Testa il flusso completo:

1. **Owner Journey:**
   ```
   Splash → Login → Home Owner (3 tabs)
          ↓
   Splash → Register (Owner) → Home Owner
   ```

2. **Pro Journey:**
   ```
   Splash → Login → Home Pro (4 tabs)
          ↓
   Splash → Register (Pro) → Subscription → Home Pro
   ```

3. **Password Recovery:**
   ```
   Login → Forgot Password → Reset Email Sent → Login
   ```

4. **Legal:**
   ```
   Login → Privacy (link) → Back
   Login → Terms (link) → Back
   ```

---

## 📝 Checklist Integrazione

- [ ] Aggiornato `app_router.dart` con nuove route
- [ ] Sostituito `Navigator` con `go_router` (`context.go()`, `context.push()`)
- [ ] Integrato widget mappa in `_OwnerMapScreen`
- [ ] Integrato widget lista PRO in `_OwnerListScreen`
- [ ] Integrato widget calendario in `_ProCalendarScreen`
- [ ] Integrato widget prenotazioni in `_ProBookingsScreen`
- [ ] Aggiunto logo in `assets/` e configurato `pubspec.yaml`
- [ ] Testato tutti i flussi di navigazione
- [ ] Verificato funzionamento Firebase Auth
- [ ] Verificato creazione documenti Firestore (users, pros)

---

## 🔍 Troubleshooting

### **Problema: "Named route not found"**
**Soluzione:** Verifica che la route sia definita in `app_router.dart` con path e name corretti.

### **Problema: "Navigator operation requested with a context that does not include a Navigator"**
**Soluzione:** Usa `go_router` invece di `Navigator`:
```dart
// ❌ WRONG
Navigator.of(context).pushNamed('/login');

// ✅ CORRECT
context.go('/login');
```

### **Problema: "Asset not found: assets/logo_mypetcare.png"**
**Soluzione:** 
1. Aggiungi il file in `assets/logo_mypetcare.png`
2. Dichiara in `pubspec.yaml` sotto `flutter: > assets:`
3. Esegui `flutter pub get`

### **Problema: Login redirect non funziona**
**Soluzione:** Verifica che il documento Firestore `users/{uid}` abbia il campo `role` impostato correttamente (`'owner'` o `'pro'`).

---

## 🚀 Deployment Checklist

Prima del deploy:

- [ ] ✅ Tutte le schermate funzionanti
- [ ] ✅ Navigazione fluida senza crash
- [ ] ✅ Firebase Auth connesso e funzionante
- [ ] ✅ Firestore regole configurate (development mode)
- [ ] ✅ Theme colori MyPetCare applicato
- [ ] ✅ Logo visibile in tutte le schermate auth
- [ ] ✅ Privacy Policy e Terms of Service completi
- [ ] ✅ Subscription flow testato (Stripe/PayPal backend ready)
- [ ] ✅ Error handling su tutte le azioni
- [ ] ✅ Loading states su operazioni async
- [ ] ✅ SnackBar feedback su successo/errore

---

## 📚 Risorse Utili

- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Firebase Auth Flutter](https://firebase.flutter.dev/docs/auth/overview)
- [Cloud Firestore Flutter](https://firebase.flutter.dev/docs/firestore/overview)
- [Material Design 3](https://m3.material.io/)

---

## 💡 Best Practices

1. **Usa go_router per tutta la navigazione** - Consistenza e typesafe routing
2. **Gestisci stati con Provider/Riverpod** - Se l'app cresce
3. **Centralizza la logica Firebase** - Crea service classes
4. **Testa su dispositivi reali** - Non solo emulatore
5. **Monitora Firebase Console** - Verifica creazione documenti corretta

---

**✅ IMPLEMENTAZIONE UI COMPLETA E PRONTA PER L'INTEGRAZIONE!**

Per domande o problemi, consulta la documentazione completa in `docs/UI_IMPLEMENTATION_SUMMARY.md`.
