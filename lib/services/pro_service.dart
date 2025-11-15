import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/pro_model.dart';

/// 🔧 SERVIZIO per caricamento Professionisti da Firestore
/// - Stream real-time per aggiornamenti automatici
/// - Filtro per categoria
/// - Solo PRO attivi con subscriptionStatus='active'
class ProService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream di professionisti filtrati
  /// - category: null o 'all' = tutti, altrimenti filtra per categoria
  /// - Solo PRO con active=true e subscriptionStatus='active'
  Stream<List<ProModel>> streamPros({String? category}) {
    try {
      Query query = _firestore
          .collection('professionals')
          .where('isActive', isEqualTo: true)
          .where('subscriptionStatus', isEqualTo: 'active');

      // Filtro categoria (opzionale)
      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      return query.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => ProModel.fromDoc(doc))
                .toList(),
          );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore streamPros: $e');
      }
      return Stream.value([]);
    }
  }

  /// Ottiene singolo professionista per ID
  Future<ProModel?> getProById(String proId) async {
    try {
      final doc = await _firestore
          .collection('professionals')
          .doc(proId)
          .get();

      if (!doc.exists) return null;

      return ProModel.fromDoc(doc);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore getProById: $e');
      }
      return null;
    }
  }

  /// Ottiene pro vicini (placeholder per geolocalizzazione futura)
  Stream<List<ProModel>> streamProsByLocation({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
    String? category,
  }) {
    // TODO: Implementare geolocalizzazione con GeoFirestore o calcolo distanza
    // Per ora ritorna tutti i pro filtrati per categoria
    return streamPros(category: category);
  }
}
