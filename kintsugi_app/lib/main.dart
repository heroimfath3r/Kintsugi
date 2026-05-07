import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kintsugi_app/core/di/service_locator.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/core/theme/app_theme.dart';
import 'package:kintsugi_app/application/auth/auth_bloc.dart';
import 'package:kintsugi_app/application/auth/auth_event.dart';
import 'package:kintsugi_app/application/auth/auth_state.dart';
import 'package:kintsugi_app/data/services/auth_service.dart';
import 'package:kintsugi_app/presentation/screens/auth/auth_screen.dart';
import 'package:kintsugi_app/presentation/screens/auth/test_sintonia_screen.dart';
import 'package:kintsugi_app/presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServiceLocator();
  runApp(const KintsugiApp());
}

class KintsugiApp extends StatelessWidget {
  const KintsugiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authService: sl<AuthService>())
        ..add(const AuthCheckSession()),
      child: MaterialApp(
        title: 'Kintsugi',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const _SplashScreen();
        }
        if (state is AuthAuthenticated) {
          if (!state.user.tieneArquetipo) {
            return const TestSintoniaScreen();
          }
          return HomeScreen(arquetipoId: state.user.arquetipo!);
        }
        return const _WelcomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'KINTSUGI',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimary,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accentPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFF0D0D0D)),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                  colors: [Colors.transparent, Color(0xFF0D0D0D)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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