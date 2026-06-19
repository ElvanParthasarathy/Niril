import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class AboutDeveloperPage extends ConsumerWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'about_developer'.tr(context, ref),
      slivers: const [
        SliverFillRemaining(
          child: Center(
            child: Text('About Developer (Dummy)'),
          ),
        ),
      ],
    );
  }
}
