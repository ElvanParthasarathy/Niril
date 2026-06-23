import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class CoolieInvoiceEditor extends StatelessWidget {
  const CoolieInvoiceEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'newCoolieInvoiceTitle'.tr(context, ref),
      onSave: () {},
      child: const Center(
        child: Text('coolieInvoiceEditorLabel'.tr(context, ref)),
      ),
    );
  }
}
