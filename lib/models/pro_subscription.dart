import 'package:cloud_firestore/cloud_firestore.dart';

/// Modello per la sottoscrizione PRO
/// Rappresenta lo stato dell'abbonamento di un professionista
class ProSubscription {
  final String status; // 'active', 'inactive', 'trial', 'past_due'
  final String? provider; // 'stripe', 'paypal', null
  final String? plan; // 'MONTHLY', 'YEARLY', 'FREE_1M', etc.
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? lastPaymentAt;
  final bool cancelAtPeriodEnd;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final String? paypalOrderId;

  ProSubscription({
    required this.status,
    this.provider,
    this.plan,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.lastPaymentAt,
    this.cancelAtPeriodEnd = false,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.paypalOrderId,
  });

  /// Crea un'istanza da un documento Firestore
  factory ProSubscription.fromMap(Map<String, dynamic> data) {
    return ProSubscription(
      status: data['subscriptionStatus'] as String? ?? 'inactive',
      provider: data['subscriptionProvider'] as String?,
      plan: data['subscriptionPlan'] as String?,
      currentPeriodStart: (data['currentPeriodStart'] as Timestamp?)?.toDate(),
      currentPeriodEnd: (data['currentPeriodEnd'] as Timestamp?)?.toDate(),
      lastPaymentAt: (data['lastPaymentAt'] as Timestamp?)?.toDate(),
      cancelAtPeriodEnd: data['cancelAtPeriodEnd'] as bool? ?? false,
      stripeCustomerId: data['stripeCustomerId'] as String?,
      stripeSubscriptionId: data['stripeSubscriptionId'] as String?,
      paypalOrderId: data['paypalOrderId'] as String?,
    );
  }

  /// Converte l'istanza in una mappa per Firestore
  Map<String, dynamic> toMap() {
    return {
      'subscriptionStatus': status,
      'subscriptionProvider': provider,
      'subscriptionPlan': plan,
      'currentPeriodStart': currentPeriodStart != null 
          ? Timestamp.fromDate(currentPeriodStart!) 
          : null,
      'currentPeriodEnd': currentPeriodEnd != null 
          ? Timestamp.fromDate(currentPeriodEnd!) 
          : null,
      'lastPaymentAt': lastPaymentAt != null 
          ? Timestamp.fromDate(lastPaymentAt!) 
          : null,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      'stripeCustomerId': stripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId,
      'paypalOrderId': paypalOrderId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Verifica se l'abbonamento è attivo
  bool get isActive => status == 'active' || status == 'trial';

  /// Verifica se l'abbonamento è in trial
  bool get isTrial => status == 'trial';

  /// Verifica se l'abbonamento è scaduto
  bool get isExpired {
    if (currentPeriodEnd == null) return true;
    return DateTime.now().isAfter(currentPeriodEnd!);
  }

  /// Verifica se l'abbonamento è in ritardo con i pagamenti
  bool get isPastDue => status == 'past_due';

  /// Giorni rimanenti nell'abbonamento
  int get daysRemaining {
    if (currentPeriodEnd == null) return 0;
    final diff = currentPeriodEnd!.difference(DateTime.now());
    return diff.inDays.clamp(0, 365);
  }

  /// Descrizione leggibile dello stato
  String get statusDescription {
    switch (status) {
      case 'active':
        return 'Attivo';
      case 'trial':
        return 'Periodo di prova';
      case 'past_due':
        return 'Pagamento in sospeso';
      case 'inactive':
      default:
        return 'Inattivo';
    }
  }

  /// Descrizione del piano
  String get planDescription {
    switch (plan) {
      case 'MONTHLY':
        return 'Mensile';
      case 'YEARLY':
        return 'Annuale';
      case 'FREE_1M':
        return 'Prova gratuita 1 mese';
      case 'FREE_3M':
        return 'Prova gratuita 3 mesi';
      case 'FREE_12M':
        return 'Prova gratuita 12 mesi';
      default:
        return plan ?? 'Nessuno';
    }
  }

  /// Copia con modifiche
  ProSubscription copyWith({
    String? status,
    String? provider,
    String? plan,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? lastPaymentAt,
    bool? cancelAtPeriodEnd,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    String? paypalOrderId,
  }) {
    return ProSubscription(
      status: status ?? this.status,
      provider: provider ?? this.provider,
      plan: plan ?? this.plan,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      lastPaymentAt: lastPaymentAt ?? this.lastPaymentAt,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      paypalOrderId: paypalOrderId ?? this.paypalOrderId,
    );
  }

  @override
  String toString() {
    return 'ProSubscription(status: $status, provider: $provider, plan: $plan, '
        'isActive: $isActive, daysRemaining: $daysRemaining)';
  }
}
