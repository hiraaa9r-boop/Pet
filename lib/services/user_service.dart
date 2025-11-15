import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔧 UserService - Centro unico per gestione ruoli, abbonamenti e notifiche
/// 
/// Questo servizio gestisce:
/// - Lettura dati da users/{uid}
/// - Lettura dati da pros/{uid} (per professionisti)
/// - Aggiornamento preferenze notifiche con doppio update (users + pros)
class UserService {
  final _firestore = FirebaseFirestore.instance;

  /// Leggi i dati utente da Firestore users/{uid}
  /// Ritorna null se il documento non esiste
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Errore nel caricamento dati utente: $e');
    }
  }

  /// Leggi i dati professionista da Firestore pros/{uid}
  /// Ritorna null se il documento non esiste (utente non è PRO)
  Future<Map<String, dynamic>?> getProData(String uid) async {
    try {
      final doc = await _firestore.collection('pros').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Errore nel caricamento dati professionista: $e');
    }
  }

  /// Aggiorna le preferenze notifiche dell'utente
  /// 
  /// IMPORTANTE: Aggiorna ENTRAMBE le collection:
  /// - users/{uid}.notifications
  /// - pros/{uid}.notifications (se esiste)
  /// 
  /// Questo garantisce consistenza tra le due collection
  Future<void> updateNotificationPrefs({
    required String uid,
    required bool push,
    required bool email,
    required bool marketing,
  }) async {
    try {
      final notificationData = {
        'notifications.pushEnabled': push,
        'notifications.emailEnabled': email,
        'notifications.marketingEnabled': marketing,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Aggiorna users/{uid}
      await _firestore.collection('users').doc(uid).update(notificationData);

      // 2. Se è PRO, aggiorna anche pros/{uid}
      final proDoc = await _firestore.collection('pros').doc(uid).get();
      if (proDoc.exists) {
        await _firestore.collection('pros').doc(uid).update(notificationData);
      }
    } catch (e) {
      throw Exception('Errore nel salvataggio preferenze notifiche: $e');
    }
  }
}
