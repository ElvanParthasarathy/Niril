import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class CoolieItemEditor extends StatelessWidget {
  const CoolieItemEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'New Coolie Item',
      onSave: () {},
      child: const Center(
        child: Text('Coolie Item Editor'),
      ),
    );
  }
}
