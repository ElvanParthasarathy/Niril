import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class CoolieVanigarAmaippuPage extends ConsumerWidget {
  const CoolieVanigarAmaippuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'vanigar_amaippugal'.tr(context, ref) + " (Coolie)",
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
