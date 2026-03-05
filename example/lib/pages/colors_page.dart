import 'package:flutter/material.dart';

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(padding: EdgeInsets.all(24), child: _ColorPalette());
  }
}

// ---------------------------------------------------------------------------
// Color palette
// ---------------------------------------------------------------------------

class _ColorPalette extends StatelessWidget {
  const _ColorPalette();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groups = [
      (
        'Primary',
        [
          ('primary', cs.primary),
          ('onPrimary', cs.onPrimary),
          ('primaryContainer', cs.primaryContainer),
          ('onPrimaryContainer', cs.onPrimaryContainer),
          ('primaryFixed', cs.primaryFixed),
          ('primaryFixedDim', cs.primaryFixedDim),
          ('onPrimaryFixed', cs.onPrimaryFixed),
          ('onPrimaryFixedVariant', cs.onPrimaryFixedVariant),
        ],
      ),
      (
        'Secondary',
        [
          ('secondary', cs.secondary),
          ('onSecondary', cs.onSecondary),
          ('secondaryContainer', cs.secondaryContainer),
          ('onSecondaryContainer', cs.onSecondaryContainer),
          ('secondaryFixed', cs.secondaryFixed),
          ('secondaryFixedDim', cs.secondaryFixedDim),
          ('onSecondaryFixed', cs.onSecondaryFixed),
          ('onSecondaryFixedVariant', cs.onSecondaryFixedVariant),
        ],
      ),
      (
        'Tertiary',
        [
          ('tertiary', cs.tertiary),
          ('onTertiary', cs.onTertiary),
          ('tertiaryContainer', cs.tertiaryContainer),
          ('onTertiaryContainer', cs.onTertiaryContainer),
          ('tertiaryFixed', cs.tertiaryFixed),
          ('tertiaryFixedDim', cs.tertiaryFixedDim),
          ('onTertiaryFixed', cs.onTertiaryFixed),
          ('onTertiaryFixedVariant', cs.onTertiaryFixedVariant),
        ],
      ),
      (
        'Error',
        [
          ('error', cs.error),
          ('onError', cs.onError),
          ('errorContainer', cs.errorContainer),
          ('onErrorContainer', cs.onErrorContainer),
        ],
      ),
      (
        'Surface',
        [
          ('surface', cs.surface),
          ('onSurface', cs.onSurface),
          ('surfaceDim', cs.surfaceDim),
          ('surfaceBright', cs.surfaceBright),
          ('surfaceContainerLowest', cs.surfaceContainerLowest),
          ('surfaceContainerLow', cs.surfaceContainerLow),
          ('surfaceContainer', cs.surfaceContainer),
          ('surfaceContainerHigh', cs.surfaceContainerHigh),
          ('surfaceContainerHighest', cs.surfaceContainerHighest),
          ('onSurfaceVariant', cs.onSurfaceVariant),
        ],
      ),
      (
        'Outline & Inverse',
        [
          ('outline', cs.outline),
          ('outlineVariant', cs.outlineVariant),
          ('inverseSurface', cs.inverseSurface),
          ('onInverseSurface', cs.onInverseSurface),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        final groupLabel = group.$1;
        final tokens = group.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: tokens.map((t) => _ColorChip(label: t.$1, color: t.$2)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: cs.outlineVariant),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
