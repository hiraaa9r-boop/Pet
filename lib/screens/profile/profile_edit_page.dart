import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ✏️ ProfileEditPage
/// 
/// Form completo per modificare il profilo utente con:
/// - Nome e cognome
/// - Telefono
/// - Indirizzo
/// - Bio (per PRO)
/// - Servizi offerti (per PRO)
/// - Validazione campi
/// - Firestore update

class ProfileEditPage extends StatefulWidget {
  final bool isPro;
  final Map<String, dynamic>? currentData;

  const ProfileEditPage({
    super.key,
    required this.isPro,
    this.currentData,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  bool _loading = false;
  Set<String> _selectedServices = {};

  // Servizi disponibili per PRO
  final List<String> _availableServices = [
    'Veterinario',
    'Toelettatore',
    'Pet Sitter',
    'Educatore',
    'Pensione',
    'Dog Walker',
    'Addestratore',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    if (widget.currentData != null) {
      final data = widget.currentData!;
      _nameController.text = data['name'] as String? ?? '';
      _surnameController.text = data['surname'] as String? ?? '';
      _phoneController.text = data['phone'] as String? ?? '';
      _addressController.text = data['address'] as String? ?? '';
      _bioController.text = data['bio'] as String? ?? '';

      // Carica servizi se è PRO
      if (widget.isPro && data['services'] is List) {
        _selectedServices = Set<String>.from(
          (data['services'] as List).map((e) => e.toString()),
        );
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefono è obbligatorio';
    }
    // Regex base per telefono italiano
    final phoneRegex = RegExp(r'^[+]?[\d\s()-]{8,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Formato telefono non valido';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validazione servizi per PRO
    if (widget.isPro && _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un servizio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utente non autenticato');

      // Prepara dati da salvare
      final data = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Aggiungi campi specifici PRO
      if (widget.isPro) {
        data['bio'] = _bioController.text.trim();
        data['services'] = _selectedServices.toList();
        data['businessName'] = '${_nameController.text.trim()} ${_surnameController.text.trim()}';
      }

      // Salva su Firestore
      final collection = widget.isPro ? 'pros' : 'users';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profilo aggiornato con successo'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Passa true per indicare successo
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore salvataggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo'),
        actions: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info header
            Card(
              color: const Color(0xFF0F6259).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      widget.isPro ? Icons.business : Icons.person,
                      size: 40,
                      color: const Color(0xFF0F6259),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.isPro
                            ? 'Profilo Professionista'
                            : 'Profilo Utente',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sezione Informazioni Personali
            const Text(
              'Informazioni Personali',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6259),
              ),
            ),
            const SizedBox(height: 12),

            // Nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateRequired(value, 'Nome'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Cognome
            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(
                labelText: 'Cognome',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateRequired(value, 'Cognome'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Telefono
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefono',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '+39 123 456 7890',
              ),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),

            // Indirizzo
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Indirizzo',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateRequired(value, 'Indirizzo'),
              maxLines: 2,
            ),

            // Sezione specifica PRO
            if (widget.isPro) ...[
              const SizedBox(height: 32),
              const Text(
                'Informazioni Professionali',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F6259),
                ),
              ),
              const SizedBox(height: 12),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Biografia',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  hintText: 'Presentati ai tuoi clienti...',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
                validator: (value) => _validateRequired(value, 'Biografia'),
              ),
              const SizedBox(height: 24),

              // Servizi offerti
              const Text(
                'Servizi Offerti',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Seleziona almeno un servizio',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableServices.map((service) {
                  final isSelected = _selectedServices.contains(service);
                  return FilterChip(
                    label: Text(service),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedServices.add(service);
                        } else {
                          _selectedServices.remove(service);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF0F6259).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF0F6259),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF0F6259)
                          : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            // Pulsante salva
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _loading ? null : _saveProfile,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_loading ? 'Salvataggio...' : 'Salva Modifiche'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6259),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info ultimo aggiornamento
            if (widget.currentData?['updatedAt'] != null)
              Center(
                child: Text(
                  'Ultimo aggiornamento: ${_formatTimestamp(widget.currentData!['updatedAt'] as Timestamp)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
