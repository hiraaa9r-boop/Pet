import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/gdpr_actions.dart';
import '../../services/auth_service.dart';
import '../../models/app_user.dart';

class HomeOwnerScreen extends StatefulWidget {
  static const routeName = '/homeOwner';

  const HomeOwnerScreen({super.key});

  @override
  State<HomeOwnerScreen> createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends State<HomeOwnerScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _OwnerMapScreen(),      // mappa
      const _OwnerListScreen(),     // lista PRO
      const _OwnerProfileScreen(),  // profilo + notifiche
    ];

    return Scaffold(
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mappa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}

// 🔍 Stub mappa (collega poi al tuo widget di Google Maps + filtri)
class _OwnerMapScreen extends StatelessWidget {
  const _OwnerMapScreen();

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
            const Text('Trova Professionisti'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Apri dialog filtri (servizi, distanza, rating)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtri mappa - TODO')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Color(0xFF0F6259)),
            const SizedBox(height: 16),
            const Text(
              'Mappa Professionisti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Qui verrà integrata la tua mappa Google Maps con i marker dei professionisti e i filtri di ricerca.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Collega al tuo widget mappa esistente
              },
              icon: const Icon(Icons.explore),
              label: const Text('Carica Mappa'),
            ),
          ],
        ),
      ),
    );
  }
}

// 📋 Stub lista PRO
class _OwnerListScreen extends StatelessWidget {
  const _OwnerListScreen();

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
            const Text('Lista Professionisti'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementa ricerca/filtri
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ricerca professionisti - TODO')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Color(0xFF0F6259)),
            const SizedBox(height: 16),
            const Text(
              'Lista Professionisti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Qui verrà mostrato l\'elenco dei professionisti con filtri per servizio, distanza, rating e disponibilità.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Collega al tuo widget lista PRO esistente
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Carica Lista'),
            ),
          ],
        ),
      ),
    );
  }
}

// 👤 Stub profilo + notifiche
class _OwnerProfileScreen extends StatefulWidget {
  const _OwnerProfileScreen();

  @override
  State<_OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<_OwnerProfileScreen> {
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
            const Text('Il Mio Profilo'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Mostra notifiche
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifiche - TODO')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nome Utente',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'owner@example.com',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('I Miei Animali'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Naviga a gestione pet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gestione animali - TODO')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Le Mie Prenotazioni'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Naviga a lista prenotazioni
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prenotazioni - TODO')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Preferiti'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Naviga a professionisti preferiti
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferiti - TODO')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Impostazioni'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Naviga a impostazioni
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Impostazioni - TODO')),
                );
              },
            ),
            
            // 🛡️ ADMIN PANEL - Solo se utente ha admin=true
            if (_currentUser?.isAdmin == true)
              ListTile(
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
            
            const SizedBox(height: 8),
            
            // Widget GDPR (Export dati + Cancellazione account)
            const GdprActionsWidget(),
            
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Logout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout - TODO')),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Esci'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
