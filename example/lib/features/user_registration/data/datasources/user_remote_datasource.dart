import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/create_user_request_model.dart';
import '../models/created_user_model.dart';
import '../models/user_model.dart';

abstract interface class UserRemoteDataSource {
  Future<List<UserModel>> getUsers({required int page, required int limit, String query = ''});
  Future<CreatedUserModel> createUser(CreateUserRequestModel request);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<UserModel>> getUsers({
    required int page,
    required int limit,
    String query = '',
  }) async {
    try {
      final skip = (page - 1) * limit;
      final q = query.trim();
      final endpoint = q.isEmpty ? ApiConstants.usersEndpoint : ApiConstants.searchUsersEndpoint;
      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: {'skip': skip, 'limit': limit, if (q.isNotEmpty) 'q': q},
      );

      final data = response.data as Map<String, dynamic>;
      final users = (data['users'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return users;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ParseException('Failed to parse users: $e');
    }
  }

  @override
  Future<CreatedUserModel> createUser(CreateUserRequestModel request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.addUserEndpoint,
        data: request.toJson(),
      );

      return CreatedUserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ParseException('Failed to parse created user: $e');
    }
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Koneksi bermasalah. Periksa koneksi internet Anda.');
      default:
        final statusCode = e.response?.statusCode;
        final msg =
            (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
            e.message ??
            'Terjadi kesalahan pada server';
        return ServerException(msg, statusCode: statusCode);
    }
  }
}
