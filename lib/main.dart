import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('🚀 Inizializzazione Firebase...');
  }

  bool firebaseInitialized = false;
  String? firebaseError;

  try {
    // Timeout di 10 secondi per Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint('⏱️ TIMEOUT: Firebase initialization troppo lenta');
        }
        throw Exception('Firebase initialization timeout dopo 10 secondi');
      },
    );

    firebaseInitialized = true;
    if (kDebugMode) {
      debugPrint('✅ Firebase inizializzato con successo!');
    }

    // Inizializza Push Notifications
    try {
      await PushNotificationService().initialize();
      if (kDebugMode) {
        debugPrint('✅ Push Notifications inizializzate');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Errore inizializzazione notifiche push: $e');
      }
    }
  } catch (e, stackTrace) {
    firebaseError = e.toString();
    if (kDebugMode) {
      debugPrint('❌ ERRORE inizializzazione Firebase: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('⚠️ Avvio app in MODALITÀ OFFLINE');
    }
  }

  // AVVIA APP SEMPRE - anche se Firebase fallisce
  runApp(MyApp(
    firebaseInitialized: firebaseInitialized,
    firebaseError: firebaseError,
  ));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  final String? firebaseError;

  const MyApp({
    super.key,
    required this.firebaseInitialized,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Pet Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
      builder: (context, child) {
        // Mostra banner se Firebase non è inizializzato
        if (!firebaseInitialized && child != null) {
          return Stack(
            children: [
              child,
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Material(
                    color: Colors.orange.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Modalità Offline: ${firebaseError ?? "Firebase non disponibile"}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
