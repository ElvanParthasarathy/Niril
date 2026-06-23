import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/meladukkugal/elvan_cheyal_meladukku.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/patru_nilaimai.dart';
import '../thiruthi/niril_kooli_pattiyal_thiruthi.dart';

/// Coolie invoice list — real DB-backed view.
/// Shows invoices grouped by business profile with search, selection, and
/// tap-to-edit navigation.
class CoolieInvoicesPage extends ConsumerWidget {
  const CoolieInvoicesPage({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieInvoicesSearchQueryProvider).toLowerCase();
    final pattiyalgalAsync = ref.watch(pattiyalgalStreamProvider);
    final profilesAsync = ref.watch(profilesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(pattiyalSelectionModeProvider);
    final selectedIds = ref.watch(selectedPattiyalIdsProvider);

    return pattiyalgalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (pattiyalgal) {
        final profiles = profilesAsync.value ?? [];

        // Filter by search query
        final filtered = query.isEmpty
            ? pattiyalgal
            : pattiyalgal.where((p) {
                final en = p.patrucheettuEn.toLowerCase();
                final peyar = p.vanigarPeyar.toLowerCase();
                return en.contains(query) || peyar.contains(query);
              }).toList();

        // Empty state
        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.doc_text,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'பற்றுச்சீட்டுகள் இல்லை',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'புதிய பற்றுச்சீட்டை உருவாக்கவும்',
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

        // Group invoices by niruvanamId
        final grouped = <int?, List<PatrucheettuEntry>>{};
        for (final p in filtered) {
          grouped.putIfAbsent(p.niruvanamId, () => []).add(p);
        }

        // Build section slivers
        final slivers = <Widget>[];

        // Selection bar
        if (isSelecting) {
          slivers.add(
            SliverToBoxAdapter(
              child: _SelectionBar(
                selectedCount: selectedIds.length,
                isDark: isDark,
                onSelectAll: () {
                  ref.read(selectedPattiyalIdsProvider.notifier).state =
                      filtered.map((p) => p.id).toSet();
                },
                onDelete: () {
                  _showBulkDeleteConfirm(
                      context, ref, selectedIds.toList());
                },
                onCancel: () {
                  ref.read(pattiyalSelectionModeProvider.notifier).state =
                      false;
                  ref.read(selectedPattiyalIdsProvider.notifier).state = {};
                },
              ),
            ),
          );
        }

        // Sections per business profile
        for (final entry in grouped.entries) {
          final niruvanamId = entry.key;
          final items = entry.value;

          // Resolve business name
          String sectionName;
          if (niruvanamId == null) {
            sectionName = 'General';
          } else {
            final profile = profiles
                .where((p) => p.id == niruvanamId)
                .firstOrNull;
            sectionName = profile?.kurumPeyar ?? 'General';
          }

          // Show section header only if there's more than one group
          if (grouped.length > 1) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    sectionName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            );
          }

          // Invoice cards for this group
          slivers.add(
            ElvanResponsiveGrid(
              itemCount: items.length,
              desktopCrossAxisCount: 2,
              childAspectRatio: 3.0,
              mobileItemHeight: 96,
              itemBuilder: (context, index) {
                final pattiyal = items[index];
                final isSelected = selectedIds.contains(pattiyal.id);

                return _CooliePatrucheettuCard(
                  pattiyal: pattiyal,
                  isDark: isDark,
                  isSelecting: isSelecting,
                  isSelected: isSelected,
                  dateFormat: _dateFormat,
                  currencyFormat: _currencyFormat,
                  onTap: () {
                    if (isSelecting) {
                      _toggleSelection(ref, pattiyal.id, selectedIds);
                    } else {
                      // Navigate to editor for editing
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CoolieInvoiceEditor(
                            editingEntry: pattiyal,
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    if (!isSelecting) {
                      ref
                          .read(pattiyalSelectionModeProvider.notifier)
                          .state = true;
                      ref
                          .read(selectedPattiyalIdsProvider.notifier)
                          .state = {pattiyal.id};
                    }
                  },
                );
              },
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
          sliver: SliverMainAxisGroup(slivers: slivers),
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
    ref.read(selectedPattiyalIdsProvider.notifier).state = updated;

    if (updated.isEmpty) {
      ref.read(pattiyalSelectionModeProvider.notifier).state = false;
    }
  }

  void _showBulkDeleteConfirm(
      BuildContext context, WidgetRef ref, List<int> ids) {
    if (ids.isEmpty) return;

    showElvanActionSheet(
      context: context,
      title: '${ids.length} ${K.neekkuPtn.tr(context, ref)}',
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(pattiyalKalanjiyamProvider).bulkDeletePattiyalgal(ids);
        ref.read(pattiyalSelectionModeProvider.notifier).state = false;
        ref.read(selectedPattiyalIdsProvider.notifier).state = {};
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
            '$selectedCount ${K.thaerndhedu.tr(context, ref)}',
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

// ── Coolie Invoice Card ─────────────────────────────────────────────────────

class _CooliePatrucheettuCard extends ConsumerWidget {
  const _CooliePatrucheettuCard({
    required this.pattiyal,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
    required this.onLongPress,
  });

  final PatrucheettuEntry pattiyal;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch payment status reactively
    final paidAsync = ref.watch(paidAmountProvider(pattiyal.id));
    final paid = paidAsync.value ?? 0.0;
    final total = pattiyal.mothaThogai;
    final isPaid = paid >= total && total > 0;
    final isPartial = paid > 0 && paid < total;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12)
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
                  Row(
                    children: [
                      Text(
                        pattiyal.patrucheettuEn,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateFormat.format(pattiyal.pattiyalNaal),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  if (pattiyal.vanigarPeyar.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      pattiyal.vanigarPeyar,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Weight badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.orange.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${pattiyal.mothaEdai.toStringAsFixed(2)} KG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.orange.shade200
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                      // Payment status badge
                      if (isPaid) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Paid ✓',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.green.shade300
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ] else if (isPartial) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blue.withValues(alpha: 0.15)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Partial',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        currencyFormat.format(pattiyal.mothaThogai),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.orange.shade200
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            if (!isSelecting) ...[
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
