import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/checkin_model.dart';

class CheckinService {
  final ApiClient _client;
  CheckinService(this._client);

  Future<CheckinModel> realizarCheckin(String estadoEmocional) async {
    final response = await _client.post(
      ApiEndpoints.checkin,
      data: {'estadoEmocional': estadoEmocional},
    );
    // La API puede devolver { checkin: {...} } o el objeto directo
    if (response.containsKey('checkin') && response['checkin'] is Map<String, dynamic>) {
      return CheckinModel.fromJson(response['checkin'] as Map<String, dynamic>);
    }
    return CheckinModel.fromJson(response);
  }

  Future<CheckinModel?> getCheckinHoy() async {
    try {
      final response = await _client.get(ApiEndpoints.checkinToday);
      if (response['hasCheckin'] != true || response['checkin'] == null) {
        return null;
      }
      final checkinData = response['checkin'];
      if (checkinData is Map<String, dynamic>) {
        return CheckinModel.fromJson(checkinData);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<CheckinModel>> getHistorial() async {
    final response = await _client.get(ApiEndpoints.checkinHistory);
    final lista = response['checkins'] as List? ?? response['historial'] as List? ?? [];
    return lista.map((item) => CheckinModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}