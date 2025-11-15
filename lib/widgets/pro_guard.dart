// lib/widgets/pro_guard.dart
// Widget di protezione route per PRO subscription

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pro_subscription_model.dart';

class ProGuard extends StatelessWidget {
  final ProSubscription? subscription;
  final Widget child;

  const ProGuard({
    super.key,
    required this.subscription,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Se subscription non valida, redirect a pagina abbonamento
    if (subscription == null || !subscription!.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/subscribe');
        }
      });
      return const SizedBox.shrink();
    }

    // Subscription valida, mostra contenuto
    return child;
  }
}
