import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// 🔐 AuthService
/// 
/// Servizio centralizzato per autenticazione e gestione custom claims
/// Include supporto per ruolo admin tramite Firebase Auth custom claims

class AuthService {
  final _auth = FirebaseAuth.instance;

  /// Stream dell'utente corrente Firebase
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Ottieni l'utente Firebase corrente (null se non autenticato)
  User? get currentFirebaseUser => _auth.currentUser;

  /// Carica AppUser completo con custom claims
  /// 
  /// IMPORTANTE: Questa funzione legge i custom claims da Firebase Auth
  /// per determinare se l'utente ha privilegi admin.
  /// 
  /// Ritorna null se l'utente non è autenticato
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Force refresh per ottenere claims aggiornati
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims ?? {};

      return AppUser.fromFirebase(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        claims: claims,
      );
    } catch (e) {
      throw Exception('Errore nel caricamento claims utente: $e');
    }
  }

  /// Ricarica i custom claims (da chiamare dopo promozione admin)
  /// 
  /// NOTA: Quando un utente viene promosso ad admin tramite lo script
  /// setAdmin.ts, deve fare logout/login OPPURE chiamare questa funzione
  /// per ricaricare i claims aggiornati
  Future<void> refreshClaims() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Force reload del token con force=true
    await user.getIdTokenResult(true);
  }

  /// Login con email e password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registrazione con email e password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Reset password
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Ottieni ID token corrente (per chiamate API backend)
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }
}
