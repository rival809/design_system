import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _ShowcasePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Showcase page
// ---------------------------------------------------------------------------

class _ShowcasePage extends StatefulWidget {
  const _ShowcasePage();

  @override
  State<_ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<_ShowcasePage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colors
              Text('Colors', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              const _ColorPalette(),
              const SizedBox(height: 32),

              // Typography
              Text('Typography', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              const _TypographyPreview(),
              const SizedBox(height: 32),

              // Buttons
              Text('Buttons', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              _ButtonsSection(isLoading: _isLoading, onLoadingTap: _simulateLoading),
              const SizedBox(height: 32),

              // Text Fields
              Text('Text Fields', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email address',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                controller: _emailController,
                validator: (v) => (v == null || v.isEmpty) ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hint: '••••••••',
                obscureText: true,
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Notes',
                hint: 'Write something…',
                maxLines: 4,
                minLines: 3,
                helperText: 'Optional — visible to the whole team.',
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Disabled field',
                hint: 'Cannot edit',
                enabled: false,
                initialValue: 'Read-only value',
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Validate form',
                expand: true,
                onPressed: () => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 32),

              // Dialogs
              Text('Dialogs', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              const _DialogSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Color palette preview
// ---------------------------------------------------------------------------

class _ColorPalette extends StatelessWidget {
  const _ColorPalette();

  static const _tokens = <(String, Color)>[
    ('primary', AppColors.primary),
    ('primaryLight', AppColors.primaryLight),
    ('secondary', AppColors.secondary),
    ('success', AppColors.success),
    ('warning', AppColors.warning),
    ('error', AppColors.error),
    ('surface', AppColors.surface),
    ('surfaceVariant', AppColors.surfaceVariant),
    ('outline', AppColors.outline),
    ('onSurfaceVariant', AppColors.onSurfaceVariant),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _tokens.map((t) => _ColorChip(label: t.$1, color: t.$2)).toList(),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppTheme.borderRadiusSm,
            border: Border.all(color: AppColors.outlineVariant),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Typography preview
// ---------------------------------------------------------------------------

class _TypographyPreview extends StatelessWidget {
  const _TypographyPreview();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: tt.displayLarge?.copyWith(fontSize: 28)),
        Text('Headline Medium', style: tt.headlineMedium),
        Text('Title Large', style: tt.titleLarge),
        Text('Title Medium', style: tt.titleMedium),
        Text('Body Large', style: tt.bodyLarge),
        Text('Body Medium', style: tt.bodyMedium),
        Text('Label Large', style: tt.labelLarge),
        Text('Caption / Body Small', style: tt.bodySmall),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: 'Filled', onPressed: () {}),
            PrimaryButton(
              label: 'With icon',
              leadingIcon: const Icon(Icons.add, size: 18),
              onPressed: () {},
            ),
            PrimaryButton(label: 'Disabled', onPressed: null),
            PrimaryButton(label: 'Loading…', isLoading: isLoading, onPressed: onLoadingTap),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: 'Outlined', variant: ButtonVariant.outlined, onPressed: () {}),
            PrimaryButton(label: 'Disabled', variant: ButtonVariant.outlined, onPressed: null),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: 'Text button', variant: ButtonVariant.text, onPressed: () {}),
            PrimaryButton(label: 'Small', size: ButtonSize.small, onPressed: () {}),
            PrimaryButton(label: 'Large CTA', size: ButtonSize.large, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Full-width button', expand: true, onPressed: () {}),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dialogs section
// ---------------------------------------------------------------------------

class _DialogSection extends StatelessWidget {
  const _DialogSection();

  void _show(BuildContext context, DialogType type) {
    AppDialog.show(
      context: context,
      config: AppDialogConfig(
        type: type,
        title: switch (type) {
          DialogType.info => 'Information',
          DialogType.success => 'All done!',
          DialogType.warning => 'Are you sure?',
          DialogType.destructive => 'Delete permanently?',
        },
        content: Text(switch (type) {
          DialogType.info => 'This is a neutral informational message.',
          DialogType.success => 'Your changes have been saved successfully.',
          DialogType.warning => 'This action may have unintended side effects.',
          DialogType.destructive =>
            'This item will be permanently deleted and cannot be recovered.',
        }),
        confirmLabel: type == DialogType.destructive ? 'Delete' : 'Got it',
        showCancelButton: type == DialogType.warning || type == DialogType.destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PrimaryButton(label: 'Info', onPressed: () => _show(context, DialogType.info)),
        PrimaryButton(label: 'Success', onPressed: () => _show(context, DialogType.success)),
        PrimaryButton(label: 'Warning', onPressed: () => _show(context, DialogType.warning)),
        PrimaryButton(
          label: 'Destructive',
          onPressed: () => _show(context, DialogType.destructive),
        ),
      ],
    );
  }
}
