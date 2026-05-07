// Reemplaza TODO el contenido de:
// lib/data/services/auth_service.dart

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_service.dart';
import '../local/local_storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  AuthService(this._client, this._localStorage, this._connectivity);

  Future<UserModel> register() async {
    final response = await _client.post(ApiEndpoints.register);
    // Guardar perfil en cache local
    await _localStorage.guardarPerfil(response);
    return UserModel.fromJson(response);
  }

  Future<UserModel> getProfile() async {
    // Intentar obtener de la API si hay internet
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.profile);
        // Actualizar cache local
        await _localStorage.guardarPerfil(response);
        return UserModel.fromJson(response);
      } catch (_) {
        // Si falla la API, intentar cache local
        return _getPerfilLocal();
      }
    }

    // Sin internet → leer del cache local
    return _getPerfilLocal();
  }

  Future<UserModel> setArchetype(String arquetipoId) async {
    final response = await _client.put(
      ApiEndpoints.archetype,
      data: {'arquetipo': arquetipoId},
    );
    // Actualizar cache local
    await _localStorage.guardarPerfil(response);
    return UserModel.fromJson(response);
  }

  /// Lee el perfil del cache local.
  /// Lanza excepción si no hay cache.
  UserModel _getPerfilLocal() {
    final data = _localStorage.obtenerPerfil();
    if (data == null) {
      throw Exception('Sin conexión y sin datos locales.');
    }
    return UserModel.fromJson(data);
  }
}