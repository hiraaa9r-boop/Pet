// lib/screens/admin/admin_dashboard_page.dart
// Dashboard amministratore con statistiche, PRO pending, coupon

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  bool _loading = false;

  Map<String, dynamic>? _stats;
  List<dynamic> _pendingPros = [];
  List<dynamic> _coupons = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse('${AppConfig.effectiveBackendUrl}/api/admin/stats'),
      );
      if (resp.statusCode == 200) {
        setState(() => _stats = jsonDecode(resp.body));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadPendingPros() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse('${AppConfig.effectiveBackendUrl}/api/admin/pros/pending'),
      );
      if (resp.statusCode == 200) {
        setState(() => _pendingPros = jsonDecode(resp.body) as List<dynamic>);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _approvePro(String id) async {
    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse('${AppConfig.effectiveBackendUrl}/api/admin/pros/$id/approve'),
      );
      if (resp.statusCode == 200) {
        await _loadPendingPros();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PRO approvato con successo')),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCoupons() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse('${AppConfig.effectiveBackendUrl}/api/admin/coupons'),
      );
      if (resp.statusCode == 200) {
        setState(() => _coupons = jsonDecode(resp.body) as List<dynamic>);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createCoupon({
    required String code,
    required int monthsFree,
  }) async {
    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse('${AppConfig.effectiveBackendUrl}/api/admin/coupons'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'monthsFree': monthsFree,
        }),
      );
      if (resp.statusCode == 200) {
        await _loadCoupons();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coupon creato con successo')),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildStats() {
    if (_stats == null) {
      return const Center(child: Text('Nessun dato disponibile'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _StatCard(
            label: 'PRO totali',
            value: '${_stats!['totalPros'] ?? '-'}',
          ),
          _StatCard(
            label: 'PRO attivi',
            value: '${_stats!['activePros'] ?? '-'}',
          ),
          _StatCard(
            label: 'Prenotazioni totali',
            value: '${_stats!['totalBookings'] ?? '-'}',
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPros() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'PRO in attesa di approvazione',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadPendingPros,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: _pendingPros.isEmpty
              ? const Center(child: Text('Nessun PRO in attesa'))
              : ListView.builder(
                  itemCount: _pendingPros.length,
                  itemBuilder: (context, index) {
                    final pro = _pendingPros[index] as Map<String, dynamic>;
                    final id = pro['id'] as String;
                    final name = (pro['displayName'] ?? 'Senza nome') as String;
                    final city = (pro['city'] ?? '') as String;

                    return ListTile(
                      title: Text(name),
                      subtitle: Text(city),
                      trailing: ElevatedButton(
                        onPressed: () => _approvePro(id),
                        child: const Text('Approva'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCoupons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Gestione Coupon',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateCouponDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Crea Coupon'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadCoupons,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: _coupons.isEmpty
              ? const Center(child: Text('Nessun coupon disponibile'))
              : ListView.builder(
                  itemCount: _coupons.length,
                  itemBuilder: (context, index) {
                    final c = _coupons[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(c['code'] ?? ''),
                      subtitle: Text(
                          'Mesi gratis: ${c['monthsFree']} • Attivo: ${c['active']}'),
                      trailing: Switch(
                        value: c['active'] ?? false,
                        onChanged: (_) {
                          // TODO: Implementare toggle attivo/disattivo
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateCouponDialog() {
    final codeController = TextEditingController();
    int selectedMonths = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Crea Coupon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Codice coupon',
                  hintText: 'es. FREE-1M',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedMonths,
                decoration: const InputDecoration(labelText: 'Durata'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 mese')),
                  DropdownMenuItem(value: 3, child: Text('3 mesi')),
                  DropdownMenuItem(value: 12, child: Text('12 mesi')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setStateDialog(() => selectedMonths = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _createCoupon(
                    code: codeController.text.trim(),
                    monthsFree: selectedMonths,
                  );
                }
              },
              child: const Text('Crea'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildStats(),
      _buildPendingPros(),
      _buildCoupons(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              if (index == 0) _loadStats();
              if (index == 1) _loadPendingPros();
              if (index == 2) _loadCoupons();
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Statistiche'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.badge),
                label: Text('PRO'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.card_giftcard),
                label: Text('Coupon'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Stack(
              children: [
                pages[_selectedIndex],
                if (_loading)
                  Container(
                    color: Colors.black.withOpacity(0.05),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 180,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
