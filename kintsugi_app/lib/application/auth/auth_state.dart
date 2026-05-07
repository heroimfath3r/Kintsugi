// lib/application/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool emailVerified;

  const AuthAuthenticated({
    required this.user,
    required this.emailVerified,
  });

  @override
  List<Object?> get props => [user.uid, user.arquetipo, emailVerified];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Estado especial para cuando se envió el correo de
/// recuperación de contraseña exitosamente.
/// Es distinto a AuthError y AuthAuthenticated porque
/// el usuario NO está logueado, pero tampoco es un error.
class AuthPasswordResetSent extends AuthState {
  final String email;
  const AuthPasswordResetSent({required this.email});
  @override
  List<Object?> get props => [email];
}