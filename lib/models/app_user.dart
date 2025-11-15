/// 🧑‍💼 AppUser Model
/// 
/// Rappresenta l'utente corrente dell'app con tutti i ruoli e permessi
/// Include il supporto per custom claims Firebase Auth (admin)

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin; // Custom claim Firebase Auth
  final String role; // 'owner' | 'pro' | 'admin'

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isAdmin,
    required this.role,
  });

  /// Factory da Firebase User + custom claims
  factory AppUser.fromFirebase({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    required Map<String, dynamic> claims,
  }) {
    // Leggi custom claim admin
    final isAdmin = claims['admin'] == true;
    
    // Determina role (priorità: admin > claim role > 'owner')
    String role = 'owner';
    if (isAdmin) {
      role = 'admin';
    } else if (claims['role'] != null) {
      role = claims['role'] as String;
    }

    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isAdmin: isAdmin,
      role: role,
    );
  }

  /// Copia con modifiche
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAdmin,
    String? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
    );
  }

  /// Verifica se l'utente è un professionista
  bool get isPro => role == 'pro' || role == 'admin';

  /// Verifica se l'utente è un owner (proprietario animali)
  bool get isOwner => role == 'owner' || role == 'admin';

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, role: $role, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.isAdmin == isAdmin &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ isAdmin.hashCode ^ role.hashCode;
  }
}
