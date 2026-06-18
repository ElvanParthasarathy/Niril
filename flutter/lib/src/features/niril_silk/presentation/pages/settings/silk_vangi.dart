import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class SilkVangiPage extends ConsumerWidget {
  const SilkVangiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'vangi'.tr(context, ref) + " (Silk)",
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('Silk Bank Settings Dummy'),
          ),
        ),
      ],
    );
  }
}
