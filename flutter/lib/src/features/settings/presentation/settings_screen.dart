import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

import '../../../localization/locale_provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/app_mode.dart';
import '../../shell/presentation/mobile/elvan_subpage_shell.dart';
import 'pages/vanigar_amaippugal_page.dart';
import 'pages/mugavari_page.dart';
import 'pages/vangi_page.dart';
import 'pages/uruvakku_amaippugal_page.dart';
import 'pages/seyali_amaippugal_page.dart';
import 'pages/pathugappu_amaippugal_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return ElvanSubpageShell(
      title: 'settings'.tr(context, ref),
      startCollapsed: false,
      slivers: [
        SliverList.list(
          children: [
            // ── Mode Switcher & Merchant Settings (Big Pill) ──
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
              child: _SettingsSection(
                cardColor: cardColor,
                dividerColor: dividerColor,
                borderRadius: 999.0,
                children: [
                  Stack(
                    children: [
                      // The main pill body (Navigates to Merchant Settings)
                      InkWell(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(builder: (_) => const VanigarAmaippugalPage()));
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
                                  'vanigar_amaippugal'.tr(context, ref),
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
                                currentMode == AppMode.coolie ? AppMode.gst : AppMode.coolie
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

            // ── Section 1: Domain-specific settings ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SettingsSection(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  _SettingsRow(
                    icon: CupertinoIcons.location_solid,
                    iconBgColor: iconBgColor,
                    title: 'settings_mugavari'.tr(context, ref),
                    description: 'Company address details',
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const MugavariPage())),
                  ),
                  _SettingsRow(
                    icon: CupertinoIcons.creditcard_fill,
                    iconBgColor: iconBgColor,
                    title: 'vangi'.tr(context, ref),
                    description: 'Account number & IFSC',
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const VangiPage())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 2: Creation settings ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SettingsSection(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  _SettingsRow(
                    icon: CupertinoIcons.doc_text_fill,
                    iconBgColor: iconBgColor,
                    title: 'uruvakku_amaippugal'.tr(context, ref),
                    description: 'Invoice styling options',
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const UruvakkuAmaippugalPage())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 3: Global settings ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SettingsSection(
                cardColor: cardColor,
                dividerColor: dividerColor,
                children: [
                  _SettingsRow(
                    icon: CupertinoIcons.settings_solid,
                    iconBgColor: iconBgColor,
                    title: 'seyali_amaippugal'.tr(context, ref),
                    description: 'UI language & theme',
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const SeyaliAmaippugalPage())),
                  ),
                  _SettingsRow(
                    icon: CupertinoIcons.lock_fill,
                    iconBgColor: iconBgColor,
                    title: 'pathugappu_amaippugal'.tr(context, ref),
                    description: 'Clear cache, Account security',
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const PathugappuAmaippugalPage())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Bottom padding restored as a spacer at the end of the list
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SettingsSection — Groups rows inside a single rounded card with dividers
// Mirrors the React ElvanSettingsSection SettingsSection component exactly.
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.children,
    required this.cardColor,
    required this.dividerColor,
    this.title,
    this.borderRadius = 24.0,
  });

  final List<Widget> children;
  final Color cardColor;
  final Color dividerColor;
  final String? title;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Material(
            color: cardColor,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 72,
                      endIndent: 20,
                      color: dividerColor,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SettingsRow — A single settings item with circular icon, title, description
// Mirrors the React ElvanSettingsSection SettingsRow component exactly.
// Padding: 16px vertical, 20px horizontal (matches React's p: '16px 20px')
// Icon: 36px circle with monochrome background
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.description,
    this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Circular icon container — 36px, monochrome background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Center(
                child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 16),
            // Title + Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Trailing chevron
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}