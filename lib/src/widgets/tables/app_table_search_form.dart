import 'package:flutter/material.dart';

import '../buttons/primary_button.dart';
import '../dropdowns/app_searchable_dropdown.dart';
import '../text_fields/app_text_field.dart';
import 'app_base_table.dart';
import 'table_utils.dart';

class AppTableSearchRule {
  const AppTableSearchRule({required this.key, required this.method, required this.value});

  final String key;
  final String method;
  final String value;
}

typedef AppTableSearchSubmit =
    void Function(List<AppTableSearchRule> rules, List<String> visibleKeys);

class AppTableSearchForm extends StatefulWidget {
  const AppTableSearchForm({
    super.key,
    required this.keys,
    this.title = 'Cari data berdasarkan',
    this.resetLabel = 'Reset Pencarian',
    this.valueHint = 'Text Placeholder',
    this.visibleColumnsHint = 'Pilih Data Yang Ingin Ditampilkan',
    this.addAspectLabel = 'Tambah Aspek Pencarian',
    this.searchLabel = 'Cari Data',
    this.initialVisibleKeys,
    this.onSubmit,
    this.onReset,
    this.hugContent = false,
  });

  final List<AppBaseTableKey> keys;
  final String title;
  final String resetLabel;
  final String valueHint;
  final String visibleColumnsHint;
  final String addAspectLabel;
  final String searchLabel;
  final List<String>? initialVisibleKeys;
  final AppTableSearchSubmit? onSubmit;
  final VoidCallback? onReset;
  final bool hugContent;

  @override
  State<AppTableSearchForm> createState() => _AppTableSearchFormState();
}

class _AppTableSearchFormState extends State<AppTableSearchForm> {
  late final Map<String, AppBaseTableKey> _keyMap;
  late final List<String> _orderedKeys;
  late Set<String> _visibleKeys;
  final List<_SearchRowModel> _rows = [];

  @override
  void initState() {
    super.initState();
    _keyMap = {for (final key in widget.keys) key.key: key};
    _orderedKeys = widget.keys.map((e) => e.key).toList();
    _visibleKeys = {...((widget.initialVisibleKeys ?? _orderedKeys).where(_keyMap.containsKey))};
    if (_visibleKeys.isEmpty) {
      _visibleKeys = {..._orderedKeys};
    }
    _addRow();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.controller.dispose();
    }
    super.dispose();
  }

  List<String> _methodOptions(String key) {
    final methods = (_keyMap[key]?.method ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (methods.isEmpty) return const ['='];
    return methods;
  }

  List<_HelperOption> _helperOptions(String key) {
    final raw = _keyMap[key]?.helper ?? const <Object?>[];
    final options = raw.map(_toHelperOption).whereType<_HelperOption>().toList();
    return options;
  }

  _HelperOption? _toHelperOption(Object? helper) {
    if (helper == null) return null;

    if (helper is String) {
      final value = helper.trim();
      if (value.isEmpty) return null;
      return _HelperOption(value: value, label: value);
    }

    if (helper is num || helper is bool) {
      final value = helper.toString();
      return _HelperOption(value: value, label: value);
    }

    if (helper is Map) {
      final map = Map<String, dynamic>.from(helper);
      // Supported value keys (in priority order):
      // {value, id, key, code, helper_id} for the submitted value.
      // {label, name, text, title, helper_name} for the display label.
      final rawValue =
          map['value'] ??
          map['id'] ??
          map['key'] ??
          map['code'] ??
          map['helper_id'];
      final rawLabel =
          map['label'] ??
          map['name'] ??
          map['text'] ??
          map['title'] ??
          map['helper_name'] ??
          rawValue;
      final value = rawValue?.toString().trim();
      final label = rawLabel?.toString().trim();
      if (value == null || value.isEmpty) return null;
      return _HelperOption(value: value, label: (label == null || label.isEmpty) ? value : label);
    }

    final fallback = helper.toString().trim();
    if (fallback.isEmpty) return null;
    return _HelperOption(value: fallback, label: fallback);
  }

  void _addRow() {
    if (_orderedKeys.isEmpty) return;
    final key = _orderedKeys.first;
    final methods = _methodOptions(key);
    final helperOptions = _helperOptions(key);
    setState(() {
      _rows.add(
        _SearchRowModel(
          selectedKey: key,
          selectedMethod: methods.first,
          controller: TextEditingController(),
          selectedHelperValue: helperOptions.isEmpty ? null : helperOptions.first.value,
        ),
      );
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      final row = _rows.removeAt(index);
      row.controller.dispose();
    });
  }

  void _reset() {
    for (final row in _rows) {
      row.controller.dispose();
    }
    _rows.clear();
    _visibleKeys = {..._orderedKeys};
    _addRow();
    widget.onReset?.call();
  }

  void _submit() {
    final rules = _rows
        .map(
          (row) => AppTableSearchRule(
            key: row.selectedKey,
            method: row.selectedMethod,
            value: row.selectedHelperValue ?? row.controller.text.trim(),
          ),
        )
        .where((row) => row.value.isNotEmpty)
        .toList();

    final visibleKeys = _orderedKeys.where(_visibleKeys.contains).toList();
    widget.onSubmit?.call(rules, visibleKeys);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: widget.hugContent ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(onPressed: _reset, child: Text(widget.resetLabel)),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            fit: widget.hugContent ? FlexFit.loose : FlexFit.tight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < _rows.length; i++) ...[
                    _SearchAspectRow(
                      keyOptions: _orderedKeys,
                      selectedKey: _rows[i].selectedKey,
                      selectedMethod: _rows[i].selectedMethod,
                      keyLabelBuilder: titleFromKey,
                      methodOptions: _methodOptions(_rows[i].selectedKey),
                      helperOptions: _helperOptions(_rows[i].selectedKey),
                      selectedHelperValue: _rows[i].selectedHelperValue,
                      valueHint: widget.valueHint,
                      controller: _rows[i].controller,
                      canRemove: _rows.length > 1,
                      onKeyChanged: (value) {
                        final methods = _methodOptions(value);
                        final helperOptions = _helperOptions(value);
                        setState(() {
                          _rows[i].selectedKey = value;
                          if (!methods.contains(_rows[i].selectedMethod)) {
                            _rows[i].selectedMethod = methods.first;
                          }
                          _rows[i].selectedHelperValue = helperOptions.isEmpty
                              ? null
                              : helperOptions.first.value;
                        });
                      },
                      onMethodChanged: (value) {
                        setState(() => _rows[i].selectedMethod = value);
                      },
                      onHelperValueChanged: (value) {
                        setState(() => _rows[i].selectedHelperValue = value);
                      },
                      onRemove: () => _removeRow(i),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        if (_visibleKeys.contains(value)) {
                          if (_visibleKeys.length > 1) {
                            _visibleKeys.remove(value);
                          }
                        } else {
                          _visibleKeys.add(value);
                        }
                      });
                    },
                    itemBuilder: (context) => [
                      for (final key in _orderedKeys)
                        CheckedPopupMenuItem<String>(
                          value: key,
                          checked: _visibleKeys.contains(key),
                          child: Text(titleFromKey(key)),
                        ),
                    ],
                    child: _SelectBox(
                      label: _visibleKeys.length == _orderedKeys.length
                          ? widget.visibleColumnsHint
                          : 'Tampil ${_visibleKeys.length} kolom',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: widget.addAspectLabel,
              variant: ButtonVariant.outlined,
              leadingIcon: const Icon(Icons.add),
              onPressed: _addRow,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: widget.searchLabel, onPressed: _submit),
          ),
        ],
      ),
    );
  }
}

class _SearchAspectRow extends StatelessWidget {
  const _SearchAspectRow({
    required this.keyOptions,
    required this.selectedKey,
    required this.selectedMethod,
    required this.keyLabelBuilder,
    required this.methodOptions,
    required this.helperOptions,
    required this.selectedHelperValue,
    required this.valueHint,
    required this.controller,
    required this.canRemove,
    required this.onKeyChanged,
    required this.onMethodChanged,
    required this.onHelperValueChanged,
    required this.onRemove,
  });

  final List<String> keyOptions;
  final String selectedKey;
  final String selectedMethod;
  final String Function(String value) keyLabelBuilder;
  final List<String> methodOptions;
  final List<_HelperOption> helperOptions;
  final String? selectedHelperValue;
  final String valueHint;
  final TextEditingController controller;
  final bool canRemove;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String?> onHelperValueChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 48,
            child: AppSearchableDropdown<String>(
              hint: 'Nama',
              selectedItem: selectedKey,
              items: keyOptions,
              itemAsString: keyLabelBuilder,
              compareFn: (a, b) => a == b,
              selectedTextMode: AppDropdownTextMode.singleLine,
              popupItemTextMode: AppDropdownTextMode.singleLine,
              onChanged: (value) {
                if (value != null) onKeyChanged(value);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: AppSearchableDropdown<String>(
              hint: '=',
              selectedItem: selectedMethod,
              selectedTextMode: AppDropdownTextMode.singleLine,
              popupItemTextMode: AppDropdownTextMode.singleLine,
              items: methodOptions,
              compareFn: (a, b) => a == b,
              onChanged: (value) {
                if (value != null) onMethodChanged(value);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 48,
            child: helperOptions.isNotEmpty
                ? AppSearchableDropdown<String>(
                    hint: valueHint,
                    selectedItem: selectedHelperValue,
                    items: helperOptions.map((e) => e.value).toList(),
                    itemAsString: (value) {
                      final option = helperOptions.where((e) => e.value == value).firstOrNull;
                      return option?.label ?? value;
                    },
                    compareFn: (a, b) => a == b,
                    selectedTextMode: AppDropdownTextMode.singleLine,
                    popupItemTextMode: AppDropdownTextMode.multiLine,
                    onChanged: onHelperValueChanged,
                  )
                : AppTextField(controller: controller, hint: valueHint),
          ),
        ),
        if (canRemove) ...[
          const SizedBox(width: 8),
          SizedBox(width: 48, height: 48, child: _RemoveButton(onTap: onRemove)),
        ],
      ],
    );
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: cs.primary),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.error),
        ),
        child: Icon(Icons.close, color: cs.error),
      ),
    );
  }
}

class _SearchRowModel {
  _SearchRowModel({
    required this.selectedKey,
    required this.selectedMethod,
    required this.controller,
    this.selectedHelperValue,
  });

  String selectedKey;
  String selectedMethod;
  TextEditingController controller;
  String? selectedHelperValue;
}

class _HelperOption {
  const _HelperOption({required this.value, required this.label});

  final String value;
  final String label;
}

