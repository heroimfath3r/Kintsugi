import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/mision_model.dart';

class MisionService {
  final ApiClient _client;
  MisionService(this._client);

  Future<MisionModel> getMisionDiaria() async {
    final response = await _client.get(ApiEndpoints.misionDaily);
    // La API devuelve { mission: {...} }
    if (response.containsKey('mission') && response['mission'] is Map<String, dynamic>) {
      return MisionModel.fromJson(response['mission'] as Map<String, dynamic>);
    }
    return MisionModel.fromJson(response);
  }

  Future<Map<String, dynamic>> completarMision(String misionId) async {
    return await _client.put(ApiEndpoints.misionComplete(misionId));
  }

  Future<List<MisionModel>> getHistorial() async {
    final response = await _client.get(ApiEndpoints.misionHistory);
    final lista = response['misiones'] as List? ?? response['missions'] as List? ?? [];
    return lista.map((item) => MisionModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}