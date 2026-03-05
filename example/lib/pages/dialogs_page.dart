import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class DialogsPage extends StatelessWidget {
  const DialogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(padding: EdgeInsets.all(24), child: _DialogSection());
  }
}

// ---------------------------------------------------------------------------
// Dialog section
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
