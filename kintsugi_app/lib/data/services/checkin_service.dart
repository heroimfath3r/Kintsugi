// Reemplaza TODO el contenido de:
// lib/data/services/checkin_service.dart

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_service.dart';
import '../local/local_storage_service.dart';
import '../models/checkin_model.dart';

class CheckinService {
  final ApiClient _client;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  CheckinService(this._client, this._localStorage, this._connectivity);

  /// Realiza un check-in emocional.
  /// Flujo offline-first:
  /// 1. Guarda en Hive inmediatamente (sincronizado = false)
  /// 2. Si hay internet → envía a la API → marca como sincronizado
  /// 3. Si no hay internet → queda en cola para SyncManager
  Future<CheckinModel> realizarCheckin(String estadoEmocional) async {
    final hoy = _fechaHoy();
    final now = DateTime.now().toIso8601String();

    // Datos del check-in
    final data = {
      'estadoEmocional': estadoEmocional,
      'fecha': now,
      'creadoEn': now,
    };

    // 1. Guardar localmente PRIMERO (respuesta inmediata al usuario)
    await _localStorage.guardarCheckin(hoy, Map.from(data), false);

    // 2. Intentar enviar a la API si hay internet
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.post(
          ApiEndpoints.checkin,
          data: {'estadoEmocional': estadoEmocional},
        );

        // Actualizar con la respuesta real del servidor
        final checkinData = response.containsKey('checkin') &&
                response['checkin'] is Map<String, dynamic>
            ? response['checkin'] as Map<String, dynamic>
            : response;

        await _localStorage.guardarCheckin(hoy, Map.from(checkinData), true);
        return CheckinModel.fromJson(checkinData);
      } catch (_) {
        // Falló la API pero ya está guardado localmente
        // SyncManager lo enviará después
      }
    }

    // Retornar el modelo desde los datos locales
    return CheckinModel.fromJson(data);
  }

  /// Verifica si ya se hizo check-in hoy.
  /// Checa primero en local, luego en la API.
  Future<CheckinModel?> getCheckinHoy() async {
    // 1. Checar en Hive primero (más rápido)
    final local = _localStorage.obtenerCheckinHoy();
    if (local != null) {
      return CheckinModel.fromJson(local);
    }

    // 2. Si no hay local y hay internet, checar en la API
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.checkinToday);
        if (response['hasCheckin'] != true || response['checkin'] == null) {
          return null;
        }
        final checkinData = response['checkin'];
        if (checkinData is Map<String, dynamic>) {
          // Guardar en cache local
          final hoy = _fechaHoy();
          await _localStorage.guardarCheckin(
              hoy, Map.from(checkinData), true);
          return CheckinModel.fromJson(checkinData);
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    // Sin internet y sin local → no hay check-in hoy
    return null;
  }

  /// Obtiene el historial de check-ins.
  Future<List<CheckinModel>> getHistorial() async {
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.checkinHistory);
        final lista = response['checkins'] as List? ??
            response['historial'] as List? ??
            [];
        return lista
            .map((item) =>
                CheckinModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Si falla, no retornar nada — el historial no es crítico offline
        return [];
      }
    }
    return [];
  }

  String _fechaHoy() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}