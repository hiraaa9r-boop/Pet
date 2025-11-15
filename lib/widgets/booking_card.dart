import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// 📅 BookingCard
/// 
/// Card per visualizzare una singola prenotazione con:
/// - Dettagli cliente e servizio
/// - Data e ora
/// - Status (pending, confirmed, completed, cancelled)
/// - Azioni (conferma, rifiuta, completa, cancella)

class BookingCard extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;
  final VoidCallback? onRefresh;

  const BookingCard({
    super.key,
    required this.bookingId,
    required this.bookingData,
    this.onRefresh,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'In attesa';
      case 'confirmed':
        return 'Confermata';
      case 'completed':
        return 'Completata';
      case 'cancelled':
        return 'Cancellata';
      case 'rejected':
        return 'Rifiutata';
      default:
        return 'Sconosciuto';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _updateBookingStatus(
    BuildContext context,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prenotazione ${_getStatusLabel(newStatus).toLowerCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      onRefresh?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore aggiornamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    String newStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus(context, newStatus);
            },
            style: FilledButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
            ),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = bookingData['status'] as String? ?? 'pending';
    final clientName = bookingData['clientName'] as String? ?? 'Cliente';
    final clientEmail = bookingData['clientEmail'] as String? ?? '';
    final service = bookingData['service'] as String? ?? 'Servizio';
    final dayId = bookingData['dayId'] as String? ?? '';
    final timeSlot = bookingData['timeSlot'] as String? ?? '';
    final notes = bookingData['notes'] as String?;
    final createdAt = bookingData['createdAt'] as Timestamp?;

    // Formatta data
    String formattedDate = dayId;
    if (dayId.isNotEmpty) {
      try {
        final parts = dayId.split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          formattedDate = DateFormat('EEEE d MMMM yyyy', 'it_IT').format(date);
        }
      } catch (e) {
        // Keep original dayId if parsing fails
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Cliente e Status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0F6259),
                  child: Text(
                    clientName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (clientEmail.isNotEmpty)
                        Text(
                          clientEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: _getStatusColor(status),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const Divider(height: 24),

            // Dettagli prenotazione
            _DetailRow(
              icon: Icons.medical_services,
              label: 'Servizio',
              value: service,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Data',
              value: formattedDate,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Ora',
              value: timeSlot,
            ),

            // Note (se presenti)
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.black54),
                        SizedBox(width: 8),
                        Text(
                          'Note cliente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notes,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Data creazione
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Richiesta il ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate())}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black38,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Azioni basate su status
            const SizedBox(height: 16),
            _buildActions(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        // Prenotazione in attesa: mostra Conferma e Rifiuta
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showConfirmDialog(
                  context,
                  'Rifiuta prenotazione',
                  'Sei sicuro di voler rifiutare questa prenotazione?',
                  'rejected',
                ),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Rifiuta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _showConfirmDialog(
                  context,
                  'Conferma prenotazione',
                  'Confermi di accettare questa prenotazione?',
                  'confirmed',
                ),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Conferma'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        );

      case 'confirmed':
        // Prenotazione confermata: mostra Completa e Cancella
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showConfirmDialog(
                  context,
                  'Cancella prenotazione',
                  'Vuoi cancellare questa prenotazione?',
                  'cancelled',
                ),
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Cancella'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _showConfirmDialog(
                  context,
                  'Completa prenotazione',
                  'Il servizio è stato completato?',
                  'completed',
                ),
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Completa'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6259),
                ),
              ),
            ),
          ],
        );

      case 'completed':
      case 'cancelled':
      case 'rejected':
        // Status finali: nessuna azione
        return Center(
          child: Text(
            status == 'completed'
                ? '✓ Servizio completato'
                : status == 'cancelled'
                    ? '✗ Prenotazione cancellata'
                    : '✗ Prenotazione rifiutata',
            style: TextStyle(
              fontSize: 14,
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F6259)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
