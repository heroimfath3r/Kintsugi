class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ConflictException extends ApiException {
  const ConflictException({super.message = 'Ya existe un registro para hoy', super.statusCode = 409});
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Recurso no encontrado', super.statusCode = 404});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'No autorizado', super.statusCode = 401});
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Sin conexión a internet', super.statusCode});
}

class ServerException extends ApiException {
  const ServerException({super.message = 'Error interno del servidor', super.statusCode = 500});
}
