/// Shared utilities for table widgets.
library;

/// Converts a snake_case key to a Title Case label.
///
/// Example: `'pangkat_golongan'` → `'Pangkat Golongan'`
String titleFromKey(String key) {
  if (key.isEmpty) return key;
  final parts = key.split('_').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return key;
  return parts
      .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}
