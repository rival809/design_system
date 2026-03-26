import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';

/// HTTP service for the user-table endpoint.
///
/// Endpoint: POST /api/tabel/user/get-list
///
/// Request body example:
/// ```json
/// {
///   "datatable": {
///     "per_page": "10",
///     "current_page": "1",
///     "order_by": [{"key": "id", "method": "ASC"}],
///     "where_fields": [{"key": "name", "method": "LIKE", "value": "Ardi"}]
///   }
/// }
/// ```
///
/// Response structure:
/// ```json
/// {
///   "code": "0000",
///   "success": true,
///   "message": "Sukses",
///   "data": {
///     "keys": [{"key":"...", "method":[...], "helper":[...]}],
///     "items": [{"id":1, "name":"...", ...}],
///     "total_rows": 1374,
///     "max_page": 138,
///     "current_page": "1"
///   }
/// }
/// ```
class UserTableService {
  UserTableService({required this.dio, required this.token});

  final Dio dio;
  final String token;

  static const _endpoint = 'https://apisakti.bapenda.jabarprov.go.id/api/tabel/user/get-list';

  /// Fetches a page of users from the API.
  ///
  /// [searchRules] are mapped to `where_fields` in the request body so
  /// filtering is done server-side.
  Future<UserTableResult> fetchPage({
    required int page,
    required int perPage,
    required List<AppTableSearchRule> searchRules,
  }) async {
    final whereFields = searchRules
        .where((r) => r.value.trim().isNotEmpty)
        .map((r) => {'key': r.key, 'method': r.method, 'value': r.value})
        .toList();

    final response = await dio.post<Map<String, dynamic>>(
      _endpoint,
      data: {
        'datatable': {
          'per_page': perPage.toString(),
          'current_page': page.toString(),
          'order_by': [
            {'key': 'id', 'method': 'ASC'},
          ],
          'where_fields': whereFields,
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      ),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body?['message']?.toString() ?? 'API returned an error',
      );
    }

    final raw = body['data'] as Map<String, dynamic>;
    final rawKeys = (raw['keys'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rawItems = (raw['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalRows = _parseInt(raw['total_rows']) ?? 0;
    final maxPage = _parseInt(raw['max_page']) ?? 1;
    final currentPage = _parseInt(raw['current_page']) ?? page;

    // Map API keys → AppBaseTableKey — helpers use {helper_id, helper_name}
    // which the design system widget already understands.
    final keys = rawKeys
        .map(
          (k) => AppBaseTableKey(
            key: k['key']?.toString() ?? '',
            method: (k['method'] as List?)?.map((e) => e.toString()).toList() ?? [],
            helper: (k['helper'] as List?)?.cast<Map<String, Object?>>() ?? [],
          ),
        )
        .where((k) => k.key.isNotEmpty)
        .toList();

    return UserTableResult(
      keys: keys,
      items: rawItems,
      totalRows: totalRows,
      maxPage: maxPage,
      currentPage: currentPage,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

/// Parsed result from [UserTableService.fetchPage].
class UserTableResult {
  const UserTableResult({
    required this.keys,
    required this.items,
    required this.totalRows,
    required this.maxPage,
    required this.currentPage,
  });

  final List<AppBaseTableKey> keys;
  final List<Map<String, dynamic>> items;
  final int totalRows;
  final int maxPage;
  final int currentPage;
}
