// lib/models/pro_subscription_model.dart
// Modello abbonamento PRO semplificato

import 'package:cloud_firestore/cloud_firestore.dart';

class ProSubscription {
  final String status; // active | inactive | trial | past_due
  final String? provider; // stripe | paypal
  final String? plan;
  final DateTime? currentPeriodEnd;

  ProSubscription({
    required this.status,
    this.provider,
    this.plan,
    this.currentPeriodEnd,
  });

  factory ProSubscription.fromMap(Map<String, dynamic> data) {
    return ProSubscription(
      status: data['subscriptionStatus'] as String? ?? 'inactive',
      provider: data['subscriptionProvider'] as String?,
      plan: data['subscriptionPlan'] as String?,
      currentPeriodEnd:
          (data['currentPeriodEnd'] as Timestamp?)?.toDate(),
    );
  }

  bool get isActive => status == 'active' || status == 'trial';
  bool get isTrial => status == 'trial';
  bool get isPastDue => status == 'past_due';

  String get statusDescription {
    switch (status) {
      case 'active':
        return isTrial ? 'Periodo di prova' : 'Abbonamento attivo';
      case 'past_due':
        return 'Pagamento scaduto';
      case 'inactive':
        return 'Nessun abbonamento';
      default:
        return 'Stato sconosciuto';
    }
  }

  String get planDescription {
    if (plan == null) return 'N/A';
    if (plan!.contains('month')) return 'Piano Mensile';
    if (plan!.contains('year')) return 'Piano Annuale';
    return plan!;
  }

  int get daysRemaining {
    if (currentPeriodEnd == null) return 0;
    final diff = currentPeriodEnd!.difference(DateTime.now());
    return diff.inDays.clamp(0, 365);
  }
}
