// lib/services/notifications_service.dart
// Servizio notifiche FCM + Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

class NotificationsService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Registra token device FCM per utente
  Future<void> registerDeviceToken(String userId) async {
    try {
      // Richiedi permessi
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        developer.log('Push notification permission denied');
        return;
      }

      // Ottieni token FCM
      final token = await _fcm.getToken();
      if (token == null) {
        developer.log('FCM token is null');
        return;
      }

      developer.log('FCM token obtained: ${token.substring(0, 20)}...');

      // Salva token su Firestore tramite backend API
      // (Oppure direttamente su Firestore se preferisci)
      final docRef = _db.collection('userPushTokens').doc(userId);
      await docRef.set(
        {
          'tokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      developer.log('FCM token registered for user: $userId');
    } catch (e) {
      developer.log('Error registering FCM token: $e');
    }
  }

  /// Inizializza listener notifiche foreground
  void initForegroundListener(
    void Function(String title, String body) onMessage,
  ) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        developer.log(
          'Foreground notification received: ${notification.title}',
        );
        onMessage(
          notification.title ?? 'Notifica',
          notification.body ?? '',
        );
      }
    });
  }

  /// Stream notifiche in-app da Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> userNotificationsStream(
    String userId,
  ) {
    return _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Marca notifica come letta
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _db
          .collection('notifications')
          .doc(userId)
          .collection('items')
          .doc(notificationId)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });

      developer.log('Notification marked as read: $notificationId');
    } catch (e) {
      developer.log('Error marking notification as read: $e');
    }
  }
}
