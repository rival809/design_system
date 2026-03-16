import 'package:flutter/material.dart';

/// A theme-aware date picker field widget.
///
/// Renders identically to [AppTextField] — same border radius, typography,
/// fill colour, and label/helper pattern — while triggering Flutter's
/// [showDatePicker] dialog on tap.
///
/// **Basic usage**
/// ```dart
/// AppDatePicker(
///   label: 'Tanggal Lahir *',
///   hint: 'Pilih tanggal lahir',
///   value: _selectedDate,
///   firstDate: DateTime(1940),
///   lastDate: DateTime(2010),
///   onChanged: (date) => setState(() => _selectedDate = date),
/// )
/// ```
class AppDatePicker extends StatelessWidget {
  /// Static label displayed above the field.
  final String? label;

  /// Helper text displayed below the label.
  final String? helperText;

  /// Placeholder text shown when no date is selected.
  final String? hint;

  /// Error message. When non-null the field enters the error state.
  final String? errorText;

  /// The currently selected date (controlled).
  final DateTime? value;

  /// Earliest selectable date. Defaults to [DateTime(1900)].
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to [DateTime.now()].
  final DateTime? lastDate;

  /// Initial date shown when the picker opens. Defaults to [value] or today.
  final DateTime? initialDate;

  /// Title shown inside the picker dialog.
  final String? pickerHelpText;

  /// Called when the user confirms a date selection.
  final ValueChanged<DateTime>? onChanged;

  /// Custom date formatter. Defaults to `d MMMM yyyy` in Indonesian.
  final String Function(DateTime)? dateFormatter;

  /// Whether the field is interactive.
  final bool enabled;

  const AppDatePicker({
    super.key,
    this.label,
    this.helperText,
    this.hint,
    this.errorText,
    this.value,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.pickerHelpText,
    this.onChanged,
    this.dateFormatter,
    this.enabled = true,
  });

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _formatDate(DateTime date) {
    if (dateFormatter != null) return dateFormatter!(date);
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasValue = value != null;

    final borderColor = hasError ? cs.error : cs.outline;
    const borderWidth = 1.0;
    final iconColor = hasError ? cs.error : cs.onSurfaceVariant;
    final fillColor = enabled ? cs.surface : cs.onSurface.withValues(alpha: 0.12);

    final field = InkWell(
      onTap: enabled
          ? () async {
              final now = DateTime.now();
              final effectiveLastDate = lastDate ?? now;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate ?? value ?? effectiveLastDate,
                firstDate: firstDate ?? DateTime(1900),
                lastDate: effectiveLastDate,
                helpText: pickerHelpText,
              );
              if (picked != null) onChanged?.call(picked);
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? _formatDate(value!) : (hint ?? ''),
                style: tt.bodySmall?.copyWith(color: hasValue ? cs.onSurface : cs.onSurfaceVariant),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, size: 24, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );

    if (label == null) return field;

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
        field,
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText!, style: tt.bodySmall?.copyWith(color: cs.error)),
          ),
        ],
      ],
    );
  }
}
