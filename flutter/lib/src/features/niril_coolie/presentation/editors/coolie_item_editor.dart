import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class CoolieItemEditor extends StatelessWidget {
  const CoolieItemEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'newCoolieItemTitle'.tr(context, ref),
      onSave: () {},
      child: const Center(
        child: Text('coolieItemEditorLabel'.tr(context, ref)),
      ),
    );
  }
}
