import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config.dart';

/// 🛡️ AdminHomeScreen
/// 
/// Pannello amministrativo accessibile solo agli utenti con custom claim admin=true
/// 
/// Funzionalità:
/// - Visualizza statistiche generali (PRO attivi, owner, prenotazioni)
/// - Lista PRO in attesa di approvazione
/// - Approva/Rifiuta professionisti
/// - Gestione coupons (da implementare)

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _loading = true;
  Map<String, dynamic>? _stats;
  List<dynamic> _pendingPros = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utente non autenticato');
      }

      final token = await user.getIdToken();
      if (token == null) {
        throw Exception('Token non disponibile');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Chiamate API parallele
      final results = await Future.wait([
        http.get(
          Uri.parse('${AppConfig.backendBaseUrl}/api/admin/stats'),
          headers: headers,
        ),
        http.get(
          Uri.parse('${AppConfig.backendBaseUrl}/api/admin/pros/pending'),
          headers: headers,
        ),
      ]);

      final statsRes = results[0];
      final prosRes = results[1];

      // Verifica errori HTTP
      if (statsRes.statusCode >= 400) {
        throw Exception(
            'Errore stats API: ${statsRes.statusCode} - ${statsRes.body}');
      }
      if (prosRes.statusCode >= 400) {
        throw Exception(
            'Errore pros API: ${prosRes.statusCode} - ${prosRes.body}');
      }

      setState(() {
        _stats = jsonDecode(statsRes.body) as Map<String, dynamic>;
        _pendingPros = jsonDecode(prosRes.body) as List<dynamic>;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeProStatus(String proId, String status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${AppConfig.backendBaseUrl}/api/admin/pros/$proId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode >= 400) {
        throw Exception('Errore API: ${response.body}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'PRO approvato con successo!'
                  : 'PRO rifiutato',
            ),
            backgroundColor:
                status == 'approved' ? Colors.green : Colors.orange,
          ),
        );
      }

      // Ricarica dati
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pannello amministrativo'),
        backgroundColor: const Color(0xFF0F6259),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Errore: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ====== STATISTICHE ======
                      if (_stats != null) _buildStatsCard(),

                      const SizedBox(height: 24),

                      // ====== PRO IN ATTESA ======
                      Text(
                        'PRO in attesa di approvazione',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F6259),
                            ),
                      ),
                      const SizedBox(height: 12),

                      if (_pendingPros.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Nessun professionista in attesa.',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._pendingPros.map((p) {
                          final map = p as Map<String, dynamic>;
                          return _buildPendingProCard(map);
                        }).toList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: const Color(0xFF0F6259)),
                const SizedBox(width: 8),
                Text(
                  'Statistiche',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F6259),
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildStatRow(
              Icons.work,
              'PRO totali',
              '${_stats!['totalPros'] ?? 0}',
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.verified,
              'PRO attivi',
              '${_stats!['activePros'] ?? 0}',
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.calendar_today,
              'Prenotazioni totali',
              '${_stats!['totalBookings'] ?? 0}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F6259),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingProCard(Map<String, dynamic> pro) {
    final displayName = pro['displayName'] ?? pro['businessName'] ?? 'N/A';
    final email = pro['email'] ?? 'Email non disponibile';
    final id = pro['id'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icona PRO
            CircleAvatar(
              backgroundColor: const Color(0xFF0F6259).withValues(alpha: 0.1),
              child: const Icon(
                Icons.business,
                color: Color(0xFF0F6259),
              ),
            ),
            const SizedBox(width: 12),

            // Info PRO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Azioni
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Rifiuta',
                  onPressed: () => _changeProStatus(id, 'disabled'),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  tooltip: 'Approva',
                  onPressed: () => _changeProStatus(id, 'approved'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
