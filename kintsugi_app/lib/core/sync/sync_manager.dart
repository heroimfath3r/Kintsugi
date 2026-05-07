// lib/core/sync/sync_manager.dart

import 'dart:async';
import '../network/connectivity_service.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../data/local/local_storage_service.dart';

/// Sincroniza datos pendientes con el backend cuando hay conexión.
///
/// Escucha cambios de conectividad y, al detectar que volvió internet,
/// envía en orden cronológico:
/// 1. Check-ins pendientes
/// 2. Misiones completadas pendientes
///
/// Implementa deduplicación por fecha — si la API devuelve 409 (conflicto),
/// marca el registro como sincronizado sin error.
class SyncManager {
  final ConnectivityService _connectivity;
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  StreamSubscription? _subscription;
  bool _isSyncing = false;

  SyncManager({
    required ConnectivityService connectivity,
    required ApiClient apiClient,
    required LocalStorageService localStorage,
  })  : _connectivity = connectivity,
        _apiClient = apiClient,
        _localStorage = localStorage;

  /// Inicia la escucha de cambios de conectividad.
  /// Llamar una sola vez, típicamente al iniciar la app.
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncPendientes();
      }
    });
  }

  /// Detiene la escucha. Llamar al cerrar sesión o al disponer.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Sincroniza todos los datos pendientes.
  /// Se puede llamar manualmente o se dispara automáticamente
  /// cuando se recupera la conexión.
  Future<void> syncPendientes() async {
    // Evitar sincronizaciones concurrentes
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Verificar que realmente hay internet
      final online = await _connectivity.checkConnectivity();
      if (!online) return;

      await _syncCheckins();
      await _syncMisionesCompletadas();
    } catch (_) {
      // Silenciar errores — se reintentará en el próximo cambio de conectividad
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincroniza check-ins pendientes en orden cronológico.
  Future<void> _syncCheckins() async {
    final pendientes = _localStorage.obtenerCheckinsPendientes();

    for (final checkin in pendientes) {
      try {
        final estadoEmocional = checkin['estadoEmocional']?.toString() ?? '';
        final fechaKey = checkin['_fecha_key']?.toString() ?? '';

        if (estadoEmocional.isEmpty || fechaKey.isEmpty) continue;

        await _apiClient.post(
          ApiEndpoints.checkin,
          data: {'estadoEmocional': estadoEmocional},
        );

        // Éxito → marcar como sincronizado
        await _localStorage.marcarCheckinSincronizado(fechaKey);
      } catch (e) {
        // 409 = ya existe en el servidor → marcar como sincronizado
        if (_esConflicto(e)) {
          final fechaKey = checkin['_fecha_key']?.toString() ?? '';
          await _localStorage.marcarCheckinSincronizado(fechaKey);
        }
        // Otros errores → se reintentará después
      }
    }
  }

  /// Sincroniza misiones completadas pendientes.
  Future<void> _syncMisionesCompletadas() async {
    final pendientes = _localStorage.obtenerMisionesCompletadasPendientes();

    for (final mision in pendientes) {
      try {
        final misionId = mision['id']?.toString() ?? '';
        final fechaKey = mision['_fecha_key']?.toString() ?? '';

        if (misionId.isEmpty || fechaKey.isEmpty) continue;

        await _apiClient.put(ApiEndpoints.misionComplete(misionId));

        // Éxito → marcar como sincronizada
        await _localStorage.marcarMisionSincronizada(fechaKey);
      } catch (e) {
        // 409 = ya completada en el servidor → marcar como sincronizada
        if (_esConflicto(e)) {
          final fechaKey = mision['_fecha_key']?.toString() ?? '';
          await _localStorage.marcarMisionSincronizada(fechaKey);
        }
      }
    }
  }

  /// Verifica si un error es un conflicto (409).
  bool _esConflicto(Object error) {
    return error.toString().contains('409') ||
        error.toString().contains('Conflict') ||
        error.toString().contains('ConflictException');
  }
}