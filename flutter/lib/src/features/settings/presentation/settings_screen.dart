import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

import '../../../localization/locale_provider.dart';
import '../../shell/presentation/mobile/elvan_subpage_shell.dart';
import 'pages/vanigar_amaippugal_page.dart';
import 'pages/mugavari_page.dart';
import 'pages/vangi_page.dart';
import 'pages/uruvakku_amaippugal_page.dart';
import 'pages/seyali_amaippugal_page.dart';
import 'pages/pathugappu_amaippugal_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanSubpageShell(
      title: 'settings'.tr(context, ref),
      startCollapsed: false, // Settings Home acts like a Main Tab, so it MUST start fully expanded!
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 32),
          sliver: SliverList.list(
            children: [
              _buildSettingsTile(
                context,
                'vanigar_amaippugal'.tr(context, ref),
                CupertinoIcons.building_2_fill,
                () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const VanigarAmaippugalPage())),
              ),
              _buildSettingsTile(
                context,
                'settings_mugavari'.tr(context, ref),
                CupertinoIcons.location_solid,
                () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const MugavariPage())),
              ),
              _buildSettingsTile(
                context,
                'vangi'.tr(context, ref),
                CupertinoIcons.building_2_fill,
                () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const VangiPage())),
              ),
              _buildSettingsTile(
                context,
                'uruvakku_amaippugal'.tr(context, ref),
                CupertinoIcons.doc_text_fill,
                () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const UruvakkuAmaippugalPage())),
              ),
              const SizedBox(height: 16), // Separator between Domain and Global settings
              _buildSettingsTile(
                context,
                'seyali_amaippugal'.tr(context, ref),
                CupertinoIcons.settings_solid,
                () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const SeyaliAmaippugalPage())),
              ),
              _buildSettingsTile(
                context,
                'pathugappu_amaippugal'.tr(context, ref),
                CupertinoIcons.lock_fill,
                () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const PathugappuAmaippugalPage())),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Dummy Items (For Testing Scroll)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...List.generate(
                20,
                (index) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  child: ListTile(
                    title: Text('Dummy Setting ${index + 1}'),
                    subtitle: const Text('This is a test item'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}