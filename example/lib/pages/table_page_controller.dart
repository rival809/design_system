import 'dart:collection';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';

enum ActionMode { singleButton, doubleButton, dropdown }

class TablePageController extends ChangeNotifier {
  int _currentPage = 1;
  int _rowsPerPage = 10;
  ActionMode _actionMode = ActionMode.singleButton;
  bool _isLoading = true;
  int _requestCounter = 0;
  bool _isDisposed = false;
  List<Map<String, dynamic>> _serverItems = const [];
  List<AppTableSearchRule> _searchRules = const [];

  static const List<String> _supportedMethods = [
    '=',
    '>=',
    '<=',
    '<',
    '>',
    'LIKE',
    '!=',
    'IN',
    'NOT IN',
  ];

  static const List<AppBaseTableKey> _searchKeys = [
    AppBaseTableKey(key: 'nama', method: _supportedMethods, helper: ['Masukkan nama']),
    AppBaseTableKey(key: 'nip', method: _supportedMethods, helper: ['Masukkan email / NIP']),
    AppBaseTableKey(key: 'bidang', method: _supportedMethods, helper: ['Masukkan kode bidang']),
    AppBaseTableKey(
      key: 'pangkat_golongan',
      method: _supportedMethods,
      helper: ['Masukkan pangkat atau golongan'],
    ),
    AppBaseTableKey(
      key: 'no_whatsapp',
      method: _supportedMethods,
      helper: ['Masukkan nomor WhatsApp'],
    ),
    AppBaseTableKey(key: 'status', method: _supportedMethods, helper: ['Masukkan status']),
    AppBaseTableKey(key: 'aksi', method: _supportedMethods, helper: ['Masukkan label aksi']),
  ];

  static final List<String> _allKeys = _searchKeys.map((e) => e.key).toList();

  final Set<String> _visibleKeys = {..._allKeys};

  static const Map<String, dynamic> _apiBaseItem = {
    'id': '7c2d4ae1-0d21-4676-bbf4-876d3de323b7',
    'name': 'Admin PSIP',
    'password': null,
    'remember_token': null,
    'created_at': '2026-03-02T03:22:36.000000Z',
    'updated_at': '2026-03-02T03:22:36.000000Z',
    'username': 'admin',
    'id_department': null,
    'id_jabatan': null,
    'no_wa': null,
    'email': null,
  };

  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;
  ActionMode get actionMode => _actionMode;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get serverItems => _serverItems;
  List<String> get allKeys => _allKeys;
  List<AppBaseTableKey> get searchKeys => _searchKeys;
  Set<String> get visibleKeys => UnmodifiableSetView(_visibleKeys);
  List<AppTableSearchRule> get searchRules => _searchRules;

  int get maxPage => (_filteredItems.length / _rowsPerPage).ceil().clamp(1, 9999);

  AppBaseTableData get tableData {
    final keys = _allKeys.where(_visibleKeys.contains).toList();
    return AppBaseTableData(
      keys: keys.map((key) => AppBaseTableKey(key: key)).toList(),
      items: _serverItems,
      totalRows: _filteredItems.length,
      maxPage: maxPage,
      currentPage: _currentPage,
    );
  }

  Future<void> init() async {
    await fakeFetchPage();
  }

  Future<void> fakeFetchPage() async {
    final requestId = ++_requestCounter;
    _isLoading = true;
    notifyListeners();

    // Simulasi hit API backend.
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (_isDisposed || requestId != _requestCounter) return;

    final sourceItems = _filteredItems;
    final start = (_currentPage - 1) * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, sourceItems.length);
    final pageItems = start >= sourceItems.length
        ? <Map<String, dynamic>>[]
        : sourceItems.sublist(start, end);

    _serverItems = pageItems;
    _isLoading = false;
    notifyListeners();
  }

  void setActionMode(ActionMode value) {
    if (_actionMode == value) return;
    _actionMode = value;
    notifyListeners();
  }

  void toggleVisibleColumn(String key) {
    if (_visibleKeys.contains(key)) {
      if (_visibleKeys.length > 1) {
        _visibleKeys.remove(key);
      }
    } else {
      _visibleKeys.add(key);
    }
    notifyListeners();
  }

  Future<void> applySearch({
    required List<AppTableSearchRule> rules,
    required List<String> visibleKeys,
  }) async {
    final normalizedVisibleKeys = visibleKeys.where(_allKeys.contains).toList();
    _searchRules = rules;
    _visibleKeys
      ..clear()
      ..addAll(normalizedVisibleKeys.isEmpty ? _allKeys : normalizedVisibleKeys);
    _currentPage = 1;
    notifyListeners();
    await fakeFetchPage();
  }

  Future<void> resetSearch() async {
    _searchRules = const [];
    _visibleKeys
      ..clear()
      ..addAll(_allKeys);
    _currentPage = 1;
    notifyListeners();
    await fakeFetchPage();
  }

  String labelForKey(String key) {
    return switch (key) {
      'nama' => 'Nama',
      'nip' => 'NIP',
      'bidang' => 'Bidang',
      'pangkat_golongan' => 'Pangkat / Golongan',
      'no_whatsapp' => 'No. WhatsApp',
      'status' => 'Status',
      'aksi' => 'Aksi',
      _ => key,
    };
  }

  Future<void> changeRowsPerPage(int value) async {
    _rowsPerPage = value;
    _currentPage = 1;
    notifyListeners();
    await fakeFetchPage();
  }

  Future<void> changePage(int value) async {
    _currentPage = value.clamp(1, maxPage);
    notifyListeners();
    await fakeFetchPage();
  }

  Map<String, dynamic> _toViewItem(Map<String, dynamic> api) {
    return {
      'nama': api['name'] ?? '-',
      'nip': api['email'] ?? '-',
      'bidang': api['id_department'] ?? '-',
      'pangkat_golongan': api['id_jabatan'] ?? '-',
      'no_whatsapp': api['no_wa'] ?? '-',
      'status': 'Aktif',
      'aksi': 'Edit Data',
    };
  }

  List<Map<String, dynamic>> get _expandedItems => _apiItems.map(_toViewItem).toList();

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchRules.isEmpty) return _expandedItems;
    return _expandedItems.where(_matchesAllRules).toList();
  }

  bool _matchesAllRules(Map<String, dynamic> item) {
    for (final rule in _searchRules) {
      final raw = (item[rule.key] ?? '').toString();
      final value = rule.value.trim();
      if (value.isEmpty) continue;
      final source = raw.toLowerCase();
      final query = value.toLowerCase();
      final method = rule.method.trim().toLowerCase();
      final compareValue = _compareValues(raw, value);

      final matched = switch (method) {
        'like' => source.contains(query),
        'in' => _splitListValue(value).contains(source),
        'not in' => !_splitListValue(value).contains(source),
        '>' => compareValue != null && compareValue > 0,
        '>=' => compareValue != null && compareValue >= 0,
        '<' => compareValue != null && compareValue < 0,
        '<=' => compareValue != null && compareValue <= 0,
        '!=' || '<>' => source != query,
        _ => source == query,
      };
      if (!matched) return false;
    }
    return true;
  }

  int? _compareValues(String source, String query) {
    final sourceNum = double.tryParse(source.trim());
    final queryNum = double.tryParse(query.trim());
    if (sourceNum != null && queryNum != null) {
      return sourceNum.compareTo(queryNum);
    }

    final sourceDate = DateTime.tryParse(source.trim());
    final queryDate = DateTime.tryParse(query.trim());
    if (sourceDate != null && queryDate != null) {
      return sourceDate.compareTo(queryDate);
    }

    return source.toLowerCase().compareTo(query.toLowerCase());
  }

  Set<String> _splitListValue(String value) {
    return value
        .split(RegExp(r'[,;]'))
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  List<Map<String, dynamic>> get _apiItems {
    return List<Map<String, dynamic>>.generate(12, (index) {
      final no = index + 1;
      return {
        ..._apiBaseItem,
        'id': 'id-$no',
        'name': 'Admin PSIP $no',
        'username': 'admin$no',
        'id_department': 'DEP-${(no % 4) + 1}',
        'id_jabatan': 'JAB-${(no % 3) + 1}',
        'no_wa': '08373665${(640 + no).toString().padLeft(4, '0')}',
        'email': 'admin$no@contoh.id',
      };
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
