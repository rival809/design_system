abstract final class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String usersEndpoint = '/users';
  static const String searchUsersEndpoint = '/users/search';
  static const String addUserEndpoint = '/users/add';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
