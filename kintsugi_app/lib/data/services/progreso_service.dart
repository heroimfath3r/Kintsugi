import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/progreso_model.dart';

class ProgresoService {
  final ApiClient _client;
  ProgresoService(this._client);

  Future<ProgresoModel> getProgreso() async {
    final response = await _client.get(ApiEndpoints.progreso);
    return ProgresoModel.fromJson(response);
  }

  Future<ProgresoWeeklyModel> getResumenSemanal() async {
    final response = await _client.get(ApiEndpoints.progresoWeekly);
    return ProgresoWeeklyModel.fromJson(response);
  }
}
