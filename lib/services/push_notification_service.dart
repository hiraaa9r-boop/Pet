import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function per gestire messaggi in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('📬 Background Message: ${message.messageId}');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  String? _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Richiedi permessi
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) debugPrint('✅ Permessi notifiche concessi');
      } else {
        if (kDebugMode) debugPrint('⚠️ Permessi notifiche negati');
        return;
      }

      // Ottieni FCM token
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) debugPrint('📱 FCM Token: $_fcmToken');

      // Salva token su Firestore
      await _saveFcmToken(_fcmToken);

      // Configura local notifications per Android
      await _initializeLocalNotifications();

      // Setup handlers
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Gestisci notifica che ha aperto l'app
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _initialized = true;
      if (kDebugMode) debugPrint('✅ Push Notification Service inizializzato');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Errore inizializzazione notifiche: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) debugPrint('📬 Notifica tappata: ${details.payload}');
        // TODO: Naviga alla pagina appropriata
      },
    );
  }

  Future<void> _saveFcmToken(String? token) async {
    if (token == null) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Salva token in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) debugPrint('✅ FCM Token salvato su Firestore');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Errore salvataggio FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📬 Foreground Message: ${message.messageId}');
      debugPrint('   Title: ${message.notification?.title}');
      debugPrint('   Body: ${message.notification?.body}');
      debugPrint('   Data: ${message.data}');
    }

    // Mostra notifica locale quando app è in foreground
    _showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📬 Message Opened App: ${message.messageId}');
      debugPrint('   Data: ${message.data}');
    }

    // TODO: Naviga alla pagina appropriata basandosi su message.data
    // Esempio:
    // if (message.data['type'] == 'new_booking') {
    //   navigatorKey.currentState?.pushNamed('/bookings/${message.data['bookingId']}');
    // }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'my_pet_care_channel',
      'My Pet Care Notifications',
      channelDescription: 'Notifiche per prenotazioni e aggiornamenti',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'My Pet Care',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  // Metodi per inviare notifiche (da chiamare via Cloud Functions)
  
  /// Invia notifica a un professionista quando riceve una nuova prenotazione
  Future<void> notifyNewBooking({
    required String proId,
    required String ownerName,
    required DateTime bookingDate,
  }) async {
    // TODO: Implementare via Cloud Function
    // La Cloud Function legge il FCM token del professionista e invia la notifica
    if (kDebugMode) {
      debugPrint('📤 Notifica nuova prenotazione inviata a: $proId');
      debugPrint('   Da: $ownerName');
      debugPrint('   Data: $bookingDate');
    }
  }

  /// Invia notifica all'utente quando la prenotazione viene confermata
  Future<void> notifyBookingConfirmed({
    required String userId,
    required String proName,
    required DateTime bookingDate,
  }) async {
    // TODO: Implementare via Cloud Function
    if (kDebugMode) {
      debugPrint('📤 Notifica prenotazione confermata inviata a: $userId');
      debugPrint('   Pro: $proName');
      debugPrint('   Data: $bookingDate');
    }
  }

  /// Invia reminder 24h prima dell'appuntamento
  Future<void> sendBookingReminder({
    required String userId,
    required String proName,
    required DateTime bookingDate,
  }) async {
    // TODO: Implementare via Cloud Function schedulata
    if (kDebugMode) {
      debugPrint('📤 Reminder inviato a: $userId');
      debugPrint('   Pro: $proName');
      debugPrint('   Data: $bookingDate');
    }
  }

  /// Invia notifica al professionista quando l'abbonamento sta per scadere
  Future<void> notifySubscriptionExpiring({
    required String proId,
    required int daysRemaining,
  }) async {
    // TODO: Implementare via Cloud Function schedulata
    if (kDebugMode) {
      debugPrint('📤 Notifica scadenza abbonamento inviata a: $proId');
      debugPrint('   Giorni rimanenti: $daysRemaining');
    }
  }

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _initialized;

  Future<void> dispose() async {
    // Cleanup se necessario
  }
}
