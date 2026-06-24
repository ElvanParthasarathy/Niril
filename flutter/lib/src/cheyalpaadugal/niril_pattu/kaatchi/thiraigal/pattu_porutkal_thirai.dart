import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../adippadai/vazhikaattal/niril_nav.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';
import '../thiruthi/porul/niril_pattu_porul_thiruthi.dart';

class SilkItemsPage extends ConsumerWidget {
  const SilkItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(silkItemsSearchQueryProvider).toLowerCase();
    final porulgalAsync = ref.watch(porulgalProvider);
    final primaryLang = ref.watch(primaryLanguageProvider);
    final secondaryLang = ref.watch(secondaryLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(porulSelectionModeProvider);
    final selectedIds = ref.watch(selectedPorulIdsProvider);

    return porulgalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (porulgal) {
        // Filter by search query
        final filtered = query.isEmpty
            ? porulgal
            : porulgal.where((p) {
                final primary = (p.porulPeyar[primaryLang] ?? '').toLowerCase();
                final secondary =
                    (p.porulPeyar[secondaryLang] ?? '').toLowerCase();
                final hsn = p.hsnCode.toLowerCase();
                return primary.contains(query) ||
                    secondary.contains(query) ||
                    hsn.contains(query);
              }).toList();

        // Empty state
        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.cube_box,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    K.porulgalIllai.tr(context, ref),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    K.porulaiChaerkkavum.tr(context, ref),
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
                      ref.read(selectedPorulIdsProvider.notifier).state =
                          filtered.map((p) => p.id).toSet();
                    },
                    onDelete: () {
                      _showBulkDeleteConfirm(
                          context, ref, selectedIds.toList());
                    },
                    onCancel: () {
                      ref.read(porulSelectionModeProvider.notifier).state =
                          false;
                      ref.read(selectedPorulIdsProvider.notifier).state = {};
                    },
                  ),
                ),

              // ── Product Grid ──
              ElvanResponsiveGrid(
                itemCount: filtered.length,
                desktopCrossAxisCount: 2,
                childAspectRatio: 2.8,
                mobileItemHeight: 100,
                itemBuilder: (context, index) {
                  final porul = filtered[index];
                  final isSelected = selectedIds.contains(porul.id);

                  return _SilkPorulCard(
                    index: index,
                    porul: porul,
                    primaryLang: primaryLang,
                    secondaryLang: secondaryLang,
                    isDark: isDark,
                    isSelecting: isSelecting,
                    isSelected: isSelected,
                    onTap: () {
                      if (isSelecting) {
                        _toggleSelection(ref, porul.id, selectedIds);
                      } else {
                        NirilNav.push(
                          context,
                          SilkItemEditor(product: porul),
                        );
                      }
                    },
                    onLongPress: () {
                      if (!isSelecting) {
                        ref.read(porulSelectionModeProvider.notifier).state =
                            true;
                        ref.read(selectedPorulIdsProvider.notifier).state = {
                          porul.id
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
    ref.read(selectedPorulIdsProvider.notifier).state = updated;

    if (updated.isEmpty) {
      ref.read(porulSelectionModeProvider.notifier).state = false;
    }
  }

  void _showBulkDeleteConfirm(
      BuildContext context, WidgetRef ref, List<int> ids) {
    if (ids.isEmpty) return;

    showElvanActionSheet(
      context: context,
      title: '${ids.length} ${K.porulAzhikkappattadhu.tr(context, ref)}',
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(porulKalanjiyamProvider).bulkDeletePorulgal(ids);
        ref.invalidate(porulgalProvider);
        ref.read(porulSelectionModeProvider.notifier).state = false;
        ref.read(selectedPorulIdsProvider.notifier).state = {};
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onSelectAll,
              child: Row(
                children: [
                  Icon(
                    selectedCount > 0
                        ? CupertinoIcons.checkmark_square_fill
                        : CupertinoIcons.square,
                    size: 22,
                    color: selectedCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$selectedCount ${K.thaerndhedu.tr(context, ref)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onCancel,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 24,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: selectedCount > 0 ? onDelete : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedCount > 0
                      ? Colors.red.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  size: 20,
                  color: selectedCount > 0
                      ? Colors.red
                      : (isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product Card Widget ─────────────────────────────────────────────────────

class _SilkPorulCard extends StatelessWidget {
  const _SilkPorulCard({
    required this.index,
    required this.porul,
    required this.primaryLang,
    required this.secondaryLang,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final int index;
  final PorulEntry porul;
  final String primaryLang;
  final String secondaryLang;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final primary = porul.porulPeyar[primaryLang] ?? '';
    final secondary = porul.porulPeyar[secondaryLang] ?? '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? const Color(0xFF1A1A1A)
                  : Colors.black.withValues(alpha: 0.04))
              : (isDark
                  ? const Color(0xFF111111)
                  : Colors.white),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index circle or selection checkbox
            if (isSelecting)
              Icon(
                isSelected
                    ? CupertinoIcons.checkmark_square_fill
                    : CupertinoIcons.square,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white38 : Colors.black38),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                alignment: Alignment.center,
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.2,
                    color: isDark ? Colors.white : Colors.black,
                    height: 1,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    primary,
                    style: const TextStyle(
                      fontSize: 15.2,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (secondary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      secondary,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Row 2: HSN + Tax % + Rate
                  Row(
                    children: [
                      if (porul.hsnCode.isNotEmpty) ...[
                        Text(
                          'HSN: ${porul.hsnCode}',
                          style: TextStyle(
                            fontSize: 13.6,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        'GST: ${porul.variVeetham.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 13.6,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const Spacer(),
                      if (porul.vilai > 0)
                        Text(
                          '₹${porul.vilai.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
