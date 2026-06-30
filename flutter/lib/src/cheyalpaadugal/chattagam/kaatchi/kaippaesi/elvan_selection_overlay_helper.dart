import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/patrucheettu_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';

import '../../../niril_podhu/tharavuthalam/app_database.dart';

import '../../../../koorugal/podhu_koorugal/elvan_thervu_pattai.dart';
import '../../../../koorugal/maeladukkugal/elvan_azhippu_urudhi_meladukku.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pothu_snack_bar.dart';

import '../../../../adippadai/vazhikaattal/navigation_provider.dart';

class SelectionOverlayHelper {
  static Widget? buildOverlay(BuildContext context, WidgetRef ref, int tabIndex, NirilNavigationState navState) {
    final mode = ref.watch(appModeProvider) ?? AppMode.silk;
    
    if (tabIndex == 1) { // Invoices / Receipts
      if (navState.uruvakkuSegment == 0) { // Invoices
        final isSelecting = ref.watch(pattiyalSelectionModeProvider);
        if (!isSelecting) return null;
        
        final selectedIds = ref.watch(selectedPattiyalIdsProvider);
        
        return ElvanThervuPattai(
          selectedCount: selectedIds.length,
          onSelectAll: () {
            // Need to get filtered IDs
            final query = mode == AppMode.coolie 
                ? ref.read(coolieInvoicesSearchQueryProvider) 
                : ref.read(silkInvoicesSearchQueryProvider);
            final items = ref.read(pattiyalgalProvider).value ?? [];
            final primaryLang = ref.read(mode == AppMode.coolie ? kooliAchuMozhiProvider : silkAchuMozhiProvider);
            final secondaryLang = primaryLang == 'Tamil' ? 'English' : 'Tamil';
            
            final filtered = query.isEmpty ? items : items.where((p) {
              final en = p.patrucheettuEn.toLowerCase();
              final peyarPrimary = (p.vaangunarPeyar[primaryLang] ?? '').toLowerCase();
              final peyarSecondary = (p.vaangunarPeyar[secondaryLang] ?? '').toLowerCase();
              return en.contains(query) || peyarPrimary.contains(query) || peyarSecondary.contains(query);
            }).toList();
            
            ref.read(selectedPattiyalIdsProvider.notifier).state = filtered.map((e) => e.id).toSet();
          },
          onDelete: () => _deletePattiyalgal(context, ref, selectedIds.toList()),
          onCancel: () {
            ref.read(pattiyalSelectionModeProvider.notifier).state = false;
            ref.read(selectedPattiyalIdsProvider.notifier).state = {};
          },
        );
      } else { // Receipts
        final isSelecting = ref.watch(patruSelectionModeProvider);
        if (!isSelecting) return null;
        
        final selectedIds = ref.watch(selectedPatruIdsProvider);
        
        return ElvanThervuPattai(
          selectedCount: selectedIds.length,
          onSelectAll: () {
            final query = mode == AppMode.coolie 
                ? ref.read(coolieReceiptsSearchQueryProvider) 
                : ref.read(silkReceiptsSearchQueryProvider);
            final items = ref.read(patrucheettugalProvider).value ?? [];
            final primaryLang = ref.read(mode == AppMode.coolie ? kooliAchuMozhiProvider : silkAchuMozhiProvider);
            final secondaryLang = primaryLang == 'Tamil' ? 'English' : 'Tamil';
            
            final filtered = query.isEmpty ? items : items.where((p) {
              final en = p.patrucheettuEn.toLowerCase();
              final peyarPrimary = (p.vaangunarPeyar[primaryLang] ?? '').toLowerCase();
              final peyarSecondary = (p.vaangunarPeyar[secondaryLang] ?? '').toLowerCase();
              return en.contains(query) || peyarPrimary.contains(query) || peyarSecondary.contains(query);
            }).toList();
            
            ref.read(selectedPatruIdsProvider.notifier).state = filtered.map((e) => e.id).toSet();
          },
          onDelete: () => _deletePatrucheettugal(context, ref, selectedIds.toList()),
          onCancel: () {
            ref.read(patruSelectionModeProvider.notifier).state = false;
            ref.read(selectedPatruIdsProvider.notifier).state = {};
          },
        );
      }
    } else if (tabIndex == 2) { // Products
      final isSelecting = ref.watch(porulSelectionModeProvider);
      if (!isSelecting) return null;
      
      final selectedIds = ref.watch(selectedPorulIdsProvider);
      
      return ElvanThervuPattai(
        selectedCount: selectedIds.length,
        onSelectAll: () {
          final query = mode == AppMode.coolie 
              ? ref.read(coolieItemsSearchQueryProvider) 
              : ref.read(silkItemsSearchQueryProvider);
          final items = ref.read(porutkalListProvider).value ?? [];
          final primaryLang = ref.read(mode == AppMode.coolie ? kooliAchuMozhiProvider : silkAchuMozhiProvider);
            final secondaryLang = primaryLang == 'Tamil' ? 'English' : 'Tamil';
            
          final filtered = query.isEmpty ? items : items.where((p) {
            final peyarPrimary = (p.peyar[primaryLang] ?? '').toLowerCase();
            final peyarSecondary = (p.peyar[secondaryLang] ?? '').toLowerCase();
            return peyarPrimary.contains(query) || peyarSecondary.contains(query);
          }).toList();
          
          ref.read(selectedPorulIdsProvider.notifier).state = filtered.map((e) => e.id).toSet();
        },
        onDelete: () => _deletePorutkal(context, ref, selectedIds.toList()),
        onCancel: () {
          ref.read(porulSelectionModeProvider.notifier).state = false;
          ref.read(selectedPorulIdsProvider.notifier).state = {};
        },
      );
    } else if (tabIndex == 3) { // Merchants
      final isSelecting = ref.watch(vaangunarSelectionModeProvider);
      if (!isSelecting) return null;
      
      final selectedIds = ref.watch(selectedVaangunarIdsProvider);
      
      return ElvanThervuPattai(
        selectedCount: selectedIds.length,
        onSelectAll: () {
          final query = mode == AppMode.coolie 
              ? ref.read(coolieMerchantsSearchQueryProvider) 
              : ref.read(silkMerchantsSearchQueryProvider);
          final items = ref.read(vaangunargalListProvider).value ?? [];
          final primaryLang = ref.read(mode == AppMode.coolie ? kooliAchuMozhiProvider : silkAchuMozhiProvider);
          final secondaryLang = primaryLang == 'Tamil' ? 'English' : 'Tamil';
            
          final filtered = query.isEmpty ? items : items.where((p) {
            final peyarPrimary = (p.peyar[primaryLang] ?? '').toLowerCase();
            final peyarSecondary = (p.peyar[secondaryLang] ?? '').toLowerCase();
            return peyarPrimary.contains(query) || peyarSecondary.contains(query);
          }).toList();
          
          ref.read(selectedVaangunarIdsProvider.notifier).state = filtered.map((e) => e.id).toSet();
        },
        onDelete: () => _deleteVaangunargal(context, ref, selectedIds.toList()),
        onCancel: () {
          ref.read(vaangunarSelectionModeProvider.notifier).state = false;
          ref.read(selectedVaangunarIdsProvider.notifier).state = {};
        },
      );
    }
    
    return null;
  }

  static void _deletePattiyalgal(BuildContext context, WidgetRef ref, List<int> ids) {
    showElvanConfirmDialog(
      context: context,
      title: K.azhippaiUrudhiCheyga.tr(context, ref),
      message: '${ids.length} ${K.pattiyalgal.tr(context, ref).toLowerCase()} ${K.azhikkaUrudhiyagaUleerhala.tr(context, ref)}',
      confirmText: K.azhi.tr(context, ref),
      onConfirm: () async {
        final db = ref.read(pattiyalDatabaseProvider);
        for (final id in ids) {
          await db.deletePattiyal(id);
        }
        if (!context.mounted) return;
        ref.read(pattiyalSelectionModeProvider.notifier).state = false;
        ref.read(selectedPattiyalIdsProvider.notifier).state = {};
        ElvanSnackBar.showSuccess(context, '${ids.length} ${K.pattiyalgal.tr(context, ref).toLowerCase()} ${K.azhikkapattadhu.tr(context, ref)}');
      },
    );
  }

  static void _deletePatrucheettugal(BuildContext context, WidgetRef ref, List<int> ids) {
    showElvanConfirmDialog(
      context: context,
      title: K.azhippaiUrudhiCheyga.tr(context, ref),
      message: '${ids.length} ${K.patrucheettugal.tr(context, ref).toLowerCase()} ${K.azhikkaUrudhiyagaUleerhala.tr(context, ref)}',
      confirmText: K.azhi.tr(context, ref),
      onConfirm: () async {
        final db = ref.read(patrucheettuDatabaseProvider);
        for (final id in ids) {
          await db.deletePatrucheettu(id);
        }
        if (!context.mounted) return;
        ref.read(patruSelectionModeProvider.notifier).state = false;
        ref.read(selectedPatruIdsProvider.notifier).state = {};
        ElvanSnackBar.showSuccess(context, '${ids.length} ${K.patrucheettugal.tr(context, ref).toLowerCase()} ${K.azhikkapattadhu.tr(context, ref)}');
      },
    );
  }

  static void _deletePorutkal(BuildContext context, WidgetRef ref, List<int> ids) {
    showElvanConfirmDialog(
      context: context,
      title: K.azhippaiUrudhiCheyga.tr(context, ref),
      message: '${ids.length} ${K.porutkal.tr(context, ref).toLowerCase()} ${K.azhikkaUrudhiyagaUleerhala.tr(context, ref)}',
      confirmText: K.azhi.tr(context, ref),
      onConfirm: () async {
        final db = ref.read(porulDatabaseProvider);
        for (final id in ids) {
          await db.deletePorul(id);
        }
        if (!context.mounted) return;
        ref.read(porulSelectionModeProvider.notifier).state = false;
        ref.read(selectedPorulIdsProvider.notifier).state = {};
        ElvanSnackBar.showSuccess(context, '${ids.length} ${K.porutkal.tr(context, ref).toLowerCase()} ${K.azhikkapattadhu.tr(context, ref)}');
      },
    );
  }

  static void _deleteVaangunargal(BuildContext context, WidgetRef ref, List<int> ids) {
    showElvanConfirmDialog(
      context: context,
      title: K.azhippaiUrudhiCheyga.tr(context, ref),
      message: '${ids.length} ${K.vaangunargal.tr(context, ref).toLowerCase()} ${K.azhikkaUrudhiyagaUleerhala.tr(context, ref)}',
      confirmText: K.azhi.tr(context, ref),
      onConfirm: () async {
        final db = ref.read(vaangunarDatabaseProvider);
        for (final id in ids) {
          await db.deleteVaangunar(id);
        }
        if (!context.mounted) return;
        ref.read(vaangunarSelectionModeProvider.notifier).state = false;
        ref.read(selectedVaangunarIdsProvider.notifier).state = {};
        ElvanSnackBar.showSuccess(context, '${ids.length} ${K.vaangunargal.tr(context, ref).toLowerCase()} ${K.azhikkapattadhu.tr(context, ref)}');
      },
    );
  }
}
