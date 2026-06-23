import 'package:flutter/material.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/locale_provider.dart';
import '../../../chattagam/kaatchi/kaipaesi/elvan_utpakkach_chattagam.dart';

/// The Universal Editor Shell that wraps all creator/editor forms.
class ElvanEditorShell extends ConsumerWidget {
  const ElvanEditorShell({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: title,
      navActions: [
        if (onSave != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSave,
              child: Text(K.chaemiPtn.tr(context, ref),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ],
    );
  }
}
