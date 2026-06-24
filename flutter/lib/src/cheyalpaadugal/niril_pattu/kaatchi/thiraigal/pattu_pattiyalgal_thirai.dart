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

import '../thiruthi/niril_pattu_pattiyal_thiruthi.dart';

/// Silk invoice list — real DB-backed view.
/// Shows invoices grouped by business profile with search, selection, and
/// tap-to-edit navigation.
class SilkInvoicesPage extends ConsumerWidget {
  const SilkInvoicesPage({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(silkInvoicesSearchQueryProvider).toLowerCase();
    final pattiyalgalAsync = ref.watch(pattiyalgalStreamProvider);
    final profilesAsync = ref.watch(currentModeProfilesStreamProvider);
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
              childAspectRatio: 3.2,
              mobileItemHeight: 88,
              itemBuilder: (context, index) {
                final pattiyal = items[index];
                final isSelected = selectedIds.contains(pattiyal.id);

                return _SilkPatrucheettuCard(
                  index: index,
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
                          builder: (_) => SilkInvoiceEditor(
                            editingEntry: pattiyal,
                          ),
                        ),
                      );
                    }
                  },
                  onDuplicate: () {
                    // Open editor with same data but no editingEntry (creates new)
                    // We pass the entry as a "duplicate source" via a new constructor param
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SilkInvoiceEditor(
                          duplicateFrom: pattiyal,
                        ),
                      ),
                    );
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

// ── Silk Invoice Card ───────────────────────────────────────────────────────

class _SilkPatrucheettuCard extends StatelessWidget {
  const _SilkPatrucheettuCard({
    required this.index,
    required this.pattiyal,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
    required this.onLongPress,
    required this.onDuplicate,
  });

  final int index;
  final PatrucheettuEntry pattiyal;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final amountStr = currencyFormat.format(pattiyal.mothaThogai);

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
            // Content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Customer name (primary)
                  Text(
                    pattiyal.vanigarPeyar,
                    style: const TextStyle(
                      fontSize: 15.2,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Row 2: placeholder (no secondary name yet)
                  // Row 3: Invoice number • date
                  const SizedBox(height: 4),
                  Text(
                    '${pattiyal.patrucheettuEn} • ${dateFormat.format(pattiyal.pattiyalNaal)}',
                    style: TextStyle(
                      fontSize: 13.6,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  // Row 4: Amount
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        amountStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: amountStr.length > 11 ? 12.8 : 15.2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // More menu (duplicate, etc.)
            if (!isSelecting)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'duplicate') onDuplicate();
                },
              ),
          ],
        ),
      ),
    );
  }
}
