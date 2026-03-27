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
          DialogType.success => null,
          DialogType.fail => null,
          DialogType.info => null,
          DialogType.warning => null,
          DialogType.confirm => 'Konfirmasi',
        },
        message: switch (type) {
          DialogType.success => 'Message!',
          DialogType.fail => 'Message!',
          DialogType.info => 'Message!',
          DialogType.warning => 'Message!',
          DialogType.confirm => 'Message',
        },
        actions: switch (type) {
          DialogType.success => const [
            AppDialogAction(id: 'ok', label: 'Ya, saya mengerti', variant: ButtonVariant.filled),
          ],
          DialogType.fail => const [
            AppDialogAction(
              id: 'retry',
              label: 'Periksa Kembali',
              variant: ButtonVariant.secondary,
            ),
            AppDialogAction(id: 'ok', label: 'Ya, saya mengerti', variant: ButtonVariant.filled),
          ],
          DialogType.info => const [
            AppDialogAction(id: 'ok', label: 'Ya, saya mengerti', variant: ButtonVariant.filled),
          ],
          DialogType.warning => const [
            AppDialogAction(
              id: 'retry',
              label: 'Periksa Kembali',
              variant: ButtonVariant.secondary,
            ),
            AppDialogAction(id: 'ok', label: 'Ya, saya mengerti', variant: ButtonVariant.filled),
          ],
          DialogType.confirm => const [
            AppDialogAction(
              id: 'retry',
              label: 'Periksa Kembali',
              variant: ButtonVariant.secondary,
            ),
            AppDialogAction(id: 'ok', label: 'Ya, saya mengerti', variant: ButtonVariant.filled),
          ],
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PrimaryButton(label: 'Success', onPressed: () => _show(context, DialogType.success)),
        PrimaryButton(label: 'Fail', onPressed: () => _show(context, DialogType.fail)),
        PrimaryButton(label: 'Info', onPressed: () => _show(context, DialogType.info)),
        PrimaryButton(label: 'Warning', onPressed: () => _show(context, DialogType.warning)),
        PrimaryButton(label: 'Confirm', onPressed: () => _show(context, DialogType.confirm)),
      ],
    );
  }
}
