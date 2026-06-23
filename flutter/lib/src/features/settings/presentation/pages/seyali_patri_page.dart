import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class SeyaliPatriPage extends ConsumerWidget {
  const SeyaliPatriPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'seyali_patri'.tr(context, ref),
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('About App (Dummy)'),
          ),
        ),
      ],
    );
  }
}
