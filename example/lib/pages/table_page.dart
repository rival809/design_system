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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TablePageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TablePageController()..addListener(_onControllerChanged);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 992;

  Future<void> _openSearchForm() async {
    if (_isDesktop(context)) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.92;
        return SizedBox(
          height: maxHeight,
          child: AppTableSearchForm(
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
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _isDesktop(context)
          ? SizedBox(
              width: 460,
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
            )
          : null,
      body: SingleChildScrollView(
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
                PrimaryButton(
                  label: 'Filter Pencarian',
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.small,
                  leadingIcon: const Icon(Icons.filter_alt_outlined),
                  onPressed: _openSearchForm,
                ),
                PrimaryButton(
                  label: 'Reset Filter',
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.small,
                  onPressed: _controller.resetSearch,
                ),
                Text('Rules: ${_controller.searchRules.length}', style: tt.bodySmall),
              ],
            ),
            if (_controller.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 12),
            AppBaseTable(
              key: ValueKey(
                'table-${_controller.currentPage}-${_controller.rowsPerPage}-${_controller.serverItems.length}-${_controller.visibleKeys.join(',')}-${_controller.isLoading}-${_controller.searchRules.length}',
              ),
              data: _controller.tableData,
              height: MediaQuery.of(context).size.height - 400,
              paginationMode: AppBaseTablePaginationMode.backend,
              columnScaleMode: AppBaseTableColumnScaleMode.fill,
              actionRenderer: _buildActionRenderer,
              rowsPerPage: _controller.rowsPerPage,
              rowsPerPageOptions: const [10],
              onRowsPerPageChanged: _controller.changeRowsPerPage,
              onPageChanged: _controller.changePage,
            ),
          ],
        ),
      ),
    );
  }
}
