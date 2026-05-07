import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/network/api_exceptions.dart';
import '../../data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirebaseAuth _firebaseAuth;

  AuthBloc({
    required AuthService authService,
    FirebaseAuth? firebaseAuth,
  })  : _authService = authService,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSetArchetype>(_onSetArchetype);
  }

  Future<void> _onCheckSession(AuthCheckSession event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      final profile = await _authService.getProfile();
      emit(AuthAuthenticated(user: profile));
    } on UnauthorizedException {
      await _firebaseAuth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: _extractMessage(e)));
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: event.email.trim(), password: event.password);
      final profile = await _authService.getProfile();
      emit(AuthAuthenticated(user: profile));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _firebaseErrorMessage(e.code)));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: _extractMessage(e)));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: event.email.trim(), password: event.password);
      final profile = await _authService.register();
      emit(AuthAuthenticated(user: profile));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _firebaseErrorMessage(e.code)));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: _extractMessage(e)));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSetArchetype(AuthSetArchetype event, Emitter<AuthState> emit) async {
    try {
      final updatedProfile = await _authService.setArchetype(event.arquetipoId);
      emit(AuthAuthenticated(user: updatedProfile));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: _extractMessage(e)));
    }
  }

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'No existe una cuenta con este correo.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'invalid-credential': return 'Credenciales inválidas.';
      case 'email-already-in-use': return 'Ya existe una cuenta con este correo.';
      case 'weak-password': return 'La contraseña es muy débil.';
      case 'invalid-email': return 'El formato del correo no es válido.';
      case 'too-many-requests': return 'Demasiados intentos. Espera un momento.';
      case 'network-request-failed': return 'Sin conexión a internet.';
      default: return 'Error de autenticación ($code).';
    }
  }

  String _extractMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is FirebaseException) return _firebaseErrorMessage(error.code);
    return 'Ocurrió un error inesperado.';
  }
}