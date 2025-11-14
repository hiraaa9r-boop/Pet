import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pro_subscription.dart';

/// Widget che protegge le funzionalità PRO verificando lo stato dell'abbonamento
/// Se l'abbonamento non è attivo, reindirizza alla pagina di sottoscrizione
class ProSubscriptionGuard extends StatefulWidget {
  final Widget child;
  final ProSubscription? subscription;
  final bool showLoadingOnRedirect;

  const ProSubscriptionGuard({
    super.key,
    required this.child,
    required this.subscription,
    this.showLoadingOnRedirect = true,
  });

  @override
  State<ProSubscriptionGuard> createState() => _ProSubscriptionGuardState();
}

class _ProSubscriptionGuardState extends State<ProSubscriptionGuard> {
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  @override
  void didUpdateWidget(ProSubscriptionGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subscription != widget.subscription) {
      _checkSubscription();
    }
  }

  void _checkSubscription() {
    // Se l'abbonamento è nullo o non attivo, reindirizza
    if (widget.subscription == null || !widget.subscription!.isActive) {
      if (!_hasRedirected && mounted) {
        _hasRedirected = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/subscribe');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se l'abbonamento è attivo, mostra il contenuto
    if (widget.subscription != null && widget.subscription!.isActive) {
      return widget.child;
    }

    // Altrimenti mostra un loading placeholder
    if (widget.showLoadingOnRedirect) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verifica abbonamento...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Widget informativo per mostrare lo stato dell'abbonamento
class SubscriptionStatusCard extends StatelessWidget {
  final ProSubscription subscription;
  final VoidCallback? onManageSubscription;

  const SubscriptionStatusCard({
    super.key,
    required this.subscription,
    this.onManageSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determina il colore in base allo stato
    Color statusColor;
    IconData statusIcon;
    
    if (subscription.isActive) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (subscription.isPastDue) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abbonamento PRO',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscription.statusDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Dettagli piano
            _buildDetailRow(
              context,
              'Piano',
              subscription.planDescription,
            ),
            
            if (subscription.currentPeriodEnd != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                'Scadenza',
                _formatDate(subscription.currentPeriodEnd!),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                'Giorni rimanenti',
                '${subscription.daysRemaining} giorni',
              ),
            ],
            
            if (subscription.lastPaymentAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                'Ultimo pagamento',
                _formatDate(subscription.lastPaymentAt!),
              ),
            ],
            
            if (subscription.cancelAtPeriodEnd) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Abbonamento in cancellazione alla scadenza',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (onManageSubscription != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onManageSubscription,
                  icon: const Icon(Icons.settings),
                  label: const Text('Gestisci Abbonamento'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
