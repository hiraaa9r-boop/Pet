import 'package:cloud_firestore/cloud_firestore.dart';

/// 🧑‍⚕️ MODELLO PROFESSIONISTA per visualizzazione in mappa/lista
/// Lightweight version per performance
class ProModel {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? category;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final double? priceFrom;
  final double? rating;
  final int? reviewCount;
  final List<String>? services;
  final String? bio;
  final String? status; // approved, pending, rejected
  final String? subscriptionStatus; // active, inactive, trial

  ProModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.category,
    this.address,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.priceFrom,
    this.rating,
    this.reviewCount,
    this.services,
    this.bio,
    this.status,
    this.subscriptionStatus,
  });

  /// Factory da Map Firestore
  factory ProModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Gestisce servizi come array o string
    List<String>? services;
    if (data['services'] is List) {
      services = (data['services'] as List).map((e) => e.toString()).toList();
    } else if (data['services'] is String) {
      services = [data['services'] as String];
    }

    return ProModel(
      id: id,
      name: data['businessName'] as String? ?? data['name'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      category: data['category'] as String?,
      address: data['studioAddress'] as String? ?? data['address'] as String?,
      latitude: data['latitude'] != null ? (data['latitude'] as num).toDouble() : null,
      longitude: data['longitude'] != null ? (data['longitude'] as num).toDouble() : null,
      photoUrl: data['photoUrl'] as String?,
      priceFrom: data['priceFrom'] != null ? (data['priceFrom'] as num).toDouble() : null,
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      reviewCount: data['reviewCount'] as int?,
      services: services,
      bio: data['bio'] as String?,
      status: data['status'] as String?,
      subscriptionStatus: data['subscriptionStatus'] as String?,
    );
  }

  /// Factory da DocumentSnapshot (backward compatibility)
  factory ProModel.fromDoc(DocumentSnapshot doc) {
    return ProModel.fromFirestore(
      doc.data() as Map<String, dynamic>? ?? {},
      doc.id,
    );
  }

  /// Factory da Map con id separato (backward compatibility)
  factory ProModel.fromMap(Map<String, dynamic> data, String id) {
    return ProModel.fromFirestore(data, id);
  }
}
