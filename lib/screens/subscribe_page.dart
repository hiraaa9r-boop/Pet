// lib/screens/subscribe_page.dart
// Pagina abbonamento PRO con Stripe e PayPal

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

class SubscribePage extends StatefulWidget {
  final String proId;

  const SubscribePage({super.key, required this.proId});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  bool _loading = false;

  Future<void> _startStripeCheckout() async {
    try {
      setState(() => _loading = true);

      final resp = await http.post(
        Uri.parse('${AppConfig.effectiveBackendUrl}/api/payments/stripe/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'proId': widget.proId,
          'priceId': AppConfig.stripeMonthlyPriceId,
          'successUrl': '${AppConfig.effectiveWebUrl}/subscribe/success',
          'cancelUrl': '${AppConfig.effectiveWebUrl}/subscribe/cancel',
        }),
      );

      if (resp.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore avvio pagamento Stripe')),
          );
        }
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final url = data['url'] as String?;

      if (url == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL checkout mancante')),
          );
        }
        return;
      }

      // Apri browser esterno per checkout Stripe
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startPayPalCheckout() async {
    try {
      setState(() => _loading = true);

      final resp = await http.post(
        Uri.parse(
            '${AppConfig.effectiveBackendUrl}/api/payments/paypal/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'proId': widget.proId,
          'amount': '9.99', // Allineare al piano reale
          'returnUrl': '${AppConfig.effectiveWebUrl}/subscribe/success',
          'cancelUrl': '${AppConfig.effectiveWebUrl}/subscribe/cancel',
        }),
      );

      if (resp.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore avvio pagamento PayPal')),
          );
        }
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final approvalLink = data['approvalLink'] as String?;

      if (approvalLink == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link PayPal mancante')),
          );
        }
        return;
      }

      // Apri browser esterno per checkout PayPal
      final uri = Uri.parse(approvalLink);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Abbonamento PRO')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titolo
                Text(
                  'Sblocca il profilo PRO',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Descrizione
                const Text(
                  'Con l\'abbonamento PRO ricevi prenotazioni, gestisci il calendario e compari nella mappa degli utenti.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Card piano
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text(
                          'Piano Mensile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '€ 9,99 / mese',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Visibilità in mappa\n• Gestione calendario\n• Notifiche istantanee\n• Supporto prioritario',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Loading indicator
                if (_loading) const CircularProgressIndicator(),

                // Pulsanti pagamento
                if (!_loading)
                  Column(
                    children: [
                      // Pulsante Stripe
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _startStripeCheckout,
                          icon: const Icon(Icons.credit_card),
                          label: const Text('Paga con Carta (Stripe)'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Pulsante PayPal
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _startPayPalCheckout,
                          icon: const Icon(Icons.payment),
                          label: const Text('Paga con PayPal'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
