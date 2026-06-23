import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../chattagam/kaatchi/kaipaesi/elvan_utpakkach_chattagam.dart';

class SilkReportsPage extends ConsumerWidget {
  const SilkReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: K.arikkaigal.tr(context, ref),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Text(
              K.arikkaigal.tr(context, ref),
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
