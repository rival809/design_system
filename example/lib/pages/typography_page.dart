import 'package:flutter/material.dart';
import '../app_theme.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Roboto'),
              Tab(text: 'Lora'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: _TypographyPreview(useSecondary: false),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: _TypographyPreview(useSecondary: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typography preview
// ---------------------------------------------------------------------------

class _TypographyPreview extends StatelessWidget {
  const _TypographyPreview({required this.useSecondary});

  final bool useSecondary;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final lora = Theme.of(context).extension<LoraTextTheme>();
    final cs = Theme.of(context).colorScheme;

    final List<(String, List<(String, String, TextStyle?)>)> groups;

    if (!useSecondary) {
      groups = [
        (
          'Display',
          [
            ('displayLarge', 'Display Large · 34 · Regular', tt.displayLarge),
            ('displayMedium', 'Display Medium · 32 · Regular', tt.displayMedium),
            ('displaySmall', 'Display Small · 30 · Regular', tt.displaySmall),
          ],
        ),
        (
          'Headline',
          [
            ('headlineLarge', 'Headline Large · 28 · Medium', tt.headlineLarge),
            ('headlineMedium', 'Headline Medium · 24 · Medium', tt.headlineMedium),
            ('headlineSmall', 'Headline Small · 20 · Medium', tt.headlineSmall),
          ],
        ),
        (
          'Title',
          [
            ('titleLarge', 'Title Large · 18 · SemiBold', tt.titleLarge),
            ('titleMedium', 'Title Medium · 16 · SemiBold', tt.titleMedium),
            ('titleSmall', 'Title Small · 14 · SemiBold', tt.titleSmall),
          ],
        ),
        (
          'Label',
          [
            ('labelLarge', 'Label Large · 14 · Medium', tt.labelLarge),
            ('labelMedium', 'Label Medium · 12 · Medium', tt.labelMedium),
            ('labelSmall', 'Label Small · 10 · Medium', tt.labelSmall),
          ],
        ),
        (
          'Body',
          [
            ('bodyLarge', 'Body Large · 16 · Regular', tt.bodyLarge),
            ('bodyMedium', 'Body Medium · 14 · Regular', tt.bodyMedium),
            ('bodySmall', 'Body Small · 12 · Regular', tt.bodySmall),
          ],
        ),
      ];
    } else {
      groups = [
        (
          'Display',
          [
            ('displayLarge', 'Display Large · 34 · Regular', lora?.displayLarge),
            ('displayMedium', 'Display Medium · 32 · Regular', lora?.displayMedium),
            ('displaySmall', 'Display Small · 30 · Regular', lora?.displaySmall),
          ],
        ),
        (
          'Headline',
          [
            ('headlineLarge', 'Headline Large · 28 · Medium', lora?.headlineLarge),
            ('headlineMedium', 'Headline Medium · 24 · Medium', lora?.headlineMedium),
            ('headlineSmall', 'Headline Small · 20 · Medium', lora?.headlineSmall),
          ],
        ),
        (
          'Title',
          [
            ('titleLarge', 'Title Large · 18 · SemiBold', lora?.titleLarge),
            ('titleMedium', 'Title Medium · 16 · SemiBold', lora?.titleMedium),
            ('titleSmall', 'Title Small · 14 · SemiBold', lora?.titleSmall),
          ],
        ),
        (
          'Label',
          [
            ('labelLarge', 'Label Large · 14 · Medium', lora?.labelLarge),
            ('labelMedium', 'Label Medium · 12 · Medium', lora?.labelMedium),
            ('labelSmall', 'Label Small · 10 · Medium', lora?.labelSmall),
          ],
        ),
        (
          'Body',
          [
            ('bodyLarge', 'Body Large · 16 · Regular', lora?.bodyLarge),
            ('bodyMedium', 'Body Medium · 14 · Regular', lora?.bodyMedium),
            ('bodySmall', 'Body Small · 12 · Regular', lora?.bodySmall),
            ('bodyXSmall', 'Body XSmall · 10 · Regular', lora?.bodyXSmall),
          ],
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        final groupLabel = group.$1;
        final styles = group.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(groupLabel, style: tt.labelLarge?.copyWith(color: cs.primary)),
              const SizedBox(height: 8),
              ...styles.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(s.$2, style: s.$3),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
