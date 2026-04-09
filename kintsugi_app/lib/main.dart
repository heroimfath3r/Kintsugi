import 'package:flutter/material.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/theme/app_theme.dart';
import 'package:kintsugi_app/presentation/screens/auth/auth_screen.dart';

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
      body: Stack(
        children: [
          // Background image full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay: transparent top 40% → solid bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
          ),
          // Content at the bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AuthScreen(
                              initialMode: AuthMode.register,
                            ),
                          ));
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
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AuthScreen(
                              initialMode: AuthMode.login,
                            ),
                          ));
                        },
                        child: const Text('YA TENGO CUENTA'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Al continuar aceptas nuestros Términos y Privacidad',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
