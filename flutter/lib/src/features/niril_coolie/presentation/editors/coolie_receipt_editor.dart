import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class CoolieReceiptEditor extends StatelessWidget {
  const CoolieReceiptEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'newCoolieReceiptTitle'.tr(context, ref),
      onSave: () {},
      child: const Center(
        child: Text('coolieReceiptEditorLabel'.tr(context, ref)),
      ),
    );
  }
}
