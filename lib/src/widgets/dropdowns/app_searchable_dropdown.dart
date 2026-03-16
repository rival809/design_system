import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

// Re-export so callers don't need to import dropdown_search directly.
export 'package:dropdown_search/dropdown_search.dart' show DropdownSearchOnFind;

/// A theme-aware searchable dropdown widget built on top of [DropdownSearch].
///
/// Renders identically to [AppTextField] — same border radius, typography,
/// fill colour, and label/helper pattern — while adding a built-in search
/// field inside the popup.
///
/// **Synchronous list**
/// ```dart
/// AppSearchableDropdown<String>(
///   label: 'Departemen',
///   hint: 'Pilih departemen',
///   items: const ['Engineering', 'Design', 'Marketing'],
///   onChanged: (v) => setState(() => _dept = v),
/// )
/// ```
///
/// **Async items from API**
/// ```dart
/// AppSearchableDropdown<UserModel>(
///   label: 'User',
///   asyncItems: (query) => api.searchUsers(query),
///   itemAsString: (u) => u.fullName,
///   onChanged: (u) => setState(() => _user = u),
/// )
/// ```
class AppSearchableDropdown<T> extends StatelessWidget {
  /// Static label displayed above the field.
  final String? label;

  /// Placeholder text when nothing is selected.
  final String? hint;

  /// Helper text below the field.
  final String? helperText;

  /// Error message. When non-null the field enters the error state.
  final String? errorText;

  /// Synchronous list of items. Required when [asyncItems] is null.
  final List<T>? items;

  /// Async item loader called with the current search query.
  /// Required when [items] is null.
  final DropdownSearchOnFind<T>? asyncItems;

  /// Converts an item to its display string. Defaults to [Object.toString].
  final DropdownSearchItemAsString<T>? itemAsString;

  /// Custom filter function for synchronous [items].
  /// If omitted, a case-insensitive `itemAsString.contains(query)` is used.
  final DropdownSearchFilterFn<T>? filterFn;

  /// Comparison used to highlight the currently selected item in the popup.
  final DropdownSearchCompareFn<T>? compareFn;

  /// The currently selected value (controlled mode).
  final T? selectedItem;

  /// Called when the user picks an item (or clears the selection).
  final ValueChanged<T?>? onChanged;

  /// Validation callback used in a [Form] context.
  final FormFieldValidator<T>? validator;

  /// Prefix icon inside the trigger field.
  final Widget? prefixIcon;

  /// Whether the field is interactive.
  final bool enabled;

  /// Hint shown inside the search box in the popup.
  final String searchHint;

  const AppSearchableDropdown({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.items,
    this.asyncItems,
    this.itemAsString,
    this.filterFn,
    this.compareFn,
    this.selectedItem,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.searchHint = 'Cari...',
  }) : assert(items != null || asyncItems != null, 'Provide either items or asyncItems');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasError = errorText != null && errorText!.isNotEmpty;
    final fillColor = enabled ? cs.surface : cs.onSurface.withValues(alpha: 0.12);

    // ── InputDecoration — mirrors AppTextField style ─────────────────────────
    final decoration = InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintText: hint,
      hintStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      errorText: hasError ? errorText : null,
      errorStyle: tt.bodySmall?.copyWith(color: cs.error),
      errorMaxLines: 2,
      prefixIcon: prefixIcon != null
          ? SizedBox(
              width: 48,
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: cs.onSurfaceVariant, size: 20),
                  child: prefixIcon!,
                ),
              ),
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? cs.error : cs.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? cs.error : cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.12)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );

    // ── Popup props ──────────────────────────────────────────────────────────
    final popupProps = PopupProps<T>.menu(
      showSearchBox: true,
      showSelectedItems: true,
      searchDelay: const Duration(milliseconds: 300),
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        style: tt.bodySmall,
        autofocus: true,
      ),
      menuProps: MenuProps(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        backgroundColor: cs.surface,
      ),
      // v5 itemBuilder signature: (BuildContext, T, bool isSelected) — 3 args
      itemBuilder: (ctx, item, isSelected) {
        final label = itemAsString != null ? itemAsString!(item) : item.toString();
        return ListTile(
          dense: true,
          title: Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: isSelected ? cs.primary : cs.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, size: 18, color: cs.primary)
              : null,
        );
      },
      // v5 emptyBuilder signature: (BuildContext, String searchEntry) — 2 args
      emptyBuilder: (ctx, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('Tidak ada hasil', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );

    // ── Core DropdownSearch ──────────────────────────────────────────────────
    final dropdown = DropdownSearch<T>(
      items: items ?? const [],
      asyncItems: asyncItems,
      selectedItem: selectedItem,
      itemAsString: itemAsString,
      filterFn: filterFn,
      compareFn: compareFn,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      popupProps: popupProps,
      dropdownButtonProps: DropdownButtonProps(
        icon: Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant, size: 24),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: decoration,
        baseStyle: tt.bodySmall,
      ),
    );

    // ── Wrap with label / helper — same pattern as AppTextField ─────────────
    if (label == null) return dropdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: label,
          child: Text(
            label!,
            style: tt.titleSmall?.copyWith(
              color: enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(helperText!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
        const SizedBox(height: 6),
        dropdown,
      ],
    );
  }
}
