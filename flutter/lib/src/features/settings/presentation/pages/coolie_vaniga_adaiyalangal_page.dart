import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class CoolieVanigaAdaiyalangalPage extends ConsumerWidget {
  const CoolieVanigaAdaiyalangalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'coolie_vaniga_adaiyalangal'.tr(context, ref),
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('Coolie Vaniga Adaiyalangal (Dummy)'),
          ),
        ),
      ],
    );
  }
}
