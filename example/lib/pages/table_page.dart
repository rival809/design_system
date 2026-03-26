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
              PopupMenuButton<String>(
                tooltip: 'Pilih kolom',
                onSelected: _controller.toggleVisibleColumn,
                itemBuilder: (context) => [
                  for (final key in _controller.allKeys)
                    CheckedPopupMenuItem<String>(
                      value: key,
                      checked: _controller.visibleKeys.contains(key),
                      child: Text(_controller.labelForKey(key)),
                    ),
                ],
                child: IgnorePointer(
                  child: PrimaryButton(
                    label: 'Kolom Tampil (${_controller.visibleKeys.length})',
                    variant: ButtonVariant.outlined,
                    size: ButtonSize.small,
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          if (_controller.isLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 12),
          AppBaseTable(
            key: ValueKey(
              'table-${_controller.currentPage}-${_controller.rowsPerPage}-${_controller.serverItems.length}-${_controller.visibleKeys.join(',')}-${_controller.isLoading}',
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
    );
  }
}
