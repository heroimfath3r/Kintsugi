// lib/application/auth/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthRegisterRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSetArchetype extends AuthEvent {
  final String arquetipoId;
  const AuthSetArchetype({required this.arquetipoId});
  @override
  List<Object?> get props => [arquetipoId];
}

// ── NUEVOS ──────────────────────────────────────────────────────────────

/// Usuario olvidó su contraseña → envía correo de reset via Firebase.
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

/// Reenvía el correo de verificación al usuario actual.
class AuthSendEmailVerification extends AuthEvent {
  const AuthSendEmailVerification();
}

/// Hace reload del usuario de Firebase y checa si emailVerified cambió.
/// Es lo que se ejecuta cuando el usuario toca "Ya verifiqué mi correo".
class AuthCheckEmailVerified extends AuthEvent {
  const AuthCheckEmailVerified();
}