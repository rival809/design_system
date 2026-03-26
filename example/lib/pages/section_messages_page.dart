import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SectionMessagesPage extends StatelessWidget {
  const SectionMessagesPage({super.key});

  static const _lorem =
      'Lorem ipsum dolor sit amet consectetur. Morbi tellus gravida tortor ut est suspendisse. Non.';

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          AppSectionMessage(message: _lorem, type: SectionMessageType.error),
          SizedBox(height: 12),
          AppSectionMessage(message: _lorem, type: SectionMessageType.success),
          SizedBox(height: 12),
          AppSectionMessage(message: _lorem, type: SectionMessageType.warning),
          SizedBox(height: 12),
          AppSectionMessage(message: _lorem, type: SectionMessageType.info),
        ],
      ),
    );
  }
}
