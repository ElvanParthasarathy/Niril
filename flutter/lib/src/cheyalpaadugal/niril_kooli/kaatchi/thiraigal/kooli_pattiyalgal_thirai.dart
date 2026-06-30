import 'package:elvan_niril/src/adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
import 'package:elvan_niril/src/cheyalpaadugal/amaippugal/tharavu/kooli_niruvana_tharavugal_provider.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
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
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';

import '../thiruthi/pattiyal/niril_kooli_pattiyal_thiruthi.dart';

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
    final pattiyalgalAsync = ref.watch(pattiyalgalProvider);
    final profilesAsync = ref.watch(kooliNiruvanaTharavugalListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(pattiyalSelectionModeProvider);
    final selectedIds = ref.watch(selectedPattiyalIdsProvider);

    final currentLocale = ref.watch(localeProvider);
    final primaryLang = ref.watch(kooliAchuMozhiProvider);
    final secondaryLang = primaryLang == 'Tamil' ? 'English' : 'Tamil';

    return pattiyalgalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (pattiyalgal) {
        final profiles = profilesAsync;

        // Filter by search query
        final filtered = query.isEmpty
            ? pattiyalgal
            : pattiyalgal.where((p) {
                final en = p.patrucheettuEn.toLowerCase();
                final peyarPrimary = (p.vaangunarPeyar[primaryLang] ?? '').toLowerCase();
                final peyarSecondary = (p.vaangunarPeyar[secondaryLang] ?? '').toLowerCase();
                return en.contains(query) || 
                       peyarPrimary.contains(query) || 
                       peyarSecondary.contains(query);
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
                    K.pattiyalgalIllai.tr(context, ref),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    K.pudhiyaPattiyalPtn.tr(context, ref),
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
        final grouped = <int?, List<PattiyalTharavuru>>{};
        for (final p in filtered) {
          grouped.putIfAbsent(p.niruvanamId, () => []).add(p);
        }

        // Build section slivers
        final slivers = <Widget>[];


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
                  index: index,
                  pattiyal: pattiyal,
                  isDark: isDark,
                  isSelecting: isSelecting,
                  isSelected: isSelected,
                  dateFormat: _dateFormat,
                  currencyFormat: _currencyFormat,
                  primaryLang: primaryLang,
                  secondaryLang: secondaryLang,
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

}


// ── Coolie Invoice Card ─────────────────────────────────────────────────────

class _CooliePatrucheettuCard extends StatelessWidget {
  const _CooliePatrucheettuCard({
    required this.index,
    required this.pattiyal,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.dateFormat,
    required this.currencyFormat,
    required this.primaryLang,
    required this.secondaryLang,
    required this.onTap,
    required this.onLongPress,
  });

  final int index;
  final PattiyalTharavuru pattiyal;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final String primaryLang;
  final String secondaryLang;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

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
            // Index circle / selection checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isSelecting && isSelected)
                    ? Theme.of(context).colorScheme.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08)),
              ),
              alignment: Alignment.center,
              child: (isSelecting && isSelected)
                  ? const Icon(
                      CupertinoIcons.checkmark_alt,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
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
                    pattiyal.vaangunarPeyar[primaryLang]?.isNotEmpty == true
                        ? pattiyal.vaangunarPeyar[primaryLang]!
                        : pattiyal.vaangunarPeyar[secondaryLang] ?? '',
                    style: const TextStyle(
                      fontSize: 15.2,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Row 2: placeholder (no secondary name yet)
                  // Row 3: Bill number • date
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
          ],
        ),
      ),
    );
  }
}
