import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import '../../../localization/locale_provider.dart';
import '../../../navigation/niril_nav.dart';
import '../../../core/utils/app_svgs.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

import '../../shell/presentation/desktop/elvan_desktop_subpage_shell.dart';
import '../../auth/presentation/mode_selector_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Widget? _selectedDetail;

  void _onMenuSelected(Widget detailPage) {
    setState(() {
      _selectedDetail = detailPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideDesktop = constraints.maxWidth >=
            800; // Keep 800 for consistency with Flutter layout

        if (isWideDesktop) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor =
              isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6);

          return Scaffold(
            backgroundColor: bgColor,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel (Hub)
                Expanded(
                  child: ElvanSubpagePadding(
                    padding: const EdgeInsets.only(left: 24, right: 16),
                    child: SettingsHubScreen(onPageSelected: _onMenuSelected),
                  ),
                ),

                // Right Panel (Detail)
                Expanded(
                  child: ElvanSubpagePadding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: _selectedDetail ?? const VanigaAmaippugalPage(),
                  ),
                ),
              ],
            ),
          );
        }
        // Mobile / Narrow layout — renders with ElvanSubpageShell back button
        return const SettingsHubScreen();
      },
    );
  }
}

class SettingsHubScreen extends ConsumerWidget {
  final void Function(Widget page)? onPageSelected;

  const SettingsHubScreen({super.key, this.onPageSelected});

  void _navigateTo(BuildContext context, Widget page) {
    if (onPageSelected != null) {
      onPageSelected!(page);
    } else {
      NirilNav.push(context, page);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppMode = ref.watch(appModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return ElvanSubpageShell(
      title: 'settings'.tr(context, ref),
      startCollapsed: true,
      hideHeaderOnDesktop: true,
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
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
                          _navigateTo(context, const VanigaAmaippugalPage());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 98, right: 32, top: 14, bottom: 14),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
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
                              Navigator.of(context, rootNavigator: true).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ModeSelectorScreen(
                                    onModeSelected: (mode) {
                                      ref
                                          .read(appModeProvider.notifier)
                                          .setMode(mode);
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                        opacity: animation, child: child);
                                  },
                                  fullscreenDialog: true,
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: Center(
                                child: SvgPicture.string(
                                  ref.watch(appModeProvider) == AppMode.coolie
                                      ? AppSvgs.coolieMode
                                      : AppSvgs.silkMode,
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onSurface,
                                    BlendMode.srcIn,
                                  ),
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
                      onTap: () => _navigateTo(
                          context, const CoolieVanigaAdaiyalangalPage()),
                    )
                  else
                    ElvanSettingsRow(
                      icon: CupertinoIcons.briefcase_fill,
                      iconBgColor: iconBgColor,
                      title: 'adaiyalam'.tr(context, ref),
                      description: 'desc_silk_identifiers'.tr(context, ref),
                      onTap: () => _navigateTo(
                          context, const SilkVanigaAdaiyalangalPage()),
                    ),
                  ElvanSettingsRow(
                    icon: CupertinoIcons.location_solid,
                    iconBgColor: iconBgColor,
                    title: 'settings_mugavari'.tr(context, ref),
                    description: 'desc_address'.tr(context, ref),
                    onTap: () => _navigateTo(context, const MugavariPage()),
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
                    onTap: () => _navigateTo(context, const VangiPage()),
                  ),
                  ElvanSettingsRow(
                    icon: CupertinoIcons.doc_text_fill,
                    iconBgColor: iconBgColor,
                    title: 'uruvakku'.tr(context, ref),
                    description: 'desc_invoice'.tr(context, ref),
                    onTap: () =>
                        _navigateTo(context, const UruvakkuAmaippugalPage()),
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
                  if (!Platform.isWindows)
                    ElvanSettingsRow(
                      icon: CupertinoIcons.sun_max_fill,
                      iconBgColor: iconBgColor,
                      title: 'thirai'.tr(context, ref),
                      description: 'desc_display'.tr(context, ref),
                      onTap: () =>
                          _navigateTo(context, const DisplaySettingsPage()),
                    ),
                  ElvanSettingsRow(
                    icon: Icons.language,
                    iconBgColor: iconBgColor,
                    title: 'appLanguage'.tr(context, ref),
                    description: 'desc_language'.tr(context, ref),
                    onTap: () =>
                        _navigateTo(context, const LanguageSettingsPage()),
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
                    onTap: () =>
                        _navigateTo(context, const PathugappuAmaippugalPage()),
                  ),
                  ElvanSettingsRow(
                    icon: CupertinoIcons.info_circle_fill,
                    iconBgColor: iconBgColor,
                    title: 'menporul_vadivalar'.tr(context, ref),
                    description: 'desc_about'.tr(context, ref),
                    onTap: () =>
                        _navigateTo(context, const AboutDeveloperPage()),
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
