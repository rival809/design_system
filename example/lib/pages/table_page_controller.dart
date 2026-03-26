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

  static const List<Map<String, Object?>> _departmentHelpers = [
    {
      'department_id': '5f2b16a1-e9fc-4c6e-bc91-e10bc2353886',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Indramayu I',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '31080ca7-3221-45d2-ae0a-017cd0352e73',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Indramayu II Haurgeulis',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '301c64d0-164d-4544-9e8d-52143621bdaa',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Kuningan',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '36ce7988-2657-4091-9991-260c1461a4ae',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Majalengka',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '43e4a4dc-dc7c-4e4e-8b0a-cca20842140b',
      'department_name': 'Bidang Pengelola Pendapatan',
      'department_kd_wil': '19900',
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '931ff84c-0c90-4080-862c-723e76fcd5a5',
      'department_name': 'Bidang Pengelola Sistem Informasi Pendapatan',
      'department_kd_wil': '19900',
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '4926867e-3d6a-4081-9e19-c6d2f751a20b',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Depok I',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '5103f019-6c45-492f-b111-e714d9b7a814',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Depok II Cinere',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'fc5fc7a8-927e-42b3-898a-3c8fe3af0b95',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Bogor',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '2f195ebb-bf23-4151-b2be-30cfaef0a04c',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Bogor',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'a986167b-db3b-4fbf-98b0-7ee8f4de8808',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Sukabumi',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '7bae20e4-018d-42b8-ae80-1904b519cb4a',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Sukabumi I Cibadak',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'a09394f9-8871-4a1f-b788-ce11e69bd366',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Sukabumi II Pelabuhan Ratu',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '3bd73787-c1f2-4e1d-8499-6a3b5ddd15ca',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Cianjur',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '2d8b4ed7-c94b-41a0-b116-33f49fab6e7a',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Bekasi',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'd9d0c6e8-e615-4c16-bfd3-bb4dfb398281',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Bekasi',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'f8f8d2d1-eda8-44e5-bc66-e59bd760f857',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Karawang',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'ee5a6801-cb85-460c-b5f0-df347995f15a',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Purwakarta',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '989fbfa0-2d6e-45f9-a106-19c18a208934',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Subang',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'b40738ff-cbff-46a0-a7e5-a680e46070cb',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Cirebon',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '9916bdd6-86a2-422a-92c8-2e22fa742230',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Cirebon I Sumber',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'd4135473-f7ed-40b0-bafc-a9ea1a064df5',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Cirebon II Ciledug',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '5b4b1f03-ab34-41dc-b4fd-fe937e010657',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Bandung I Pajajaran',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'bbbe26fc-a6e8-422e-9bf8-3ad4d1973812',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Bandung II Kawaluyaan',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '592f264b-3760-4fc4-9618-597b27df6761',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Bandung III Soekarno Hatta',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'b78aa69d-a458-4beb-a4b9-e043e84aed01',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Bandung Barat',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '7af743c1-28df-49b8-8a89-19246e4c19e9',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Bandung I Rancaekek',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'ccc10893-6379-45b7-b2ad-f2614aeb8fcb',
      'department_name':
          'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Bandung II Soreang',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '16c90928-d02d-4da1-ae89-b4cdf1a9c51f',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Sumedang',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '575c334f-f070-437f-828c-58ce4a1e9330',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Garut',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '9ca91402-2eb3-4894-b18b-8e03a973f508',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Tasikmalaya',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '14027ab4-eec7-4d65-81b9-06fea6bec57c',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Tasikmalaya',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '600603e1-abe2-4827-8565-1ffcef16143e',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Ciamis',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'dbfb7287-4e52-403f-b298-579c2ed554c7',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kabupaten Pangandaran',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '6e1790f4-f27e-4dff-809b-7503ed3f91e8',
      'department_name': 'UPTD Pusat Pengelolaan Pendapatan Daerah Wilayah Kota Cimahi',
      'department_kd_wil': null,
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': 'a9f55450-326a-4960-9df8-0373c123ca75',
      'department_name': 'Sekretariat',
      'department_kd_wil': '19900',
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '4f21979e-557c-4ec0-ad63-f9b9eda3cd63',
      'department_name': 'Bidang Perencanaan dan Pengembangan',
      'department_kd_wil': '19900',
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '17f1f9b5-ab99-449b-a06b-3c58cebca568',
      'department_name': 'Bidang Pengendalian dan Evaluasi',
      'department_kd_wil': '19900',
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
    {
      'department_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
      'department_name': 'Kepala Badan Pendapatan Daerah Provinsi Jawa Barat',
      'department_kd_wil': '19900',
      'department_parent_id': '23011f89-4008-4c2c-acb7-74b6b64c14c4',
    },
  ];

  static const List<AppBaseTableKey> _searchKeys = [
    AppBaseTableKey(key: 'nama', method: _supportedMethods, helper: []),
    AppBaseTableKey(key: 'nip', method: _supportedMethods, helper: []),
    AppBaseTableKey(key: 'bidang', method: _supportedMethods, helper: _departmentHelpers),
    AppBaseTableKey(key: 'pangkat_golongan', method: _supportedMethods, helper: []),
    AppBaseTableKey(key: 'no_whatsapp', method: _supportedMethods, helper: []),
    AppBaseTableKey(key: 'status', method: _supportedMethods, helper: []),
    AppBaseTableKey(key: 'aksi', method: _supportedMethods, helper: []),
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
    final idDepartment = api['id_department'];
    String bidangName = idDepartment?.toString() ?? '-';

    if (idDepartment != null) {
      final helper = _departmentHelpers
          .where((h) => h['department_id'] == idDepartment)
          .firstOrNull;

      if (helper != null) {
        bidangName = helper['department_name']?.toString() ?? bidangName;
      }
    }

    return {
      'nama': api['name'] ?? '-',
      'nip': api['email'] ?? '-',
      'bidang': bidangName,
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
      final department = _departmentHelpers[index % _departmentHelpers.length];
      return {
        ..._apiBaseItem,
        'id': 'id-$no',
        'name': 'Admin PSIP $no',
        'username': 'admin$no',
        'id_department': department['department_id'],
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
