sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class ParseException extends AppException {
  const ParseException(super.message);
}
