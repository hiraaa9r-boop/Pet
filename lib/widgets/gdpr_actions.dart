import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../config.dart';

/// Widget per le azioni GDPR (Export dati + Cancellazione account)
/// Da inserire nella sezione Impostazioni del profilo utente
class GdprActionsWidget extends StatelessWidget {
  const GdprActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 32),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Gestione Dati Personali (GDPR)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F6259),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.download, color: Color(0xFF0F6259)),
          title: const Text('Scarica i miei dati (GDPR)'),
          subtitle: const Text('Esporta tutti i tuoi dati personali'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _exportGdprData(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Richiedi cancellazione account',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Elimina permanentemente il tuo account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _requestAccountDeletion(context),
        ),
      ],
    );
  }

  /// Export dati utente (GDPR Art. 15, 20)
  Future<void> _exportGdprData(BuildContext context) async {
    // Ottieni token autenticazione
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore: Utente non autenticato')),
        );
      }
      return;
    }

    final token = await user.getIdToken();

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F6259)),
        ),
      ),
    );

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.backendBaseUrl}/api/gdpr/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Chiudi loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Mostra dialog con dati esportati
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.download, color: Color(0xFF0F6259)),
                SizedBox(width: 8),
                Text('Dati Esportati'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'I tuoi dati sono stati esportati con successo in formato JSON.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      const JsonEncoder.withIndent('  ').convert(data),
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '💡 Puoi copiare questi dati o salvarli su un file.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Export failed: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Chiudi loading se ancora aperto
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Cancellazione account (GDPR Art. 17)
  Future<void> _requestAccountDeletion(BuildContext context) async {
    // Dialog di conferma
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Conferma cancellazione account'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sei sicuro di voler cancellare il tuo account?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Questa azione:'),
              SizedBox(height: 8),
              Text('• Disabiliterà il tuo account'),
              Text('• Anonimizzerà i tuoi dati personali'),
              Text('• È irreversibile'),
              SizedBox(height: 16),
              Text(
                'Alcuni dati saranno conservati per obblighi legali (prenotazioni, transazioni) in forma anonimizzata.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Conferma Cancellazione'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Ottieni token autenticazione
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore: Utente non autenticato')),
        );
      }
      return;
    }

    final token = await user.getIdToken();

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ),
    );

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.backendBaseUrl}/api/gdpr/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Chiudi loading

      if (response.statusCode == 200) {
        // Logout e vai a login screen
        await FirebaseAuth.instance.signOut();
        
        if (context.mounted) {
          context.go('/login');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account cancellato con successo'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('Deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Chiudi loading se ancora aperto
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante la cancellazione: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
