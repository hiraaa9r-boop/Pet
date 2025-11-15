import 'package:cloud_firestore/cloud_firestore.dart';

/// 🗓️ SLOT DEL CALENDARIO
/// Rappresenta un singolo slot orario (es. "09:00")
class CalendarSlot {
  final String time;      // es. "09:00"
  final bool enabled;     // il PRO lo ha reso disponibile
  final bool booked;      // c'è una prenotazione attiva
  final bool locked;      // c'è un lock con ttl futuro

  CalendarSlot({
    required this.time,
    required this.enabled,
    required this.booked,
    required this.locked,
  });

  CalendarSlot copyWith({
    bool? enabled,
    bool? booked,
    bool? locked,
  }) {
    return CalendarSlot(
      time: time,
      enabled: enabled ?? this.enabled,
      booked: booked ?? this.booked,
      locked: locked ?? this.locked,
    );
  }
}

/// 🔧 SERVIZIO CALENDARIO CON TEMPLATE SETTIMANALI
/// Gestisce disponibilità, prenotazioni e locks degli slot orari
/// 
/// Struttura Firestore:
/// - calendars/{proId}/days/{YYYY-MM-DD} → override giornaliero
/// - calendars/{proId}/weeklyTemplates/{1-7} → template per giorno settimana
/// - calendars/{proId}/locks/{lockId} → lock temporanei
/// - bookings/{bookingId} → prenotazioni confermate
/// 
/// Priorità configurazione:
/// 1. calendars/{proId}/days/{YYYY-MM-DD} (override specifico)
/// 2. calendars/{proId}/weeklyTemplates/{weekday} (template settimanale)
/// 3. defaultSlots() (fallback se nessuna config)
class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Converte DateTime in dayId formato "YYYY-MM-DD"
  String dayIdFromDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Ritorna il giorno della settimana (1=lunedì, 7=domenica)
  int weekdayFromDate(DateTime date) {
    // 1 = lunedì ... 7 = domenica (stesso di Dart)
    return date.weekday;
  }

  /// Slot di default se non ci sono né configurazione giornaliera né template
  /// Default: 9-13 e 15-18 (ogni ora) - tutti disabilitati
  List<CalendarSlot> defaultSlots() {
    final times = <String>[
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '15:00',
      '16:00',
      '17:00',
    ];
    return times
        .map((t) => CalendarSlot(
              time: t,
              enabled: false,
              booked: false,
              locked: false,
            ))
        .toList();
  }

  /// Carica la configurazione di base per un giorno con logica a cascata:
  /// 1. Cerca calendars/{proId}/days/{YYYY-MM-DD} (override specifico)
  /// 2. Se non esiste o slots vuoti → cerca calendars/{proId}/weeklyTemplates/{weekday}
  /// 3. Se non esiste nulla → defaultSlots()
  Future<List<CalendarSlot>> loadBaseSlots(
    String proId,
    DateTime date,
  ) async {
    final dayId = dayIdFromDate(date);
    final dayRef = _firestore
        .collection('calendars')
        .doc(proId)
        .collection('days')
        .doc(dayId);

    // 1️⃣ Prova a caricare override giornaliero
    final daySnap = await dayRef.get();
    if (daySnap.exists) {
      final data = daySnap.data()!;
      final rawSlots = (data['slots'] as List<dynamic>? ?? []);
      if (rawSlots.isNotEmpty) {
        return rawSlots.map((raw) {
          final m = raw as Map<String, dynamic>;
          return CalendarSlot(
            time: m['time'] as String,
            enabled: (m['enabled'] ?? false) as bool,
            booked: false,
            locked: false,
          );
        }).toList();
      }
    }

    // 2️⃣ Fallback: template settimanale
    final weekday = weekdayFromDate(date).toString(); // "1".."7"
    final tmplRef = _firestore
        .collection('calendars')
        .doc(proId)
        .collection('weeklyTemplates')
        .doc(weekday);

    final tmplSnap = await tmplRef.get();
    if (tmplSnap.exists) {
      final data = tmplSnap.data()!;
      final rawSlots = (data['slots'] as List<dynamic>? ?? []);
      if (rawSlots.isNotEmpty) {
        return rawSlots.map((raw) {
          final m = raw as Map<String, dynamic>;
          return CalendarSlot(
            time: m['time'] as String,
            enabled: (m['enabled'] ?? false) as bool,
            booked: false,
            locked: false,
          );
        }).toList();
      }
    }

    // 3️⃣ Nessuna config → default
    return defaultSlots();
  }

  /// Stream delle prenotazioni per un giorno (slot occupati)
  Stream<QuerySnapshot<Map<String, dynamic>>> bookingsForDayStream(
    String proId,
    DateTime date,
  ) {
    final dayId = dayIdFromDate(date);
    return _firestore
        .collection('bookings')
        .where('proId', isEqualTo: proId)
        .where('dayId', isEqualTo: dayId)
        .where('status', whereIn: ['pending', 'confirmed'])
        .snapshots();
  }

  /// Stream dei locks validi (ttl > now) per un giorno
  Stream<QuerySnapshot<Map<String, dynamic>>> locksForDayStream(
    String proId,
    DateTime date,
  ) {
    final dayId = dayIdFromDate(date);
    final now = Timestamp.fromDate(DateTime.now());
    return _firestore
        .collection('calendars')
        .doc(proId)
        .collection('locks')
        .where('dayId', isEqualTo: dayId)
        .where('ttl', isGreaterThan: now)
        .snapshots();
  }

  /// Salva configurazione di un giorno specifico (override rispetto al template)
  /// Questo sovrascrive il template settimanale per questa data specifica
  Future<void> saveSlotsForDay({
    required String proId,
    required DateTime date,
    required List<CalendarSlot> slots,
  }) async {
    final dayId = dayIdFromDate(date);
    final docRef = _firestore
        .collection('calendars')
        .doc(proId)
        .collection('days')
        .doc(dayId);

    final dataSlots = slots
        .map((s) => {
              'time': s.time,
              'enabled': s.enabled,
            })
        .toList();

    await docRef.set(
      {
        'dayId': dayId,
        'slots': dataSlots,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Salva la configurazione come template settimanale
  /// (weekday: 1=lun, 2=mar, 3=mer, 4=gio, 5=ven, 6=sab, 7=dom)
  /// 
  /// Questo template verrà usato per tutte le date future di questo giorno
  /// della settimana, a meno che non ci sia un override specifico
  Future<void> saveWeeklyTemplate({
    required String proId,
    required int weekday,
    required List<CalendarSlot> slots,
  }) async {
    final tmplRef = _firestore
        .collection('calendars')
        .doc(proId)
        .collection('weeklyTemplates')
        .doc(weekday.toString());

    final dataSlots = slots
        .map((s) => {
              'time': s.time,
              'enabled': s.enabled,
            })
        .toList();

    await tmplRef.set(
      {
        'weekday': weekday,
        'slots': dataSlots,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Crea un lock temporaneo su uno slot (per evitare doppie prenotazioni)
  /// TTL di default: 5 minuti
  Future<String> createLock({
    required String proId,
    required DateTime date,
    required String timeSlot,
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final dayId = dayIdFromDate(date);
    final lockRef = _firestore
        .collection('calendars')
        .doc(proId)
        .collection('locks')
        .doc();

    final lockData = {
      'dayId': dayId,
      'time': timeSlot,
      'ttl': Timestamp.fromDate(DateTime.now().add(ttl)),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await lockRef.set(lockData);
    return lockRef.id;
  }

  /// Rimuove un lock (quando la prenotazione è confermata o cancellata)
  Future<void> removeLock({
    required String proId,
    required String lockId,
  }) async {
    await _firestore
        .collection('calendars')
        .doc(proId)
        .collection('locks')
        .doc(lockId)
        .delete();
  }
}
