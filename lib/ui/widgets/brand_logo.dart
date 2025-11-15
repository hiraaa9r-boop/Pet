import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🐶 Usa il tuo asset del bulldog/boxer
        SizedBox(
          height: size,
          child: Image.asset(
            'assets/logo_mypetcare.png', // assicurati che sia in pubspec.yaml
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback se l'immagine non è disponibile
              return Icon(
                Icons.pets,
                size: size,
                color: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MyPetCare',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tutti i servizi per il tuo pet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
        ),
      ],
    );
  }
}
