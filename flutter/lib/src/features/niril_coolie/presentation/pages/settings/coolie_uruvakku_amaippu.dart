import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class CoolieUruvakkuAmaippuPage extends ConsumerWidget {
  const CoolieUruvakkuAmaippuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'uruvakku_amaippugal'.tr(context, ref) + " (Coolie)",
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('Coolie Creation Settings Dummy'),
          ),
        ),
      ],
    );
  }
}
