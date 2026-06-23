import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../adippadai/vazhikaattal/niril_nav.dart';
import '../../../../koorugal/meladukkugal/elvan_cheyal_meladukku.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/vanigar_nilaimai.dart';
import '../thiruthi/niril_kooli_vanigar_thiruthi.dart';

class CoolieMerchantsPage extends ConsumerWidget {
  const CoolieMerchantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieMerchantsSearchQueryProvider).toLowerCase();
    final vanigargalAsync = ref.watch(vanigargalStreamProvider);
    final primaryLang = ref.watch(primaryLanguageProvider);
    final secondaryLang = ref.watch(secondaryLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(vanigarSelectionModeProvider);
    final selectedIds = ref.watch(selectedVanigarIdsProvider);

    return vanigargalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (vanigargal) {
        // Filter by search query (name + city)
        final filtered = query.isEmpty
            ? vanigargal
            : vanigargal.where((v) {
                final pName = (v.peyar[primaryLang] ?? '').toLowerCase();
                final sName = (v.peyar[secondaryLang] ?? '').toLowerCase();
                final pCity = (v.oor[primaryLang] ?? '').toLowerCase();
                final sCity = (v.oor[secondaryLang] ?? '').toLowerCase();
                return pName.contains(query) ||
                    sName.contains(query) ||
                    pCity.contains(query) ||
                    sCity.contains(query);
              }).toList();

        // Empty state
        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.person_2,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    K.vanigargalIllai.tr(context, ref),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    K.vanigaraiChaerkkavum.tr(context, ref),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
          sliver: SliverMainAxisGroup(
            slivers: [
              // ── Selection Bar ──
              if (isSelecting)
                SliverToBoxAdapter(
                  child: _SelectionBar(
                    selectedCount: selectedIds.length,
                    isDark: isDark,
                    onSelectAll: () {
                      ref.read(selectedVanigarIdsProvider.notifier).state =
                          filtered.map((v) => v.id).toSet();
                    },
                    onDelete: () {
                      _showBulkDeleteConfirm(
                          context, ref, selectedIds.toList());
                    },
                    onCancel: () {
                      ref.read(vanigarSelectionModeProvider.notifier).state =
                          false;
                      ref.read(selectedVanigarIdsProvider.notifier).state = {};
                    },
                  ),
                ),

              // ── Merchant Grid ──
              ElvanResponsiveGrid(
                itemCount: filtered.length,
                desktopCrossAxisCount: 2,
                childAspectRatio: 3.5,
                mobileItemHeight: 80,
                itemBuilder: (context, index) {
                  final vanigar = filtered[index];
                  final isSelected = selectedIds.contains(vanigar.id);

                  return _CoolieVanigarCard(
                    vanigar: vanigar,
                    primaryLang: primaryLang,
                    secondaryLang: secondaryLang,
                    isDark: isDark,
                    isSelecting: isSelecting,
                    isSelected: isSelected,
                    onTap: () {
                      if (isSelecting) {
                        _toggleSelection(ref, vanigar.id, selectedIds);
                      } else {
                        NirilNav.push(
                          context,
                          CoolieMerchantEditor(vanigar: vanigar),
                        );
                      }
                    },
                    onLongPress: () {
                      if (!isSelecting) {
                        ref.read(vanigarSelectionModeProvider.notifier).state =
                            true;
                        ref.read(selectedVanigarIdsProvider.notifier).state = {
                          vanigar.id
                        };
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleSelection(WidgetRef ref, int id, Set<int> current) {
    final updated = Set<int>.from(current);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    ref.read(selectedVanigarIdsProvider.notifier).state = updated;

    if (updated.isEmpty) {
      ref.read(vanigarSelectionModeProvider.notifier).state = false;
    }
  }

  void _showBulkDeleteConfirm(
      BuildContext context, WidgetRef ref, List<int> ids) {
    if (ids.isEmpty) return;

    showElvanActionSheet(
      context: context,
      title: '${ids.length} ${K.vanigarAzhikkappattadhu.tr(context, ref)}',
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(vanigarKalanjiyamProvider).bulkDeleteVanigargal(ids);
        ref.read(vanigarSelectionModeProvider.notifier).state = false;
        ref.read(selectedVanigarIdsProvider.notifier).state = {};
      },
    );
  }
}

// ── Selection Bar Widget ────────────────────────────────────────────────────

class _SelectionBar extends ConsumerWidget {
  const _SelectionBar({
    required this.selectedCount,
    required this.isDark,
    required this.onSelectAll,
    required this.onDelete,
    required this.onCancel,
  });

  final int selectedCount;
  final bool isDark;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount ${K.therindhaedhu.tr(context, ref)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSelectAll,
            child: Text(K.anaithaiyumTheriPtn.tr(context, ref)),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.delete,
                color: Colors.red.withValues(alpha: 0.8), size: 20),
            onPressed: onDelete,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, size: 18),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

// ── Coolie Merchant Card ────────────────────────────────────────────────────

class _CoolieVanigarCard extends StatelessWidget {
  const _CoolieVanigarCard({
    required this.vanigar,
    required this.primaryLang,
    required this.secondaryLang,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final VanigarEntry vanigar;
  final String primaryLang;
  final String secondaryLang;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final primaryName = vanigar.peyar[primaryLang] ?? '';
    final secondaryName = vanigar.peyar[secondaryLang] ?? '';
    final primaryCity = vanigar.oor[primaryLang] ?? '';
    final secondaryCity = vanigar.oor[secondaryLang] ?? '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Selection checkbox
            if (isSelecting) ...[
              Icon(
                isSelected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                size: 22,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white30 : Colors.black26),
              ),
              const SizedBox(width: 12),
            ],
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    primaryName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondaryName.isNotEmpty &&
                      secondaryName != primaryName) ...[
                    const SizedBox(height: 2),
                    Text(
                      secondaryName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (primaryCity.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      secondaryCity.isNotEmpty && secondaryCity != primaryCity
                          ? '$primaryCity • $secondaryCity'
                          : primaryCity,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white26 : Colors.black26,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Chevron
            if (!isSelecting)
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
          ],
        ),
      ),
    );
  }
}
