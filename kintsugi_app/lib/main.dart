import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/theme/app_theme.dart';

void main() {
  runApp(const KintsugiApp());
}

class KintsugiApp extends StatelessWidget {
  const KintsugiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kintsugi',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Hero image zone
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: AppColors.backgroundSecondary,
                // TODO: replace with Image.asset('assets/images/warrior_hero.png', fit: BoxFit.cover)
                child: const Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
            // Title, tagline and buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const Text(
                    'KINTSUGI',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPrimary,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu camino. Tu historia. Tu progreso.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: navigate to register
                      },
                      child: const Text('COMENZAR VIAJE'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: navigate to login
                      },
                      child: const Text('YA TENGO CUENTA'),
                    ),
                  ),
                ],
              ),
            ),
            // Legal text
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Text(
                'Al continuar aceptas nuestros Términos y Privacidad',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
