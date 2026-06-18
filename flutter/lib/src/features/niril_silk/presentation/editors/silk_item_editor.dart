import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class SilkItemEditor extends StatelessWidget {
  const SilkItemEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'New Silk Item',
      onSave: () {},
      child: const Center(
        child: Text('Silk Item Editor'),
      ),
    );
  }
}
