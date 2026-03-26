import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'table_page_controller.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final GlobalKey<ScaffoldState> _desktopScaffoldKey = GlobalKey<ScaffoldState>();
  late final TablePageController _controller;
  final ScrollController _mobileScrollController = ScrollController();
  final TextEditingController _searchNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TablePageController()..addListener(_onControllerChanged);
    _controller.init();

    _mobileScrollController.addListener(() {
      if (_mobileScrollController.position.pixels >=
          _mobileScrollController.position.maxScrollExtent - 200) {
        _controller.loadNextPageMobile();
      }
    });
  }

  @override
  void dispose() {
    _searchNameController.dispose();
    _mobileScrollController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _applyBasicSearch() async {
    final keyword = _searchNameController.text.trim();
    if (keyword.isEmpty) {
      await _controller.resetSearch();
      return;
    }

    // Ganti rule jadi hanya filter berdasarkan name
    final rule = AppTableSearchRule(key: 'name', method: 'LIKE', value: keyword);
    await _controller.applySearch(rules: [rule], visibleKeys: _controller.visibleKeys.toList());
  }

  Future<void> _openMobileSearchForm() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: AppTableSearchForm(
            hugContent: true,
            keys: _controller.searchKeys,
            initialVisibleKeys: _controller.visibleKeys.toList(),
            onSubmit: (rules, visibleKeys) async {
              await _controller.applySearch(rules: rules, visibleKeys: visibleKeys);
              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();
            },
            onReset: () {
              _controller.resetSearch();
            },
          ),
        );
      },
    );
  }

  Widget _buildActionRenderer(TrinaColumnRendererContext ctx) {
    return switch (_controller.actionMode) {
      ActionMode.singleButton => PrimaryButton(
        label: 'Edit Data',
        variant: ButtonVariant.secondary,
        size: ButtonSize.small,
        onPressed: () {},
      ),
      ActionMode.doubleButton => Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: 'Edit',
              variant: ButtonVariant.secondary,
              size: ButtonSize.small,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: PrimaryButton(
              label: 'Hapus',
              variant: ButtonVariant.danger,
              size: ButtonSize.small,
              onPressed: () {},
            ),
          ),
        ],
      ),
      ActionMode.dropdown => PopupMenuButton<String>(
        tooltip: 'Aksi',
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'detail', child: Text('Detail')),
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'hapus', child: Text('Hapus')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Aksi'),
              SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ),
    };
  }

  // ---------------------------------------------------------------------------
  // DESKTOP LAYOUT (Table View)
  // ---------------------------------------------------------------------------
  Widget _buildDesktopLayout(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      key: _desktopScaffoldKey,
      endDrawer: SizedBox(
        width: 500,
        child: SafeArea(
          child: AppTableSearchForm(
            keys: _controller.searchKeys,
            initialVisibleKeys: _controller.visibleKeys.toList(),
            onSubmit: (rules, visibleKeys) async {
              await _controller.applySearch(rules: rules, visibleKeys: visibleKeys);
              if (!mounted) return;
              Navigator.of(context).maybePop();
            },
            onReset: () {
              _controller.resetSearch();
            },
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tableHeight = (constraints.maxHeight - 140).clamp(140.0, double.infinity);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Base Table', style: tt.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: AppTextField(
                        controller: _searchNameController,
                        hint: 'Cari berdasarkan nama...',
                        suffixIcon: InkWell(
                          onTap: _applyBasicSearch,
                          child: const Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _applyBasicSearch(),
                      ),
                    ),
                    PrimaryButton(
                      label: 'Filter Lanjutan',
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.small,
                      leadingIcon: const Icon(Icons.tune),
                      onPressed: () => _desktopScaffoldKey.currentState?.openEndDrawer(),
                    ),
                    if (_controller.searchRules.isNotEmpty) ...[
                      PrimaryButton(
                        label: 'Reset',
                        variant: ButtonVariant.secondary,
                        size: ButtonSize.small,
                        onPressed: () {
                          _searchNameController.clear();
                          _controller.resetSearch();
                        },
                      ),
                      Text('Rules: ${_controller.searchRules.length}', style: tt.bodySmall),
                    ],
                  ],
                ),
                if (_controller.isLoading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: 12),
                AppBaseTable(
                  key: ValueKey(
                    '${_controller.visibleKeys.join(',')}_${_controller.searchRules.length}',
                  ),
                  data: _controller.tableData,
                  height: tableHeight,
                  paginationMode: AppBaseTablePaginationMode.backend,
                  columnScaleMode: AppBaseTableColumnScaleMode.fill,
                  actionRenderer: _buildActionRenderer,
                  customColumnRenderers: {
                    'kd_wil': (ctx) => Center(
                      child: AppChip(
                        label: ctx.cell.value.toString(),
                        variant: ChipVariant.green,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                  },
                  rowsPerPage: _controller.rowsPerPage,
                  rowsPerPageOptions: const [10, 25, 50, 100, 250, 500, 1000],
                  onRowsPerPageChanged: _controller.changeRowsPerPage,
                  onPageChanged: _controller.changePage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE LAYOUT (List View)
  // ---------------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text(
          'Manajemen User',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: cs.outlineVariant, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchNameController,
                    hint: 'Cari',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    onSubmitted: (_) => _applyBasicSearch(),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8),
                      child: PrimaryButton(
                        onPressed: _applyBasicSearch,
                        trailingIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                PrimaryButton(
                  onPressed: _openMobileSearchForm,
                  trailingIcon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),

          if (_controller.isLoading) const LinearProgressIndicator(),

          // List Items
          Expanded(
            child: ListView.separated(
              controller: _mobileScrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _controller.mobileItems.length + (_controller.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _controller.mobileItems.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildMobileCard(_controller.mobileItems[index]);
              },
            ),
          ),
        ],
      ),
      // Sticky Bottom Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PrimaryButton(label: 'Tambah Data', onPressed: () {}),
        ),
      ),
    );
  }

  Widget _buildMobileCard(Map<String, dynamic> item) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final nama = item['name']?.toString() ?? '-';
    final nip = item['username']?.toString() ?? '-';
    final nmWil = item['nm_wil']?.toString() ?? '-';
    // Gunakan helper nm_role / nm_wilkerja utk display jabatan jika ada
    final jabatan = item['nm_role']?.toString() ?? nmWil;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Atas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(nip, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        jabatan,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          // Info Bawah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'Aktif',
                  style: tt.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Detail',
                        style: tt.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, size: 16, color: Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveLayout(
      mobile: _buildMobileLayout(context),
      desktop: _buildDesktopLayout(context),
      breakpoint: 992.0, // Match the previous _isDesktop width
    );
  }
}
