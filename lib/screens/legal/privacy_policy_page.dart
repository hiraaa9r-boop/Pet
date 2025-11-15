import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ultimo aggiornamento: ${DateTime.now().year}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Informazioni che raccogliamo',
              'My Pet Care raccoglie le seguenti informazioni:\n\n'
              '• Informazioni personali (nome, email, telefono)\n'
              '• Informazioni sui tuoi animali domestici\n'
              '• Informazioni sugli appuntamenti e prenotazioni\n'
              '• Dati di utilizzo dell\'app\n'
              '• Posizione geografica (con il tuo consenso)',
            ),
            
            _buildSection(
              'Come utilizziamo le tue informazioni',
              'Utilizziamo le tue informazioni per:\n\n'
              '• Fornire e migliorare i nostri servizi\n'
              '• Gestire appuntamenti e prenotazioni\n'
              '• Comunicare con te riguardo ai servizi\n'
              '• Personalizzare la tua esperienza\n'
              '• Garantire la sicurezza dell\'app',
            ),
            
            _buildSection(
              'Condivisione delle informazioni',
              'Non vendiamo le tue informazioni personali a terze parti. '
              'Condividiamo le tue informazioni solo con:\n\n'
              '• Professionisti veterinari con cui prenoti appuntamenti\n'
              '• Provider di servizi che ci aiutano a operare l\'app\n'
              '• Autorità legali quando richiesto dalla legge',
            ),
            
            _buildSection(
              'Sicurezza dei dati',
              'Implementiamo misure di sicurezza tecniche e organizzative '
              'per proteggere le tue informazioni personali contro accessi '
              'non autorizzati, perdita o distruzione.',
            ),
            
            _buildSection(
              'I tuoi diritti (GDPR)',
              'Ai sensi del Regolamento (UE) 2016/679 (GDPR), hai il diritto di:\n\n'
              '• Accedere alle tue informazioni personali (Art. 15)\n'
              '• Correggere informazioni inesatte o incomplete (Art. 16)\n'
              '• Richiedere la cancellazione dei tuoi dati (Art. 17)\n'
              '• Opporti al trattamento dei tuoi dati (Art. 21)\n'
              '• Richiedere la portabilità dei dati (Art. 20)\n'
              '• Ritirare il consenso in qualsiasi momento\n'
              '• Proporre reclamo all\'Autorità Garante per la protezione dei dati personali',
            ),
            
            _buildSection(
              'Accesso, portabilità e cancellazione dei dati',
              'L\'Utente può in qualsiasi momento:\n\n'
              '• Richiedere conferma che sia in corso un trattamento di dati personali che lo riguardano\n'
              '• Ottenere copia dei dati personali forniti tramite l\'app, in formato elettronico interoperabile (portabilità)\n'
              '• Richiedere la cancellazione del proprio account e dei dati associati, nei limiti consentiti dalla normativa\n\n'
              'Tali diritti possono essere esercitati direttamente dall\'app My Pet Care, tramite l\'apposita funzione '
              '"Scarica i miei dati (GDPR)" e "Richiedi cancellazione account", oppure inviando una richiesta a:\n\n'
              'Email: petcareassistenza@gmail.com',
            ),
            
            _buildSection(
              'Cookie e tecnologie simili',
              'Utilizziamo cookie e tecnologie simili per migliorare '
              'la tua esperienza, analizzare l\'utilizzo dell\'app e '
              'personalizzare i contenuti.',
            ),
            
            _buildSection(
              'Modifiche alla Privacy Policy',
              'Potremmo aggiornare questa Privacy Policy periodicamente. '
              'Ti notificheremo eventuali modifiche importanti tramite '
              'l\'app o via email.',
            ),
            
            _buildSection(
              'Titolare del trattamento e contatti',
              'Titolare del trattamento: My Pet Care\n'
              'Email: petcareassistenza@gmail.com\n\n'
              'Per domande sulla Privacy Policy, sull\'esercizio dei tuoi diritti GDPR, '
              'o per richiedere informazioni sul trattamento dei tuoi dati personali, '
              'puoi contattarci all\'indirizzo email sopra indicato.\n\n'
              'Autorità di controllo:\n'
              'Garante per la protezione dei dati personali\n'
              'www.garanteprivacy.it',
            ),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ho Capito'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
