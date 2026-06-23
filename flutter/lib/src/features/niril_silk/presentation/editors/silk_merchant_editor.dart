import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class SilkMerchantEditor extends StatelessWidget {
  const SilkMerchantEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'newSilkMerchantTitle'.tr(context, ref),
      onSave: () {},
      child: const Center(
        child: Text('silkMerchantEditorLabel'.tr(context, ref)),
      ),
    );
  }
}
