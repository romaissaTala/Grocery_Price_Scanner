abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
}

class ServerException extends AppException {
  const ServerException(String message) : super(message);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class AuthException extends AppException {
  const AuthException(String message) : super(message);
}