import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termini di Servizio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Termini di Servizio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ultimo aggiornamento: ${DateTime.now().year}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              '1. Accettazione dei Termini',
              'Utilizzando l\'app My Pet Care, accetti di essere vincolato '
              'da questi Termini di Servizio. Se non accetti questi termini, '
              'non utilizzare l\'app.',
            ),
            
            _buildSection(
              '2. Descrizione del Servizio',
              'My Pet Care è una piattaforma che connette proprietari di '
              'animali domestici con professionisti veterinari e servizi '
              'per animali. Forniamo:\n\n'
              '• Prenotazione di appuntamenti\n'
              '• Gestione dei profili degli animali\n'
              '• Comunicazione con professionisti\n'
              '• Registri sanitari e vaccinazioni',
            ),
            
            _buildSection(
              '3. Registrazione e Account',
              'Per utilizzare i nostri servizi, devi:\n\n'
              '• Fornire informazioni accurate e complete\n'
              '• Mantenere la sicurezza della tua password\n'
              '• Notificarci immediatamente di qualsiasi uso non autorizzato\n'
              '• Essere responsabile di tutte le attività sul tuo account',
            ),
            
            _buildSection(
              '4. Uso Accettabile',
              'Ti impegni a NON:\n\n'
              '• Violare leggi o regolamenti\n'
              '• Pubblicare contenuti offensivi o inappropriati\n'
              '• Interferire con il funzionamento dell\'app\n'
              '• Utilizzare l\'app per scopi commerciali non autorizzati\n'
              '• Impersonare altre persone o entità',
            ),
            
            _buildSection(
              '5. Prenotazioni e Pagamenti',
              'Le prenotazioni sono soggette a disponibilità. I pagamenti '
              'devono essere effettuati secondo i termini concordati con il '
              'professionista. Le politiche di cancellazione variano per '
              'ogni professionista.',
            ),
            
            _buildSection(
              '6. Responsabilità dei Professionisti',
              'I professionisti veterinari sono responsabili per:\n\n'
              '• La qualità dei loro servizi\n'
              '• Il rispetto delle normative professionali\n'
              '• La gestione delle loro disponibilità\n'
              '• La comunicazione con i clienti',
            ),
            
            _buildSection(
              '7. Limitazione di Responsabilità',
              'My Pet Care non è responsabile per:\n\n'
              '• La qualità dei servizi forniti dai professionisti\n'
              '• Eventuali danni derivanti dall\'uso dell\'app\n'
              '• Interruzioni o errori nel servizio\n'
              '• Perdita di dati o informazioni',
            ),
            
            _buildSection(
              '8. Proprietà Intellettuale',
              'Tutti i contenuti dell\'app (design, logo, testi, immagini) '
              'sono di proprietà di My Pet Care e protetti da copyright. '
              'Non puoi copiare, modificare o distribuire questi contenuti '
              'senza autorizzazione.',
            ),
            
            _buildSection(
              '9. Modifiche ai Termini',
              'Ci riserviamo il diritto di modificare questi termini in '
              'qualsiasi momento. Ti notificheremo le modifiche importanti '
              'tramite l\'app o via email. L\'uso continuato dell\'app dopo '
              'le modifiche costituisce accettazione dei nuovi termini.',
            ),
            
            _buildSection(
              '10. Account, sospensione e cancellazione',
              'L\'Utente può richiedere in qualsiasi momento:\n\n'
              '• La cancellazione del proprio account\n'
              '• L\'accesso e l\'esportazione dei dati associati all\'account\n\n'
              'La richiesta può essere effettuata:\n\n'
              '• Tramite le funzioni disponibili nell\'app My Pet Care '
              '("Scarica i miei dati (GDPR)" e "Richiedi cancellazione account")\n'
              '• Oppure tramite email a petcareassistenza@gmail.com\n\n'
              'In caso di cancellazione, alcuni dati relativi alle transazioni '
              'e alle prenotazioni potranno essere conservati in forma limitata '
              'e/o anonimizzata per l\'adempimento di obblighi di legge, di natura '
              'contabile o fiscale.\n\n'
              'Ci riserviamo il diritto di sospendere o terminare il tuo account '
              'se violi questi termini o per qualsiasi altro motivo legittimo.',
            ),
            
            _buildSection(
              '11. Legge Applicabile',
              'Questi termini sono regolati dalla legge italiana. Qualsiasi '
              'controversia sarà risolta presso i tribunali competenti in '
              'Italia.',
            ),
            
            _buildSection(
              '12. Contatti',
              'Per domande sui Termini di Servizio, sulla gestione del tuo account '
              'o per richiedere la cancellazione:\n\n'
              'Email: petcareassistenza@gmail.com\n\n'
              'Le richieste di cancellazione account e accesso ai dati (GDPR) '
              'possono essere effettuate direttamente dall\'app tramite le apposite funzioni.',
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
