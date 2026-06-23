import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class SilkReceiptEditor extends StatelessWidget {
  const SilkReceiptEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'newSilkReceiptTitle'.tr(context, ref),
      onSave: () {},
      child: const Center(
        child: Text('silkReceiptEditorLabel'.tr(context, ref)),
      ),
    );
  }
}
