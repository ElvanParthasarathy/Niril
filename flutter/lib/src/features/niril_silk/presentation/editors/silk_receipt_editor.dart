import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class SilkReceiptEditor extends StatelessWidget {
  const SilkReceiptEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'New Silk Receipt',
      onSave: () {},
      child: const Center(
        child: Text('Silk Receipt Editor'),
      ),
    );
  }
}
