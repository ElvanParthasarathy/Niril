import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../widgets/elvan_settings_section.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElvanSubpageShell(
      title: 'appLanguage'.tr(context, ref),
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
                  ElvanRadioSettingsRow<Locale?>(
                    title: 'system_auto'.tr(context, ref),
                    value: null,
                    groupValue: currentLocale,
                    onChanged: (val) {
                      ref.read(localeProvider.notifier).setLocale(val);
                    },
                  ),
                  ElvanRadioSettingsRow<Locale?>(
                    title: 'tamil'.tr(context, ref),
                    value: const Locale('ta'),
                    groupValue: currentLocale,
                    onChanged: (val) {
                      ref.read(localeProvider.notifier).setLocale(val);
                    },
                  ),
                  ElvanRadioSettingsRow<Locale?>(
                    title: 'english'.tr(context, ref),
                    value: const Locale('en'),
                    groupValue: currentLocale,
                    onChanged: (val) {
                      ref.read(localeProvider.notifier).setLocale(val);
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
