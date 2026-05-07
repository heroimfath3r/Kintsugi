// Reemplaza TODO el contenido de:
// lib/data/services/progreso_service.dart

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_service.dart';
import '../local/local_storage_service.dart';
import '../models/progreso_model.dart';

class ProgresoService {
  final ApiClient _client;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  ProgresoService(this._client, this._localStorage, this._connectivity);

  /// Obtiene datos de progreso del usuario.
  /// Con internet → API + cache. Sin internet → cache.
  Future<ProgresoModel> getProgreso() async {
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.progreso);
        // Guardar en cache
        await _localStorage.guardarProgreso(response);
        return ProgresoModel.fromJson(response);
      } catch (_) {
        return _getProgresoLocal();
      }
    }
    return _getProgresoLocal();
  }

  /// Obtiene el resumen semanal.
  /// Con internet → API + cache. Sin internet → cache.
  Future<ProgresoWeeklyModel> getResumenSemanal() async {
    if (await _connectivity.checkConnectivity()) {
      try {
        final response = await _client.get(ApiEndpoints.progresoWeekly);
        final resumenData = response['resumenSemanal'];
        if (resumenData is Map<String, dynamic>) {
          // Guardar en cache
          await _localStorage.guardarResumenSemanal(resumenData);
          return ProgresoWeeklyModel.fromJson(resumenData);
        }
        return ProgresoWeeklyModel.fromJson(response);
      } catch (_) {
        return _getResumenLocal();
      }
    }
    return _getResumenLocal();
  }

  ProgresoModel _getProgresoLocal() {
    final data = _localStorage.obtenerProgreso();
    if (data == null) {
      // Retornar valores por defecto en vez de lanzar error
      return const ProgresoModel();
    }
    return ProgresoModel.fromJson(data);
  }

  ProgresoWeeklyModel _getResumenLocal() {
    final data = _localStorage.obtenerResumenSemanal();
    if (data == null) {
      return const ProgresoWeeklyModel();
    }
    return ProgresoWeeklyModel.fromJson(data);
  }
}