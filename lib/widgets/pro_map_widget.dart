import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pro_model.dart';

/// 🗺️ ProMapWidget
/// 
/// Widget per visualizzare i professionisti sulla mappa con:
/// - Marker per ogni PRO attivo
/// - Info window con dettagli
/// - Filtri per servizi e distanza
/// - Geolocation dell'utente

class ProMapWidget extends StatefulWidget {
  const ProMapWidget({super.key});

  @override
  State<ProMapWidget> createState() => _ProMapWidgetState();
}

class _ProMapWidgetState extends State<ProMapWidget> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  Set<Marker> _markers = {};
  List<ProModel> _allPros = [];
  List<ProModel> _filteredPros = [];
  bool _loading = true;
  String? _selectedService;
  double _maxDistance = 50.0; // km

  // Servizi disponibili per filtro
  final List<String> _services = [
    'Tutti',
    'Veterinario',
    'Toelettatore',
    'Pet Sitter',
    'Educatore',
    'Pensione',
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _loading = true);

    try {
      // 1. Richiedi permessi geolocalizzazione
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Ottieni posizione utente
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      // 3. Carica PRO attivi da Firestore
      await _loadPros();
    } catch (e) {
      debugPrint('Errore inizializzazione mappa: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadPros() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pros')
          .where('status', isEqualTo: 'approved')
          .where('subscriptionStatus', isEqualTo: 'active')
          .get();

      _allPros = snapshot.docs
          .map((doc) => ProModel.fromFirestore(doc.data(), doc.id))
          .where((pro) => pro.latitude != null && pro.longitude != null)
          .toList();

      _applyFilters();
    } catch (e) {
      debugPrint('Errore caricamento PRO: $e');
    }
  }

  void _applyFilters() {
    List<ProModel> filtered = List.from(_allPros);

    // Filtro per servizio
    if (_selectedService != null && _selectedService != 'Tutti') {
      filtered = filtered.where((pro) {
        return pro.services?.contains(_selectedService) ?? false;
      }).toList();
    }

    // Filtro per distanza (se abbiamo posizione utente)
    if (_userPosition != null) {
      filtered = filtered.where((pro) {
        final distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          pro.latitude!,
          pro.longitude!,
        );
        return (distance / 1000) <= _maxDistance; // Converti in km
      }).toList();
    }

    setState(() {
      _filteredPros = filtered;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    _markers = _filteredPros.map((pro) {
      return Marker(
        markerId: MarkerId(pro.id),
        position: LatLng(pro.latitude!, pro.longitude!),
        infoWindow: InfoWindow(
          title: pro.name ?? 'Professionista',
          snippet: pro.services?.join(', ') ?? 'Servizi',
          onTap: () => _showProDetails(pro),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColor(pro.services?.first),
        ),
      );
    }).toSet();

    // Aggiungi marker posizione utente
    if (_userPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'La tua posizione'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }
  }

  double _getMarkerColor(String? service) {
    switch (service) {
      case 'Veterinario':
        return BitmapDescriptor.hueRed;
      case 'Toelettatore':
        return BitmapDescriptor.hueBlue;
      case 'Pet Sitter':
        return BitmapDescriptor.hueGreen;
      case 'Educatore':
        return BitmapDescriptor.hueOrange;
      case 'Pensione':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRose;
    }
  }

  void _showProDetails(ProModel pro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome e rating
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF0F6259),
                    child: Text(
                      pro.name?.substring(0, 1).toUpperCase() ?? 'P',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pro.name ?? 'Professionista',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              pro.rating?.toStringAsFixed(1) ?? '5.0',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${pro.reviewCount ?? 0} recensioni)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Servizi
              const Text(
                'Servizi offerti',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (pro.services ?? []).map((service) {
                  return Chip(
                    label: Text(service),
                    backgroundColor: const Color(0xFF0F6259).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF0F6259)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Bio
              if (pro.bio != null) ...[
                const Text(
                  'Descrizione',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  pro.bio!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
              ],

              // Distanza (se disponibile)
              if (_userPosition != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: Color(0xFF0F6259)),
                    const SizedBox(width: 8),
                    Text(
                      '${_calculateDistance(pro).toStringAsFixed(1)} km di distanza',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Pulsante prenotazione
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Naviga a pagina prenotazione
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Prenotazione con ${pro.name} - TODO'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Prenota Servizio'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0F6259),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDistance(ProModel pro) {
    if (_userPosition == null || pro.latitude == null || pro.longitude == null) {
      return 0.0;
    }
    final distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      pro.latitude!,
      pro.longitude!,
    );
    return distance / 1000; // km
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtri',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Filtro servizio
              const Text('Tipo di servizio', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: _services.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() => _selectedService = value);
                },
              ),
              const SizedBox(height: 24),

              // Filtro distanza
              Text(
                'Distanza massima: ${_maxDistance.toStringAsFixed(0)} km',
                style: const TextStyle(fontSize: 16),
              ),
              Slider(
                value: _maxDistance,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${_maxDistance.toStringAsFixed(0)} km',
                activeColor: const Color(0xFF0F6259),
                onChanged: (value) {
                  setModalState(() => _maxDistance = value);
                },
              ),
              const SizedBox(height: 24),

              // Pulsanti
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedService = null;
                          _maxDistance = 50.0;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F6259),
                      ),
                      child: const Text('Applica'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Caricamento mappa...'),
          ],
        ),
      );
    }

    // Determina posizione iniziale camera
    final initialPosition = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : const LatLng(41.9028, 12.4964); // Roma di default

    return Stack(
      children: [
        // Mappa
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 12,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          padding: const EdgeInsets.only(top: 80, bottom: 100),
        ),

        // Header con contatore e filtri
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_filteredPros.length} professionisti trovati',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilters,
                    color: const Color(0xFF0F6259),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
