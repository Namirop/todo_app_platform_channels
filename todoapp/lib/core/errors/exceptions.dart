// Infrastructure layer exceptions
// These are thrown by datasources and caught by repositories

abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException({required super.message}) : super(statusCode: null);
}

class ValidationException extends AppException {
  ValidationException({required super.message}) : super(statusCode: 400);
}

class NotFoundException extends AppException {
  NotFoundException({required super.message}) : super(statusCode: 404);
}

class ForbiddenException extends AppException {
  ForbiddenException({required super.message}) : super(statusCode: 403);
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message}) : super(statusCode: 401);
}

class UnknownException extends AppException {
  UnknownException({required super.message}) : super(statusCode: null);
}

class AuthException extends AppException {
  AuthException({required super.message, super.statusCode});
}

class CacheException extends AppException {
  CacheException({required super.message}) : super(statusCode: null);
}
