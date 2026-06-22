import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class SilkReportsPage extends ConsumerWidget {
  const SilkReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'reports'.tr(context, ref),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'reports'.tr(context, ref),
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
