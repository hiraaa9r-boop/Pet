import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'subscribe_page.dart';

/// Wrapper per la pagina di abbonamento PRO
/// Usa il proId dell'utente corrente autenticato
class SubscriptionScreen extends StatelessWidget {
  static const String routeName = '/subscribe';
  
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ottieni l'ID utente corrente da Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Se non c'è utente autenticato, mostra errore
      return Scaffold(
        appBar: AppBar(title: const Text('Abbonamento')),
        body: const Center(
          child: Text('Errore: Utente non autenticato'),
        ),
      );
    }
    
    // Passa il proId a SubscribePage
    return SubscribePage(proId: user.uid);
  }
}
