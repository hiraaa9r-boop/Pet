import 'package:cloud_firestore/cloud_firestore.dart';

/// 🧑‍⚕️ MODELLO PROFESSIONISTA per visualizzazione in mappa/lista
/// Lightweight version per performance
class ProModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final double lat;
  final double lng;
  final String? photoUrl;
  final double? priceFrom;
  final double? rating;

  ProModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.lat,
    required this.lng,
    this.photoUrl,
    this.priceFrom,
    this.rating,
  });

  /// Factory da DocumentSnapshot Firestore
  factory ProModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProModel(
      id: doc.id,
      name: data['businessName'] ?? data['name'] ?? 'Professionista',
      category: data['category'] ?? 'unknown',
      address: data['studioAddress'] ?? data['address'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'] as String?,
      priceFrom: data['priceFrom'] != null 
          ? (data['priceFrom'] as num).toDouble() 
          : null,
      rating: data['rating'] != null 
          ? (data['rating'] as num).toDouble() 
          : null,
    );
  }

  /// Factory da Map (per compatibility)
  factory ProModel.fromMap(Map<String, dynamic> data, String id) {
    return ProModel(
      id: id,
      name: data['businessName'] ?? data['name'] ?? 'Professionista',
      category: data['category'] ?? 'unknown',
      address: data['studioAddress'] ?? data['address'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'] as String?,
      priceFrom: data['priceFrom'] != null 
          ? (data['priceFrom'] as num).toDouble() 
          : null,
      rating: data['rating'] != null 
          ? (data['rating'] as num).toDouble() 
          : null,
    );
  }
}
