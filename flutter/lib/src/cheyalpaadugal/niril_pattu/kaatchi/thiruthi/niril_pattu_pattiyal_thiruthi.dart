import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/locale_provider.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_editor_shell.dart';

class SilkInvoiceEditor extends ConsumerWidget {
  const SilkInvoiceEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanEditorShell(
      title: K.pudhiyaPattupPattiyal.tr(context, ref),
      onSave: () {},
      child: Center(
        child: Text(K.pattupattiyalthiruthi.tr(context, ref)),
      ),
    );
  }
}
