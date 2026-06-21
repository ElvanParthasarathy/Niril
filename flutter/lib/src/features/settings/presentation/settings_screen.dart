import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

import '../../../localization/locale_provider.dart';
import '../../shell/presentation/mobile/widgets/elvan_page_route.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/app_mode.dart';
import '../../shell/presentation/mobile/elvan_subpage_shell.dart';
import 'pages/vaniga_amaippugal_page.dart';
import 'pages/mugavari_page.dart';
import 'pages/vangi_page.dart';
import 'pages/coolie_vaniga_adaiyalangal_page.dart';
import 'pages/silk_vaniga_adaiyalangal_page.dart';
import 'pages/about_developer_page.dart';
import 'pages/uruvakku_amaippugal_page.dart';
import 'pages/display_settings_page.dart';
import 'pages/language_settings_page.dart';
import 'package:elvan_niril/src/features/settings/presentation/widgets/elvan_settings_section.dart';
import 'package:elvan_niril/src/features/niril_common/presentation/widgets/elvan_settings_icon.dart';
import 'pages/pathugappu_amaippugal_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppMode = ref.watch(appModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return ElvanSubpageShell(
      title: 'settings'.tr(context, ref),
      startCollapsed: false,
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      slivers: [
        SliverList.list(
          children: [
            // ── Mode Switcher & Merchant Settings (Big Pill) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElvanSettingsSection(
                borderRadius: 999.0,
                children: [
                  Stack(
                    children: [
                      // The main pill body (Navigates to Merchant Settings)
                      InkWell(
                        onTap: () {
                          Navigator.push(context, ElvanPageRoute(builder: (_) => const VanigaAmaippugalPage()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 98, right: 32, top: 14, bottom: 14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'vaniga_amaippugal'.tr(context, ref),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ref.watch(appModeProvider) == AppMode.coolie 
                                      ? 'nirilCoolie'.tr(context, ref) 
                                      : 'nirilSilk'.tr(context, ref),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // The circular Mode Switcher on the left
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Material(
                          color: iconBgColor,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {
                              final currentMode = ref.read(appModeProvider);
                              ref.read(appModeProvider.notifier).setMode(
                                currentMode == AppMode.coolie ? AppMode.silk : AppMode.coolie
                              );
                            },
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: Center(
                                child: Icon(
                                  ref.watch(appModeProvider) == AppMode.coolie 
                                      ? CupertinoIcons.money_dollar_circle_fill
                                      : CupertinoIcons.doc_text_fill,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 1: Business Profile & Identity ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElvanSettingsSection(
                children: [

                  if (currentAppMode == AppMode.coolie)
                    ElvanSettingsRow(
                      icon: CupertinoIcons.briefcase_fill,
                      iconBgColor: iconBgColor,
                      title: 'adaiyalam'.tr(context, ref),
                      description: 'desc_coolie_identifiers'.tr(context, ref),
                      onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const CoolieVanigaAdaiyalangalPage())),
                    )
                  else
                    ElvanSettingsRow(
                      icon: CupertinoIcons.briefcase_fill,
                      iconBgColor: iconBgColor,
                      title: 'adaiyalam'.tr(context, ref),
                      description: 'desc_silk_identifiers'.tr(context, ref),
                      onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const SilkVanigaAdaiyalangalPage())),
                    ),
                  ElvanSettingsRow(
                    icon: CupertinoIcons.location_solid,
                    iconBgColor: iconBgColor,
                    title: 'settings_mugavari'.tr(context, ref),
                    description: 'desc_address'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const MugavariPage())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 2: Finance & Creation ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElvanSettingsSection(
                children: [
                  ElvanSettingsRow(
                    icon: CupertinoIcons.creditcard_fill,
                    iconBgColor: iconBgColor,
                    title: 'vangi'.tr(context, ref),
                    description: 'desc_bank'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const VangiPage())),
                  ),
                  ElvanSettingsRow(
                    icon: CupertinoIcons.doc_text_fill,
                    iconBgColor: iconBgColor,
                    title: 'uruvakku'.tr(context, ref),
                    description: 'desc_invoice'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const UruvakkuAmaippugalPage())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 3: App Experience & Display ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElvanSettingsSection(
                children: [
                  ElvanSettingsRow(
                    icon: CupertinoIcons.sun_max_fill,
                    iconBgColor: iconBgColor,
                    title: 'thirai'.tr(context, ref),
                    description: 'desc_display'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const DisplaySettingsPage())),
                  ),
                  ElvanSettingsRow(
                    icon: Icons.language,
                    iconBgColor: iconBgColor,
                    title: 'appLanguage'.tr(context, ref),
                    description: 'desc_language'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const LanguageSettingsPage())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 4: System & About ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElvanSettingsSection(
                children: [
                  ElvanSettingsRow(
                    icon: CupertinoIcons.lock_fill,
                    iconBgColor: iconBgColor,
                    title: 'pathugappu'.tr(context, ref),
                    description: 'desc_security'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const PathugappuAmaippugalPage())),
                  ),
                  ElvanSettingsRow(
                    icon: CupertinoIcons.info_circle_fill,
                    iconBgColor: iconBgColor,
                    title: 'menporul_vadivalar'.tr(context, ref),
                    description: 'desc_about'.tr(context, ref),
                    onTap: () => Navigator.push(context, ElvanPageRoute(builder: (_) => const AboutDeveloperPage())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ],
    );
  }
}