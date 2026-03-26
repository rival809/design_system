import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _isLoading = false;

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _ButtonsSection(isLoading: _isLoading, onLoadingTap: _simulateLoading),
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons section
// ---------------------------------------------------------------------------

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection({required this.isLoading, required this.onLoadingTap});

  final bool isLoading;
  final VoidCallback onLoadingTap;

  static const _variants = [
    (ButtonVariant.filled, 'Primary'),
    (ButtonVariant.secondary, 'Secondary'),
    (ButtonVariant.danger, 'Danger'),
    (ButtonVariant.tertiary, 'Tertiary'),
    (ButtonVariant.link, 'Link'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Variant matrix ──────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header row
              TableRow(
                children: [
                  const SizedBox(width: 72),
                  ..._variants.map(
                    (v) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Text(
                        v.$2,
                        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              // Active row
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                    child: Text(
                      'Active',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  ..._variants.map(
                    (v) => Padding(
                      padding: const EdgeInsets.all(6),
                      child: PrimaryButton(
                        label: 'Button',
                        variant: v.$1,
                        size: ButtonSize.small,
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
              // Disabled row
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                    child: Text(
                      'Disable',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  ..._variants.map(
                    (v) => Padding(
                      padding: const EdgeInsets.all(6),
                      child: PrimaryButton(
                        label: 'Button',
                        variant: v.$1,
                        size: ButtonSize.small,
                        onPressed: null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Icons ────────────────────────────────────────────────────────────
        Text('With Icons', style: tt.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(
              label: 'Leading',
              leadingIcon: const Icon(Icons.add, size: 16),
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Trailing',
              trailingIcon: const Icon(Icons.arrow_forward, size: 16),
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Both',
              leadingIcon: const Icon(Icons.upload, size: 16),
              trailingIcon: const Icon(Icons.check, size: 16),
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Secondary',
              variant: ButtonVariant.secondary,
              leadingIcon: const Icon(Icons.edit_outlined, size: 16),
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Danger',
              variant: ButtonVariant.danger,
              leadingIcon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Tertiary',
              variant: ButtonVariant.tertiary,
              trailingIcon: const Icon(Icons.open_in_new, size: 16),
              onPressed: () {},
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Sizes ─────────────────────────────────────────────────────────────
        Text('Sizes', style: tt.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PrimaryButton(label: 'Small', size: ButtonSize.small, onPressed: () {}),
            PrimaryButton(label: 'Medium', size: ButtonSize.medium, onPressed: () {}),
            PrimaryButton(label: 'Large', size: ButtonSize.large, onPressed: () {}),
          ],
        ),

        const SizedBox(height: 28),

        // ── Badge ───────────────────────────────────────────────────────────
        Text('Badge', style: tt.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            AppBadge(label: '1', variant: BadgeVariant.primary),
            AppBadge(label: '1', variant: BadgeVariant.error),
            AppBadge(label: '1', variant: BadgeVariant.onSecondaryContainer),
            AppBadge(label: 'NEW', variant: BadgeVariant.primary),
            AppBadge.dot(variant: BadgeVariant.primary),
            AppBadge.dot(variant: BadgeVariant.error),
            AppBadge.dot(variant: BadgeVariant.onSecondaryContainer),
          ],
        ),

        const SizedBox(height: 28),

        // ── Chips ───────────────────────────────────────────────────────────
        Text('Chips', style: tt.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            AppChip(label: 'Data Table', variant: ChipVariant.blue),
            AppChip(label: 'Data Table', variant: ChipVariant.green),
            AppChip(label: 'Data Table', variant: ChipVariant.red),
            AppChip(label: 'Data Table', variant: ChipVariant.yellow),
          ],
        ),

        const SizedBox(height: 28),

        // ── Loading ───────────────────────────────────────────────────────────
        Text('Loading', style: tt.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: 'Primary', isLoading: isLoading, onPressed: onLoadingTap),
            PrimaryButton(
              label: 'Secondary',
              variant: ButtonVariant.secondary,
              isLoading: isLoading,
              onPressed: onLoadingTap,
            ),
            PrimaryButton(
              label: 'Danger',
              variant: ButtonVariant.danger,
              isLoading: isLoading,
              onPressed: onLoadingTap,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Full width ────────────────────────────────────────────────────────
        Text('Full Width', style: tt.titleSmall),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Full-width button', expand: true, onPressed: () {}),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Full-width outlined',
          variant: ButtonVariant.outlined,
          expand: true,
          onPressed: () {},
        ),

        const SizedBox(height: 28),

        // ── Snackbar ─────────────────────────────────────────────────────────
        Text('Snackbar', style: tt.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(
              label: 'Info',
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Ini adalah snackbar info.',
                type: SnackbarType.info,
              ),
            ),
            PrimaryButton(
              label: 'Success',
              variant: ButtonVariant.secondary,
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Operasi berhasil dilakukan.',
                type: SnackbarType.success,
              ),
            ),
            PrimaryButton(
              label: 'Warning',
              variant: ButtonVariant.tertiary,
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Periksa kembali data Anda.',
                type: SnackbarType.warning,
              ),
            ),
            PrimaryButton(
              label: 'Error',
              variant: ButtonVariant.danger,
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Terjadi kesalahan saat memproses permintaan.',
                type: SnackbarType.error,
              ),
            ),
            PrimaryButton(
              label: 'With Action',
              variant: ButtonVariant.outlined,
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Gagal memuat data.',
                type: SnackbarType.error,
                actionLabel: 'Coba lagi',
                onAction: () =>
                    AppSnackbar.show(context, message: 'Mencoba ulang...', type: SnackbarType.info),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
