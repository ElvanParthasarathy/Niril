import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../adippadai/panigal/seyali_oaviyangal.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../adippadai/panigal/niril_backup_service.dart';
import '../../tharavu/kooli_niruvana_tharavugal_provider.dart';
import '../../tharavu/pattu_niruvana_tharavugal_provider.dart';
import 'elvan_amaippu_pagudhi.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/thoatra_vazhanguthi.dart';


import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../koorugal/ulleedugal/elvan_ulleedu.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../../../koorugal/maeladukkugal/elvan_aetrum_maeladukku.dart';
import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../adippadai/viruppangal_paniyagam.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/vazhikaattal/navigation_provider.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/patru_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';


final storageStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  final kooliDb = ref.watch(kooliDatabaseProvider);
  final pattuDb = ref.watch(pattuDatabaseProvider);

  final backupStats = await backupService.getBackupStats();
  final dbSize = await backupService.getTotalDatabaseSize();
  
  final kPattiyal = await kooliDb.customSelect('SELECT COUNT(*) FROM kooli_patrucheettu_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  final kPatru = await kooliDb.customSelect('SELECT COUNT(*) FROM kooli_patrugal_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  final kPorul = await kooliDb.customSelect('SELECT COUNT(*) FROM kooli_porul_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  final kVaangunar = await kooliDb.customSelect('SELECT COUNT(*) FROM kooli_vaangunar_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  
  final pPattiyal = await pattuDb.customSelect('SELECT COUNT(*) FROM pattu_patrucheettu_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  final pPatru = await pattuDb.customSelect('SELECT COUNT(*) FROM pattu_patrugal_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  final pPorul = await pattuDb.customSelect('SELECT COUNT(*) FROM pattu_porul_table').getSingle().then((r) => r.read<int>('COUNT(*)'));
  final pVaangunar = await pattuDb.customSelect('SELECT COUNT(*) FROM pattu_vaangunar_table').getSingle().then((r) => r.read<int>('COUNT(*)'));

  return {
    'lastBackup': backupStats?['lastModified'],
    'backupSize': backupStats?['sizeBytes'] ?? 0,
    'totalDbSize': dbSize,
    'kooliInvoices': kPattiyal,
    'kooliReceipts': kPatru,
    'kooliProducts': kPorul,
    'kooliCustomers': kVaangunar,
    'silkInvoices': pPattiyal,
    'silkReceipts': pPatru,
    'silkProducts': pPorul,
    'silkCustomers': pVaangunar,
  };
});

class StorageManagerSection extends ConsumerWidget {
  const StorageManagerSection({super.key});

  Widget _buildDataGrid(BuildContext context, int invoices, int receipts, int customers, int products) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    final style = TextStyle(fontSize: 12, color: color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('$invoices Invoices', style: style)),
            Expanded(child: Text('$receipts Receipts', style: style)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: Text('$customers Customers', style: style)),
            Expanded(child: Text('$products Products', style: style)),
          ],
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(storageStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statsAsync.when(
          data: (stats) {
            final DateTime? lastBackup = stats['lastBackup'];
            final backupDateStr = lastBackup != null 
                ? DateFormat('MMM d, yyyy - h:mm a').format(lastBackup)
                : 'No Backup Yet';

            return Column(
              children: [
                StorageProjectionPill(stats: stats),
                ElvanSettingsSection(
                  children: [
                    ElvanSettingsRow(
                      iconWidget: Icon(
                        CupertinoIcons.folder_solid,
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                      iconBgColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      title: 'Storage Used',
                      description: '${_formatBytes(stats['totalDbSize'])} Database  •  ${_formatBytes(stats['backupSize'])} Backup',
                      onTap: () {},
                    ),
                    ElvanSettingsRow(
                      iconWidget: Icon(
                        CupertinoIcons.time,
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                      iconBgColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      title: 'Last Auto-Backup',
                      description: backupDateStr,
                      onTap: () {},
                    ),
                    ElvanSettingsRow(
                      iconWidget: Icon(
                        CupertinoIcons.cloud_upload_fill,
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                      iconBgColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      title: K.tharavuKaappuChei.tr(context, ref),
                      description: K.ungalTharavaiChaemikkavum.tr(context, ref),
                      onTap: () {
                        _showBackupFlow(context, ref);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElvanSettingsSection(
                  children: [
                    ElvanSettingsRow(
                      iconWidget: SvgPicture.string(
                        AppSvgs.coolieMode,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                      ),
                      iconBgColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      title: 'Coolie Data',
                      crossAxisAlignment: CrossAxisAlignment.start,
                      customDescription: _buildDataGrid(context, stats['kooliInvoices'], stats['kooliReceipts'], stats['kooliCustomers'], stats['kooliProducts']),
                      onTap: () {},
                    ),
                    ElvanSettingsRow(
                      iconWidget: SvgPicture.string(
                        AppSvgs.silkMode,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                      ),
                      iconBgColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      title: 'Silk Data',
                      crossAxisAlignment: CrossAxisAlignment.start,
                      customDescription: _buildDataGrid(context, stats['silkInvoices'], stats['silkReceipts'], stats['silkCustomers'], stats['silkProducts']),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (e, s) => Center(child: Text('Error loading stats: $e')),
        ),
      ],
    );
  }

  void _showBackupFlow(BuildContext context, WidgetRef ref) {
    showElvanActionSheet(
      context: context,
      title: K.tharavuKaappu.tr(context, ref),
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.kaappuCheiPtn.tr(context, ref),
      onConfirm: () async {
        showElvanLoadingOverlay(
            context: context, text: K.chaemikkappadugiradhu.tr(context, ref));
            
        // Wait a small amount of time for UX purposes so it doesn't flash instantly
        await Future.delayed(const Duration(milliseconds: 800));
        
        final backupService = ref.read(backupServiceProvider);
        await backupService.createBackup();

        if (context.mounted) {
          // Pop the loading dialog
          Navigator.of(context, rootNavigator: true).pop();
          ElvanSnackbar.show(context, K.tharavuchaemippuvetri.tr(context, ref));
          ref.invalidate(storageStatsProvider);
        }
      },
    );
  }

}

class StorageProjectionPill extends ConsumerWidget {
  final Map<String, dynamic> stats;
  const StorageProjectionPill({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dbSize = stats['totalDbSize'] as int;
    final totalItems = (stats['kooliInvoices'] as int) + 
                       (stats['kooliReceipts'] as int) + 
                       (stats['kooliCustomers'] as int) + 
                       (stats['kooliProducts'] as int) + 
                       (stats['silkInvoices'] as int) + 
                       (stats['silkReceipts'] as int) + 
                       (stats['silkCustomers'] as int) + 
                       (stats['silkProducts'] as int);
    
    final avgSize = totalItems > 0 ? (dbSize / totalItems) : 4096.0;
    final maxSpace = 1024.0 * 1024.0 * 1024.0; // 1 GB
    final maxItems = (maxSpace / avgSize).floor();
    final remainingItems = (maxItems - totalItems).clamp(0, maxItems);
    final percent = dbSize / maxSpace;

    // Formatting sizes
    String formatBytes(double bytes) {
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB"];
      var i = 0;
      double size = bytes;
      while (size > 1024 && i < suffixes.length - 1) {
        size /= 1024;
        i++;
      }
      return '${size.toStringAsFixed(2)} ${suffixes[i]}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cloud Storage (1GB Limit)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(4)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 28,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${formatBytes(dbSize.toDouble())} used. At your current usage rate, you can store approximately ${NumberFormat.decimalPattern().format(remainingItems)} more items before hitting the free cloud limit.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
