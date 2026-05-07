// lib/presentation/screens/auth/email_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kintsugi_app/core/theme/app_colors.dart';
import 'package:kintsugi_app/application/auth/auth_bloc.dart';
import 'package:kintsugi_app/application/auth/auth_event.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _showNotVerifiedMessage = false;
  bool _resentEmail = false;

  void _checkVerification() async {
    setState(() {
      _isChecking = true;
      _showNotVerifiedMessage = false;
    });

    // Disparar evento al BLoC para hacer reload + chequeo
    context.read<AuthBloc>().add(const AuthCheckEmailVerified());

    // Esperar un momento para que Firebase procese el reload
    await Future.delayed(const Duration(milliseconds: 1500));

    // Si seguimos montados y no navegamos, es que no estaba verificado
    if (mounted) {
      setState(() {
        _isChecking = false;
        _showNotVerifiedMessage = true;
      });
    }
  }

  void _resendEmail() {
    context.read<AuthBloc>().add(const AuthSendEmailVerification());
    setState(() {
      _resentEmail = true;
      _showNotVerifiedMessage = false;
    });

    // Ocultar el mensaje de "reenviado" después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _resentEmail = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Fondo con imagen (consistente con auth_screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFF0D0D0D)),
            ),
          ),
          const Positioned.fill(
            child: ColoredBox(color: Color(0xD90D0D0D)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Botón de cerrar sesión arriba a la derecha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthLogoutRequested());
                      },
                      icon: const Icon(Icons.logout,
                          color: AppColors.textSecondary, size: 18),
                      label: const Text(
                        'Salir',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Ícono de correo
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_rounded,
                      color: AppColors.accentPrimary,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Título
                  const Text(
                    'Verifica tu correo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Descripción
                  Text(
                    'Enviamos un enlace de verificación a',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Haz clic en el enlace del correo y luego\ntoca el botón de abajo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Botón "Ya verifiqué mi correo"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary,
                        foregroundColor: AppColors.backgroundPrimary,
                        disabledBackgroundColor:
                            AppColors.accentPrimary.withValues(alpha: 0.5),
                        disabledForegroundColor:
                            AppColors.backgroundPrimary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      child: _isChecking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.backgroundPrimary),
                              ),
                            )
                          : const Text('YA VERIFIQUÉ MI CORREO'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mensaje de "aún no verificado"
                  if (_showNotVerifiedMessage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tu correo aún no está verificado. '
                              'Revisa tu bandeja de entrada y spam.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.error,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Mensaje de "correo reenviado"
                  if (_resentEmail)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              AppColors.accentPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: AppColors.accentPrimary, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Correo de verificación reenviado.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.accentPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(flex: 1),
                  // Botón "Reenviar correo"
                  TextButton(
                    onPressed: _resendEmail,
                    child: const Text(
                      '¿No recibiste el correo? Reenviar',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}