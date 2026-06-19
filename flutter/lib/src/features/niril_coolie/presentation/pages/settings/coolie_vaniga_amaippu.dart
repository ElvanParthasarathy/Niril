import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class CoolieVanigaAmaippuPage extends ConsumerWidget {
  const CoolieVanigaAmaippuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'vanigam'.tr(context, ref) + " (Coolie)",
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('Coolie Merchant Settings Dummy'),
          ),
        ),
      ],
    );
  }
}
