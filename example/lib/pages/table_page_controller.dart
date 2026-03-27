import 'dart:collection';

import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'user_table_service.dart';

enum ActionMode { singleButton, doubleButton, dropdown }

/// Token JWT untuk autentikasi API. Ganti dengan mekanisme auth yang sebenarnya
/// (misal: dari secure storage / BLoC auth) pada implementasi production.
const _kBearerToken =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTkyLjE2OC45OS40Nzo4MDAwL2FwaS9sb2dpbiIsImlhdCI6MTc3NDU3MTMyMCwiZXhwIjoxNzc0NTkyOTIwLCJuYmYiOjE3NzQ1NzEzMjAsImp0aSI6Im9ZbUdoVmM3eTJ5SmRJUkoiLCJzdWIiOiIxMSIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.7-9097hkyiDV32VRXv03QqjvnVqL-tUT5nhZoXWXp_Q';

class TablePageController extends ChangeNotifier {
  TablePageController() {
    _service = UserTableService(dio: Dio(), token: _kBearerToken);
  }

  late final UserTableService _service;

  int _currentPage = 1;
  int _rowsPerPage = 10;
  ActionMode _actionMode = ActionMode.singleButton;
  bool _isLoading = true;
  bool _isLoadingMore = false; // Indicator specifically for mobile lazy load
  String? _errorMessage;
  int _requestCounter = 0;
  bool _isDisposed = false;

  // Hasil dari API — di-set setiap kali fetchPage() selesai.
  List<AppBaseTableKey> _apiKeys = const [];
  List<Map<String, dynamic>> _serverItems = const []; // Desktop replaces this
  final List<Map<String, dynamic>> _mobileItems = []; // Mobile appends to this
  int _totalRows = 0;
  int _maxPage = 1;

  List<AppTableSearchRule> _searchRules = const [];

  // Kolom yang tampil — diisi dari _apiKeys saat pertama fetch.
  final Set<String> _visibleKeys = {};
  bool _keysInitialized = false;

  // ─── Getters ───────────────────────────────────────────────────────────────

  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;
  ActionMode get actionMode => _actionMode;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get serverItems => _serverItems;
  List<Map<String, dynamic>> get mobileItems => UnmodifiableListView(_mobileItems);
  List<AppBaseTableKey> get searchKeys => _apiKeys;
  List<String> get allKeys => _apiKeys.map((e) => e.key).toList();
  Set<String> get visibleKeys => UnmodifiableSetView(_visibleKeys);
  List<AppTableSearchRule> get searchRules => _searchRules;
  int get maxPage => _maxPage;

  AppBaseTableData get tableData {
    final visibleKeyOrder = _apiKeys.map((k) => k.key).where(_visibleKeys.contains).toList();

    return AppBaseTableData(
      keys: visibleKeyOrder.map((key) => AppBaseTableKey(key: key)).toList(),
      items: _serverItems,
      totalRows: _totalRows,
      maxPage: _maxPage,
      currentPage: _currentPage,
    );
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    await fetchPage();
  }

  Future<void> fetchPage({bool isLoadMore = false}) async {
    final requestId = ++_requestCounter;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchPage(
        page: _currentPage,
        perPage: _rowsPerPage,
        searchRules: _searchRules,
      );

      if (_isDisposed || requestId != _requestCounter) return;

      // Inisialisasi visibleKeys dari API sekali saja (saat pertama load).
      if (!_keysInitialized) {
        _visibleKeys
          ..clear()
          ..addAll(result.keys.map((k) => k.key));
        _keysInitialized = true;
      }

      _apiKeys = result.keys;
      _serverItems = result.items;
      _totalRows = result.totalRows;
      _maxPage = result.maxPage;

      if (_currentPage == 1) {
        _mobileItems.clear();
      }
      _mobileItems.addAll(result.items);
    } on DioException catch (e) {
      if (_isDisposed || requestId != _requestCounter) return;
      _errorMessage = e.message ?? 'Terjadi kesalahan jaringan';
    } catch (e) {
      if (_isDisposed || requestId != _requestCounter) return;
      _errorMessage = 'Error: $e';
    } finally {
      if (!_isDisposed && requestId == _requestCounter) {
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void setActionMode(ActionMode value) {
    if (_actionMode == value) return;
    _actionMode = value;
    notifyListeners();
  }

  void toggleVisibleColumn(String key) {
    if (_visibleKeys.contains(key)) {
      if (_visibleKeys.length > 1) _visibleKeys.remove(key);
    } else {
      _visibleKeys.add(key);
    }
    notifyListeners();
  }

  Future<void> applySearch({
    required List<AppTableSearchRule> rules,
    required List<String> visibleKeys,
  }) async {
    final validKeys = visibleKeys.where(allKeys.contains).toList();
    _searchRules = rules;
    _visibleKeys
      ..clear()
      ..addAll(validKeys.isEmpty ? allKeys : validKeys);
    _currentPage = 1;
    await fetchPage();
  }

  Future<void> resetSearch() async {
    _searchRules = const [];
    _visibleKeys
      ..clear()
      ..addAll(allKeys);
    _currentPage = 1;
    await fetchPage();
  }

  Future<void> changeRowsPerPage(int value) async {
    _rowsPerPage = value;
    _currentPage = 1;
    await fetchPage();
  }

  Future<void> changePage(int value) async {
    _currentPage = value.clamp(1, _maxPage);
    await fetchPage();
  }

  /// Khusus untuk mobile: append data halaman berikutnya ke list akhir.
  Future<void> loadNextPageMobile() async {
    if (_isLoading || _isLoadingMore || _currentPage >= _maxPage) return;
    _currentPage++;
    await fetchPage(isLoadMore: true);
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
