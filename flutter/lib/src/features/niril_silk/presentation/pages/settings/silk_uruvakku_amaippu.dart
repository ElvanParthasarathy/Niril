import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class SilkUruvakkuAmaippuPage extends ConsumerWidget {
  const SilkUruvakkuAmaippuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'uruvakku_amaippugal'.tr(context, ref) + " (Silk)",
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('Silk Creation Settings Dummy'),
          ),
        ),
      ],
    );
  }
}
