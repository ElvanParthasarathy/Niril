import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../../niril_podhu/kalanjiyam/patru_nilaimai.dart';
import '../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import '../thiruthi/patrucheettu/niril_kooli_patrucheettu_thiruthi.dart';

/// Coolie Receipt List — real DB-backed view showing payment receipts.
/// Completely separate from invoice list.
class CoolieReceiptsPage extends ConsumerWidget {
  const CoolieReceiptsPage({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieReceiptsSearchQueryProvider).toLowerCase();
    final patrugalAsync = ref.watch(patrugalProvider);
    final profilesAsync = ref.watch(currentModeProfilesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(patruSelectionModeProvider);
    final selectedIds = ref.watch(selectedPatruIdsProvider);

    return patrugalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (patrugal) {
        final profiles = profilesAsync.value ?? [];

        // Filter by search query
        final filtered = query.isEmpty
            ? patrugal
            : patrugal.where((p) {
                final en = p.patruEn.toLowerCase();
                final peyar = p.vanigarPeyar.toLowerCase();
                final vagai = p.seluthiVagai.toLowerCase();
                return en.contains(query) ||
                    peyar.contains(query) ||
                    vagai.contains(query);
              }).toList();

        // Empty state
        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.doc_plaintext,
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

        // Group by niruvanamId
        final grouped = <int?, List<PatrugalEntry>>{};
        for (final p in filtered) {
          grouped.putIfAbsent(p.niruvanamId, () => []).add(p);
        }

        final slivers = <Widget>[];

        // Selection bar
        if (isSelecting) {
          slivers.add(
            SliverToBoxAdapter(
              child: _SelectionBar(
                selectedCount: selectedIds.length,
                isDark: isDark,
                onSelectAll: () {
                  ref.read(selectedPatruIdsProvider.notifier).state =
                      filtered.map((p) => p.id).toSet();
                },
                onDelete: () =>
                    _showBulkDeleteConfirm(context, ref, selectedIds.toList()),
                onCancel: () {
                  ref.read(patruSelectionModeProvider.notifier).state = false;
                  ref.read(selectedPatruIdsProvider.notifier).state = {};
                },
              ),
            ),
          );
        }

        // Sections per business profile
        for (final entry in grouped.entries) {
          final niruvanamId = entry.key;
          final items = entry.value;

          String sectionName;
          if (niruvanamId == null) {
            sectionName = 'General';
          } else {
            final profile =
                profiles.where((p) => p.id == niruvanamId).firstOrNull;
            sectionName = profile?.kurumPeyar ?? 'General';
          }

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

          // Receipt cards
          slivers.add(
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final patru = items[index];
                  final isSelected = selectedIds.contains(patru.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PatruCard(
                      patru: patru,
                      isDark: isDark,
                      isSelecting: isSelecting,
                      isSelected: isSelected,
                      dateFormat: _dateFormat,
                      currencyFormat: _currencyFormat,
                      onTap: () {
                        if (isSelecting) {
                          _toggleSelection(ref, patru.id, selectedIds);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CoolieReceiptEditor(editingEntry: patru),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!isSelecting) {
                          ref.read(patruSelectionModeProvider.notifier).state =
                              true;
                          ref.read(selectedPatruIdsProvider.notifier).state = {
                            patru.id
                          };
                        }
                      },
                    ),
                  );
                },
                childCount: items.length,
              ),
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
    ref.read(selectedPatruIdsProvider.notifier).state = updated;

    if (updated.isEmpty) {
      ref.read(patruSelectionModeProvider.notifier).state = false;
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
        ref.read(patruKalanjiyamProvider).bulkDeletePatrugal(ids);
        ref.invalidate(patrugalProvider);
        ref.read(patruSelectionModeProvider.notifier).state = false;
        ref.read(selectedPatruIdsProvider.notifier).state = {};
      },
    );
  }
}

// ── Selection Bar ───────────────────────────────────────────────────────────

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

// ── Receipt Card ────────────────────────────────────────────────────────────

class _PatruCard extends StatelessWidget {
  const _PatruCard({
    required this.patru,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
    required this.onLongPress,
  });

  final PatrugalEntry patru;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final mode = SeluthiVagaiX.fromStored(patru.seluthiVagai);

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
                  ? const Color(0xFF111111)
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
                  // Row 1: Customer name + date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          patru.vanigarPeyar.isNotEmpty
                              ? patru.vanigarPeyar
                              : patru.patruEn,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(patru.patruNaal),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Row 2: Receipt number + payment mode badge + amount
                  Row(
                    children: [
                      Text(
                        patru.patruEn,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      if (mode != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: mode
                                .badgeColor(isDark)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mode.tamilLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: mode.badgeColor(isDark),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        currencyFormat.format(patru.thogai),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.green.shade300
                              : Colors.green.shade700,
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
