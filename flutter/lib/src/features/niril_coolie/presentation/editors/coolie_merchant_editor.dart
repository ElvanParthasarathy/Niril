import 'package:flutter/material.dart';
import '../../../niril_common/presentation/editors/elvan_editor_shell.dart';

class CoolieMerchantEditor extends StatelessWidget {
  const CoolieMerchantEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: 'newCoolieMerchantTitle'.tr(context, ref),
      onSave: () {},
      child: const Center(
        child: Text('coolieMerchantEditorLabel'.tr(context, ref)),
      ),
    );
  }
}
