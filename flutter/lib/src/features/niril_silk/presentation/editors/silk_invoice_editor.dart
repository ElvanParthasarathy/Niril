import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class SilkInvoiceEditor extends StatelessWidget {
  const SilkInvoiceEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'New Silk Invoice',
      onSave: () {},
      child: const Center(
        child: Text('Silk Invoice Editor (GST Mode)'),
      ),
    );
  }
}
