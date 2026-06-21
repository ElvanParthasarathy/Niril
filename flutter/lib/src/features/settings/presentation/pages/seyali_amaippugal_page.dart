import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/models/app_mode.dart';
import '../../../../core/state/app_state.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../widgets/elvan_settings_section.dart';

class SeyaliAmaippugalPage extends ConsumerWidget {
  const SeyaliAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppMode = ref.watch(appModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElvanSubpageShell(
      title: 'seyali_amaippugal'.tr(context, ref),
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: 32,
          ),
          sliver: SliverList.list(
            children: [
              ElvanSettingsSection(
                dividerIndent: 16.0,
                children: [
                  ElvanRadioSettingsRow<AppMode>(
                    title: 'nirilSilk'.tr(context, ref),
                    value: AppMode.silk,
                    groupValue: currentAppMode ?? AppMode.silk,
                    onChanged: (val) {
                      if (val != null) ref.read(appModeProvider.notifier).setMode(val);
                    },
                  ),
                  ElvanRadioSettingsRow<AppMode>(
                    title: 'nirilCoolie'.tr(context, ref),
                    value: AppMode.coolie,
                    groupValue: currentAppMode ?? AppMode.silk,
                    onChanged: (val) {
                      if (val != null) ref.read(appModeProvider.notifier).setMode(val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
