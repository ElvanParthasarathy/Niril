import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/models/app_mode.dart';
import '../../../../core/state/app_state.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';

class SeyaliAmaippugalPage extends ConsumerWidget {
  const SeyaliAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentAppMode = ref.watch(appModeProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1);

    return ElvanSubpageShell(
      title: 'seyali_amaippugal'.tr(context, ref),
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 32),
          sliver: SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'uiLanguageTheme'.tr(context, ref),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: cardColor,
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System Auto'),
                      value: ThemeMode.system,
                      groupValue: currentTheme,
                      onChanged: (val) {
                        if (val != null) ref.read(themeModeProvider.notifier).setThemeMode(val);
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                    RadioListTile<ThemeMode>(
                      title: Text('lightMode'.tr(context, ref)),
                      value: ThemeMode.light,
                      groupValue: currentTheme,
                      onChanged: (val) {
                        if (val != null) ref.read(themeModeProvider.notifier).setThemeMode(val);
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                    RadioListTile<ThemeMode>(
                      title: Text('darkMode'.tr(context, ref)),
                      value: ThemeMode.dark,
                      groupValue: currentTheme,
                      onChanged: (val) {
                        if (val != null) ref.read(themeModeProvider.notifier).setThemeMode(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'businessProfilesTitle'.tr(context, ref),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: cardColor,
                child: Column(
                  children: [
                    RadioListTile<AppMode>(
                      title: Text('nirilSilk'.tr(context, ref)),
                      value: AppMode.gst,
                      groupValue: currentAppMode ?? AppMode.gst,
                      onChanged: (val) {
                        if (val != null) ref.read(appModeProvider.notifier).setMode(val);
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                    RadioListTile<AppMode>(
                      title: Text('nirilCoolie'.tr(context, ref)),
                      value: AppMode.coolie,
                      groupValue: currentAppMode ?? AppMode.gst,
                      onChanged: (val) {
                        if (val != null) ref.read(appModeProvider.notifier).setMode(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'appLanguage'.tr(context, ref),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: cardColor,
                child: Column(
                  children: [
                    RadioListTile<Locale?>(
                      title: const Text('System Auto'),
                      value: null,
                      groupValue: currentLocale,
                      onChanged: (val) {
                        ref.read(localeProvider.notifier).setLocale(val);
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                    RadioListTile<Locale?>(
                      title: Text('tamil'.tr(context, ref)),
                      value: const Locale('ta'),
                      groupValue: currentLocale,
                      onChanged: (val) {
                        ref.read(localeProvider.notifier).setLocale(val);
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                    RadioListTile<Locale?>(
                      title: Text('english'.tr(context, ref)),
                      value: const Locale('en'),
                      groupValue: currentLocale,
                      onChanged: (val) {
                        ref.read(localeProvider.notifier).setLocale(val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
