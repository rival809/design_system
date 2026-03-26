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

  static const List<String> _allKeys = [
    'nama',
    'nip',
    'bidang',
    'pangkat_golongan',
    'no_whatsapp',
    'status',
    'aksi',
  ];

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
  Set<String> get visibleKeys => UnmodifiableSetView(_visibleKeys);

  int get maxPage => (_expandedItems.length / _rowsPerPage).ceil().clamp(1, 9999);

  AppBaseTableData get tableData {
    final keys = _allKeys.where(_visibleKeys.contains).toList();
    return AppBaseTableData(
      keys: keys.map((key) => AppBaseTableKey(key: key)).toList(),
      items: _serverItems,
      totalRows: _expandedItems.length,
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

    final start = (_currentPage - 1) * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _expandedItems.length);
    final pageItems = start >= _expandedItems.length
        ? <Map<String, dynamic>>[]
        : _expandedItems.sublist(start, end);

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
