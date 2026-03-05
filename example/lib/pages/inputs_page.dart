import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class InputsPage extends StatelessWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Single Line'),
              Tab(text: 'Multiline'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _InputStatesSection(multiline: false),
                _InputStatesSection(multiline: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input states section
// ---------------------------------------------------------------------------

class _InputStatesSection extends StatefulWidget {
  const _InputStatesSection({required this.multiline});
  final bool multiline;

  @override
  State<_InputStatesSection> createState() => _InputStatesSectionState();
}

class _InputStatesSectionState extends State<_InputStatesSection> {
  final _filledController = TextEditingController(text: 'Text Placeholder');
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _filledController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int? get _maxLines => widget.multiline ? null : 1;
  int? get _minLines => widget.multiline ? 4 : null;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final states = [
      (
        'Default',
        AppTextField(
          label: 'Label Input',
          hint: 'Text Placeholder',
          helperText: 'Helper Messages',
          prefixIcon: const Icon(Icons.mail_outline),
          obscureText: !widget.multiline,
          maxLines: _maxLines,
          minLines: _minLines,
        ),
      ),
      (
        'Focused',
        AppTextField(
          label: 'Label Input',
          hint: 'Text Placeholder',
          helperText: 'Helper Messages',
          prefixIcon: const Icon(Icons.mail_outline),
          obscureText: !widget.multiline,
          focusNode: _focusNode,
          autofocus: true,
          maxLines: _maxLines,
          minLines: _minLines,
        ),
      ),
      (
        'Filled',
        AppTextField(
          label: 'Label Input',
          hint: 'Text Placeholder',
          helperText: 'Helper Messages',
          prefixIcon: const Icon(Icons.mail_outline),
          obscureText: !widget.multiline,
          controller: _filledController,
          maxLines: _maxLines,
          minLines: _minLines,
        ),
      ),
      (
        'Disabled',
        AppTextField(
          label: 'Label Input',
          hint: 'Text Placeholder',
          helperText: 'Helper Messages',
          prefixIcon: const Icon(Icons.mail_outline),
          obscureText: !widget.multiline,
          enabled: false,
          maxLines: _maxLines,
          minLines: _minLines,
        ),
      ),
      (
        'Error',
        AppTextField(
          label: 'Label Input',
          hint: 'Text Placeholder',
          helperText: 'Helper Messages',
          errorText: 'Error Messages',
          prefixIcon: const Icon(Icons.mail_outline),
          obscureText: !widget.multiline,
          maxLines: _maxLines,
          minLines: _minLines,
        ),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: states
            .expand(
              (s) => [
                Text(s.$1, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                s.$2,
                const SizedBox(height: 24),
              ],
            )
            .toList(),
      ),
    );
  }
}
