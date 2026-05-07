// lib/data/services/mision_service.dart

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_service.dart';
import '../local/local_storage_service.dart';
import '../models/mision_model.dart';

class MisionService {
  final ApiClient _client;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  MisionService(this._client, this._localStorage, this._connectivity);

  /// Obtiene la misión diaria.
  /// Flujo offline-first:
  /// 1. Si hay internet → pide a la API → guarda en cache
  /// 2. Si no hay internet → lee del cache local
  Future<MisionModel> getMisionDiaria() async {
    final hoy = _fechaHoy();

    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.misionDaily);
        final misionData = response.containsKey('mission') &&
                response['mission'] is Map<String, dynamic>
            ? response['mission'] as Map<String, dynamic>
            : response;

        // Guardar en cache local
        await _localStorage.guardarMision(hoy, Map.from(misionData), true);
        return MisionModel.fromJson(misionData);
      } catch (_) {
        // Si falla la API, intentar cache local
        return _getMisionLocal(hoy);
      }
    }

    // Sin internet → leer del cache
    return _getMisionLocal(hoy);
  }

  /// Marca una misión como completada.
  /// Flujo offline-first:
  /// 1. Marca localmente PRIMERO
  /// 2. Si hay internet → envía a la API
  /// 3. Si no → SyncManager lo enviará después
  Future<Map<String, dynamic>> completarMision(String misionId) async {
    final hoy = _fechaHoy();

    // 1. Marcar localmente primero (respuesta inmediata)
    await _localStorage.completarMisionLocal(hoy, false);

    // 2. Intentar enviar a la API
    if (await _connectivity.checkConnectivity()) {
      try {
        final response =
            await _client.put(ApiEndpoints.misionComplete(misionId));
        // Éxito → marcar como sincronizada
        await _localStorage.marcarMisionSincronizada(hoy);
        return response;
      } catch (_) {
        // Falló la API pero ya está marcada localmente
        // SyncManager lo enviará después
      }
    }

    return {'completada': true, '_offline': true};
  }

  /// Obtiene el historial de misiones.
  /// Con internet → API. Sin internet → cache local.
  Future<List<MisionModel>> getHistorial() async {
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.misionHistory);
        final lista = response['misiones'] as List? ??
            response['missions'] as List? ??
            [];
        final misiones = lista
            .map((item) =>
                MisionModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Guardar cada misión en cache local
        for (final mision in misiones) {
          final fechaKey = mision.fecha.length >= 10
              ? mision.fecha.substring(0, 10)
              : mision.fecha;
          await _localStorage.guardarMision(
            fechaKey,
            {
              'id': mision.id,
              'titulo': mision.titulo,
              'tipo': mision.tipo,
              'descripcion': mision.descripcion,
              'estadoEmocional': mision.estadoEmocional,
              'arquetipo': mision.arquetipo,
              'completada': mision.completada,
              'fecha': mision.fecha,
            },
            true,
          );
        }

        return misiones;
      } catch (_) {
        return _getHistorialLocal();
      }
    }

    return _getHistorialLocal();
  }

  /// Lee la misión del cache local.
  MisionModel _getMisionLocal(String fecha) {
    final data = _localStorage.obtenerMision(fecha);
    if (data == null) {
      throw Exception('Sin conexión y sin misión cacheada.');
    }
    return MisionModel.fromJson(data);
  }

  /// Lee el historial de misiones del cache local.
  List<MisionModel> _getHistorialLocal() {
    final lista = _localStorage.obtenerHistorialMisiones();
    return lista.map((data) => MisionModel.fromJson(data)).toList();
  }

  String _fechaHoy() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}