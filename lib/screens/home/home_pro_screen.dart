import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/gdpr_actions.dart';
import '../../services/auth_service.dart';
import '../../models/app_user.dart';

class HomeProScreen extends StatefulWidget {
  static const routeName = '/homePro';

  const HomeProScreen({super.key});

  @override
  State<HomeProScreen> createState() => _HomeProScreenState();
}

class _HomeProScreenState extends State<HomeProScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _ProCalendarScreen(),   // calendario / slot
      const _ProBookingsScreen(),   // prenotazioni
      const _ProProfileScreen(),    // profilo studio
      const _ProSubscriptionTab(),  // abbonamento
    ];

    return Scaffold(
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Prenotazioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Profilo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Abbonamento',
          ),
        ],
      ),
    );
  }
}

class _ProCalendarScreen extends StatelessWidget {
  const _ProCalendarScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/my_pet_care_app_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Calendario Disponibilità'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Aggiungi slot disponibilità
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aggiungi slot - TODO')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 64, color: Color(0xFF0F6259)),
            const SizedBox(height: 16),
            const Text(
              'Gestione Calendario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Qui gestirai i tuoi slot di disponibilità, i lock (periodi non disponibili) e vedrai le prenotazioni confermate.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Collega al tuo widget calendario esistente
              },
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Gestisci Disponibilità'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBookingsScreen extends StatelessWidget {
  const _ProBookingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/my_pet_care_app_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Prenotazioni'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filtri prenotazioni (pending, confirmed, completed)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtri prenotazioni - TODO')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, size: 64, color: Color(0xFF0F6259)),
            const SizedBox(height: 16),
            const Text(
              'Le Tue Prenotazioni',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Qui vedrai tutte le prenotazioni ricevute dai clienti, con possibilità di confermare, rifiutare o completare.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Collega al tuo widget lista bookings esistente
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Carica Prenotazioni'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProProfileScreen extends StatefulWidget {
  const _ProProfileScreen();

  @override
  State<_ProProfileScreen> createState() => _ProProfileScreenState();
}

class _ProProfileScreenState extends State<_ProProfileScreen> {
  final _authService = AuthService();
  AppUser? _currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/my_pet_care_app_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Profilo Professionista'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Modifica profilo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modifica profilo - TODO')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.business, size: 50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nome Studio',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Veterinario • Milano',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text('4.8 (127 recensioni)'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Servizi Offerti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildServiceTile('Visita generale', '€40'),
            _buildServiceTile('Vaccinazioni', '€30'),
            _buildServiceTile('Microchip', '€25'),
            const SizedBox(height: 24),
            const Text(
              'Informazioni Studio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(Icons.location_on, 'Via Roma 123, Milano'),
            _buildInfoTile(Icons.phone, '+39 02 1234567'),
            _buildInfoTile(Icons.email, 'info@studiovetenginario.it'),
            _buildInfoTile(Icons.schedule, 'Lun-Ven: 9:00-19:00'),
            const SizedBox(height: 24),
            const Text(
              'Statistiche',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('47', 'Prenotazioni\nMese corrente'),
                _buildStatCard('4.8', 'Rating\nMedio'),
                _buildStatCard('127', 'Recensioni\nTotali'),
              ],
            ),
            const SizedBox(height: 16),
            
            // 🛡️ ADMIN PANEL - Solo se utente ha admin=true
            if (_currentUser?.isAdmin == true)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF0F6259)),
                  title: const Text(
                    'Pannello amministrativo',
                    style: TextStyle(
                      color: Color(0xFF0F6259),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF0F6259)),
                  onTap: () {
                    context.go('/admin');
                  },
                ),
              ),
            
            // Widget GDPR (Export dati + Cancellazione account)
            const GdprActionsWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTile(String name, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medical_services, color: Color(0xFF0F6259)),
        title: Text(name),
        trailing: Text(
          price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F6259),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 2,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6259),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProSubscriptionTab extends StatelessWidget {
  const _ProSubscriptionTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/my_pet_care_app_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Il Tuo Abbonamento'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFFE0F2F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Piano PRO',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeature('✓ Visibilità in mappa'),
                    _buildFeature('✓ Gestione calendario e slot'),
                    _buildFeature('✓ Prenotazioni illimitate'),
                    _buildFeature('✓ Profilo completo con foto e servizi'),
                    _buildFeature('✓ Sistema di recensioni'),
                    _buildFeature('✓ Notifiche in tempo reale'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Stato:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text('ATTIVO'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Prossimo rinnovo: 15 Febbraio 2024'),
                    const Text('Importo: €29,99/mese'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gestisci Abbonamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Metodo di pagamento'),
              subtitle: const Text('Visa •••• 4242'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Modifica metodo pagamento
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modifica pagamento - TODO')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Fatture'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Visualizza storico fatture
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fatture - TODO')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancella abbonamento'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Dialog conferma cancellazione
                _showCancelDialog(context);
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Link a pagina FAQ abbonamenti
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FAQ abbonamenti - TODO')),
                  );
                },
                child: const Text('Hai domande sull\'abbonamento?'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancellare abbonamento?'),
        content: const Text(
          'Sei sicuro di voler cancellare l\'abbonamento PRO? '
          'Perderai accesso a tutte le funzionalità professionali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Cancella abbonamento
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cancellazione abbonamento - TODO'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Conferma Cancellazione'),
          ),
        ],
      ),
    );
  }
}
