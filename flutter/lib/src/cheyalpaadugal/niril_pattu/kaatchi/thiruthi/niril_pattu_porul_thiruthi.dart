import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';

class SilkItemEditor extends ConsumerWidget {
  const SilkItemEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanEditorShell(
      title: K.pudhiyaPattupPorul.tr(context, ref),
      onSave: () {},
      child: Center(
        child: Text(K.pattupPorulThiruthi.tr(context, ref)),
      ),
    );
  }
}
