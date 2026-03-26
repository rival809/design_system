import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../buttons/primary_button.dart';
import '../chips/app_chip.dart';

/// Pagination behavior mode for [AppBaseTable].
enum AppBaseTablePaginationMode {
  /// Pagination is handled inside the widget from [AppBaseTableData.items].
  frontend,

  /// Pagination is handled by API/backend using callbacks and current page data.
  backend,
}

/// Column auto-size behavior for [AppBaseTable].
enum AppBaseTableColumnScaleMode {
  /// Keep original width behavior, no auto scaling.
  none,

  /// Fill available width proportionally.
  fill,

  /// Fill available width with equal column sizes.
  equal,

  /// Fill available width using Trina's proportional scale mode.
  scale,
}

/// Builder for action cell content.
///
/// Use this to render custom action UI per row, e.g. one button,
/// two buttons, or a dropdown menu.
typedef AppBaseTableActionRenderer = Widget Function(TrinaColumnRendererContext context);

/// Column schema received from API under `data.keys`.
class AppBaseTableKey {
  const AppBaseTableKey({required this.key, this.method = const [], this.helper = const []});

  final String key;
  final List<String> method;
  final List<String> helper;

  factory AppBaseTableKey.fromJson(Map<String, dynamic> json) {
    return AppBaseTableKey(
      key: (json['key'] ?? '').toString(),
      method: ((json['method'] as List?) ?? const []).map((e) => e.toString()).toList(),
      helper: ((json['helper'] as List?) ?? const []).map((e) => e.toString()).toList(),
    );
  }
}

/// Payload received from API under `data`.
class AppBaseTableData {
  const AppBaseTableData({
    required this.keys,
    required this.items,
    this.totalRows,
    this.maxPage,
    this.currentPage,
  });

  final List<AppBaseTableKey> keys;
  final List<Map<String, dynamic>> items;
  final int? totalRows;
  final int? maxPage;
  final int? currentPage;

  factory AppBaseTableData.fromJson(Map<String, dynamic> json) {
    return AppBaseTableData(
      keys: ((json['keys'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => AppBaseTableKey.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      totalRows: _tryInt(json['total_rows']),
      maxPage: _tryInt(json['max_page']),
      currentPage: _tryInt(json['current_page']),
    );
  }
}

/// Full response parser for API structures containing a `data` field.
class AppBaseTableResponse {
  const AppBaseTableResponse({
    required this.code,
    required this.success,
    required this.data,
    this.message,
  });

  final String code;
  final bool success;
  final AppBaseTableData data;
  final String? message;

  factory AppBaseTableResponse.fromJson(Map<String, dynamic> json) {
    return AppBaseTableResponse(
      code: (json['code'] ?? '').toString(),
      success: json['success'] == true,
      data: AppBaseTableData.fromJson(
        Map<String, dynamic>.from((json['data'] as Map?) ?? const {}),
      ),
      message: json['message']?.toString(),
    );
  }
}

/// Base table widget powered by TrinaGrid.
///
/// Supports API payload shape:
/// `data.keys` for columns and `data.items` for rows.
///
/// Customize action column rendering with [actionRenderer], for example:
/// - single button
/// - two inline buttons
/// - dropdown action menu
class AppBaseTable extends StatefulWidget {
  const AppBaseTable({
    super.key,
    required this.data,
    this.height = 420,
    this.readOnly = true,
    this.showMetaFooter = true,
    this.headerHeight = 44,
    this.rowHeight = 44,
    this.emptyLabel = 'Data tidak ditemukan',
    this.rowsPerPage = 10,
    this.rowsPerPageOptions = const [10, 25, 50],
    this.onRowsPerPageChanged,
    this.onPageChanged,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.paginationMode = AppBaseTablePaginationMode.frontend,
    this.columnScaleMode = AppBaseTableColumnScaleMode.fill,
    this.actionRenderer,
    this.actionFieldNames = const {'aksi', 'action', 'actions'},
  });

  factory AppBaseTable.fromResponseJson(
    Map<String, dynamic> json, {
    Key? key,
    double height = 420,
    bool readOnly = true,
    bool showMetaFooter = true,
    double headerHeight = 44,
    double rowHeight = 44,
    String emptyLabel = 'Data tidak ditemukan',
    int rowsPerPage = 10,
    List<int> rowsPerPageOptions = const [10, 25, 50],
    ValueChanged<int>? onRowsPerPageChanged,
    ValueChanged<int>? onPageChanged,
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    AppBaseTablePaginationMode paginationMode = AppBaseTablePaginationMode.frontend,
    AppBaseTableColumnScaleMode columnScaleMode = AppBaseTableColumnScaleMode.fill,
    AppBaseTableActionRenderer? actionRenderer,
    Set<String> actionFieldNames = const {'aksi', 'action', 'actions'},
  }) {
    final response = AppBaseTableResponse.fromJson(json);
    return AppBaseTable(
      key: key,
      data: response.data,
      height: height,
      readOnly: readOnly,
      showMetaFooter: showMetaFooter,
      headerHeight: headerHeight,
      rowHeight: rowHeight,
      emptyLabel: emptyLabel,
      rowsPerPage: rowsPerPage,
      rowsPerPageOptions: rowsPerPageOptions,
      onRowsPerPageChanged: onRowsPerPageChanged,
      onPageChanged: onPageChanged,
      headerBackgroundColor: headerBackgroundColor,
      headerForegroundColor: headerForegroundColor,
      paginationMode: paginationMode,
      columnScaleMode: columnScaleMode,
      actionRenderer: actionRenderer,
      actionFieldNames: actionFieldNames,
    );
  }

  final AppBaseTableData data;
  final double height;
  final bool readOnly;
  final bool showMetaFooter;
  final double headerHeight;
  final double rowHeight;
  final String emptyLabel;
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final ValueChanged<int>? onRowsPerPageChanged;
  final ValueChanged<int>? onPageChanged;
  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;
  final AppBaseTablePaginationMode paginationMode;
  final AppBaseTableColumnScaleMode columnScaleMode;
  final AppBaseTableActionRenderer? actionRenderer;
  final Set<String> actionFieldNames;

  @override
  State<AppBaseTable> createState() => _AppBaseTableState();
}

class _AppBaseTableState extends State<AppBaseTable> {
  late int _frontendRowsPerPage;
  late int _frontendCurrentPage;

  @override
  void initState() {
    super.initState();
    _frontendRowsPerPage = widget.rowsPerPage;
    _frontendCurrentPage = 1;
  }

  @override
  void didUpdateWidget(covariant AppBaseTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowsPerPage != widget.rowsPerPage) {
      _frontendRowsPerPage = widget.rowsPerPage;
      _frontendCurrentPage = 1;
    }
  }

  bool _isActionColumn(String normalizedKey) {
    final normalized = widget.actionFieldNames.map((e) => e.toLowerCase());
    return normalized.contains(normalizedKey);
  }

  List<TrinaColumn> _buildColumns(Color bgColor) {
    return widget.data.keys.map((k) {
      final normalized = k.key.toLowerCase();
      return TrinaColumn(
        title: _titleFromKey(k.key),
        field: k.key,
        type: TrinaColumnType.text(),
        enableSorting: true,
        backgroundColor: bgColor,
        titlePadding: const EdgeInsets.symmetric(horizontal: 14),
        titleTextAlign: normalized == 'status' || _isActionColumn(normalized)
            ? TrinaColumnTextAlign.center
            : TrinaColumnTextAlign.left,
        textAlign: normalized == 'status' || _isActionColumn(normalized)
            ? TrinaColumnTextAlign.center
            : TrinaColumnTextAlign.left,
        renderer: (ctx) {
          if (normalized == 'status') {
            return Center(
              child: AppChip(
                label: ctx.cell.value.toString(),
                variant: ChipVariant.green,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            );
          }

          if (_isActionColumn(normalized)) {
            if (widget.actionRenderer != null) {
              return widget.actionRenderer!(ctx);
            }

            return Center(
              child: PrimaryButton(
                label: ctx.cell.value.toString(),
                variant: ButtonVariant.secondary,
                size: ButtonSize.small,
                onPressed: () {},
              ),
            );
          }

          return Text(ctx.cell.value.toString(), overflow: TextOverflow.ellipsis, maxLines: 2);
        },
      );
    }).toList();
  }

  List<TrinaRow> _buildRows(List<Map<String, dynamic>> items) {
    return items
        .map(
          (item) => TrinaRow(
            cells: {
              for (final k in widget.data.keys)
                k.key: TrinaCell(value: item[k.key] == null ? '' : item[k.key].toString()),
            },
          ),
        )
        .toList();
  }

  TrinaAutoSizeMode _resolveAutoSizeMode() {
    return switch (widget.columnScaleMode) {
      AppBaseTableColumnScaleMode.none => TrinaAutoSizeMode.none,
      AppBaseTableColumnScaleMode.equal => TrinaAutoSizeMode.equal,
      AppBaseTableColumnScaleMode.scale => TrinaAutoSizeMode.scale,
      AppBaseTableColumnScaleMode.fill => TrinaAutoSizeMode.scale,
    };
  }

  void _onRowsPerPageChanged(int value) {
    if (widget.paginationMode == AppBaseTablePaginationMode.frontend) {
      setState(() {
        _frontendRowsPerPage = value;
        _frontendCurrentPage = 1;
      });
    }
    widget.onRowsPerPageChanged?.call(value);
  }

  void _onPageChanged(int value, int maxPage) {
    final safePage = value.clamp(1, maxPage);
    if (widget.paginationMode == AppBaseTablePaginationMode.frontend) {
      setState(() {
        _frontendCurrentPage = safePage;
      });
    }
    widget.onPageChanged?.call(safePage);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final headerBg = widget.headerBackgroundColor ?? cs.primary;
    final headerFg = widget.headerForegroundColor ?? cs.onPrimary;
    final selectedRowColor = isDark
        ? cs.primary.withValues(alpha: 0.20)
        : cs.primary.withValues(alpha: 0.12);
    final activeBorderColor = isDark
        ? cs.primary.withValues(alpha: 0.72)
        : cs.primary.withValues(alpha: 0.85);
    final inactiveBorderColor = isDark ? cs.outline.withValues(alpha: 0.55) : cs.outline;

    final totalRows = widget.paginationMode == AppBaseTablePaginationMode.frontend
        ? widget.data.items.length
        : (widget.data.totalRows ?? widget.data.items.length);

    final effectiveRowsPerPage = widget.paginationMode == AppBaseTablePaginationMode.frontend
        ? _frontendRowsPerPage
        : widget.rowsPerPage;

    final maxPageRaw = widget.paginationMode == AppBaseTablePaginationMode.frontend
        ? (totalRows / effectiveRowsPerPage).ceil()
        : (widget.data.maxPage ?? 1);
    final maxPage = maxPageRaw < 1 ? 1 : maxPageRaw;

    final currentPageRaw = widget.paginationMode == AppBaseTablePaginationMode.frontend
        ? _frontendCurrentPage
        : (widget.data.currentPage ?? 1);
    final currentPage = currentPageRaw < 1
        ? 1
        : (currentPageRaw > maxPage ? maxPage : currentPageRaw);

    if (widget.data.keys.isEmpty) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outline),
        ),
        alignment: Alignment.center,
        child: Text('Table keys tidak tersedia', style: tt.bodyMedium),
      );
    }

    final columns = _buildColumns(headerBg);
    final visibleItems = widget.paginationMode == AppBaseTablePaginationMode.frontend
        ? () {
            final start = (currentPage - 1) * effectiveRowsPerPage;
            final end = (start + effectiveRowsPerPage).clamp(0, widget.data.items.length);
            if (start >= widget.data.items.length) return <Map<String, dynamic>>[];
            return widget.data.items.sublist(start, end);
          }()
        : widget.data.items;
    final rows = _buildRows(visibleItems);

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                TrinaGrid(
                  key: ValueKey(
                    '${widget.data.keys.map((e) => e.key).join('|')}|${rows.length}|$currentPage|$effectiveRowsPerPage',
                  ),
                  columns: columns,
                  rows: rows,
                  mode: widget.readOnly ? TrinaGridMode.readOnly : TrinaGridMode.normal,
                  configuration: TrinaGridConfiguration(
                    columnSize: TrinaGridColumnSizeConfig(autoSizeMode: _resolveAutoSizeMode()),
                    style: TrinaGridStyleConfig(
                      gridPadding: 0,
                      gridBackgroundColor: cs.surface,
                      rowColor: cs.surface,
                      oddRowColor: cs.surface,
                      evenRowColor: cs.surface,
                      activatedColor: selectedRowColor,
                      activatedBorderColor: activeBorderColor,
                      inactivatedBorderColor: inactiveBorderColor,
                      cellColorInReadOnlyState: cs.surface,
                      borderColor: cs.outline,
                      gridBorderColor: Colors.transparent,
                      gridBorderWidth: 0,
                      rowHeight: widget.rowHeight,
                      columnHeight: widget.headerHeight,
                      columnTextStyle:
                          tt.titleSmall?.copyWith(color: headerFg, fontWeight: FontWeight.w700) ??
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      cellTextStyle: tt.bodyMedium ?? const TextStyle(fontSize: 14),
                      gridBorderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (rows.isEmpty)
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outline),
                        ),
                        child: Text(widget.emptyLabel, style: tt.bodyMedium),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.showMetaFooter)
            _MetaFooter(
              totalRows: totalRows,
              rowsPerPage: effectiveRowsPerPage,
              rowsPerPageOptions: widget.rowsPerPageOptions,
              currentPage: currentPage,
              maxPage: maxPage,
              onRowsPerPageChanged: _onRowsPerPageChanged,
              onPageChanged: (page) => _onPageChanged(page, maxPage),
              enableRowsPerPageControl:
                  widget.paginationMode == AppBaseTablePaginationMode.frontend ||
                  widget.onRowsPerPageChanged != null,
              enablePageControl:
                  widget.paginationMode == AppBaseTablePaginationMode.frontend ||
                  widget.onPageChanged != null,
            ),
        ],
      ),
    );
  }
}

class _MetaFooter extends StatelessWidget {
  const _MetaFooter({
    required this.totalRows,
    required this.rowsPerPage,
    required this.rowsPerPageOptions,
    required this.currentPage,
    required this.maxPage,
    required this.enableRowsPerPageControl,
    required this.enablePageControl,
    this.onRowsPerPageChanged,
    this.onPageChanged,
  });

  final int totalRows;
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final int currentPage;
  final int maxPage;
  final bool enableRowsPerPageControl;
  final bool enablePageControl;
  final ValueChanged<int>? onRowsPerPageChanged;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final usePageDropdown = maxPage <= 20;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                Text('Tampilkan', style: tt.bodySmall),
                _BorderedDropdown<int>(
                  value: rowsPerPage,
                  items: rowsPerPageOptions.toSet().toList()..sort(),
                  enabled: enableRowsPerPageControl,
                  onChanged: enableRowsPerPageControl ? onRowsPerPageChanged : null,
                  itemLabel: (v) => '$v',
                ),
                Text('Item', style: tt.bodySmall),
                Text('dari total', style: tt.bodySmall),
                Text('$totalRows', style: tt.titleSmall),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                Text('Halaman', style: tt.bodySmall),
                if (usePageDropdown)
                  _BorderedDropdown<int>(
                    value: currentPage,
                    items: List<int>.generate(maxPage, (index) => index + 1),
                    enabled: enablePageControl,
                    onChanged: enablePageControl ? onPageChanged : null,
                    itemLabel: (v) => '$v',
                  )
                else
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(6),
                      color: cs.surfaceContainerLow,
                    ),
                    child: Text('$currentPage', style: tt.bodySmall),
                  ),
                Text('dari', style: tt.bodySmall),
                Text('$maxPage', style: tt.titleSmall),
                _FooterIconButton(
                  icon: Icons.chevron_left,
                  enabled: enablePageControl && currentPage > 1,
                  onTap: onPageChanged == null ? null : () => onPageChanged!(currentPage - 1),
                ),
                _FooterIconButton(
                  icon: Icons.chevron_right,
                  enabled: enablePageControl && currentPage < maxPage,
                  onTap: onPageChanged == null ? null : () => onPageChanged!(currentPage + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BorderedDropdown<T> extends StatelessWidget {
  const _BorderedDropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    this.enabled = true,
    this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final bool enabled;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        // border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(6),
        color: enabled ? cs.surface : cs.surfaceContainerLow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: tt.bodySmall,
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          ],
          onChanged: !enabled
              ? null
              : (value) {
                  if (value != null) {
                    onChanged?.call(value);
                  }
                },
        ),
      ),
    );
  }
}

class _FooterIconButton extends StatelessWidget {
  const _FooterIconButton({required this.icon, required this.enabled, this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(6),
          color: enabled ? cs.surface : cs.surfaceContainerLow,
        ),
        child: Icon(icon, size: 18, color: enabled ? cs.primary : cs.onSurfaceVariant),
      ),
    );
  }
}

String _titleFromKey(String key) {
  if (key.isEmpty) return key;
  final parts = key.split('_').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return key;
  return parts
      .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}

int? _tryInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
