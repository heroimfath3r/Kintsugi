//C:\Proyectos\Kintsugi\kintsugi_app\lib\core\network\api_client.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final token = await user.getIdToken();
              
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _extractData(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _extractData(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _extractData(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _extractData(Response response) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      // Si la API envuelve la respuesta en una clave única (ej: { "user": {...} }),
      // extraer el contenido interno automáticamente.
      if (data.length == 1) {
        final inner = data.values.first;
        if (inner is Map<String, dynamic>) {
          return inner;
        }
      }
      return data;
    }
    return {'data': response.data};
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    String message = 'Error inesperado';
    if (responseData is Map<String, dynamic>) {
      message = responseData['error']?.toString() ?? responseData['message']?.toString() ?? message;
    }
    switch (statusCode) {
      case 401: return UnauthorizedException(message: message);
      case 404: return NotFoundException(message: message);
      case 409: return ConflictException(message: message);
      case 500: return ServerException(message: message);
      default: return ApiException(message: message, statusCode: statusCode);
    }
  }
}
