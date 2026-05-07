import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<UserModel> register() async {
    final response = await _client.post(ApiEndpoints.register);
    return UserModel.fromJson(response);
  }

  Future<UserModel> getProfile() async {
    final response = await _client.get(ApiEndpoints.profile);
    return UserModel.fromJson(response);
  }

  Future<UserModel> setArchetype(String arquetipoId) async {
    final response = await _client.put(
      ApiEndpoints.archetype,
      data: {'arquetipo': arquetipoId},
    );
    return UserModel.fromJson(response);
  }
}
