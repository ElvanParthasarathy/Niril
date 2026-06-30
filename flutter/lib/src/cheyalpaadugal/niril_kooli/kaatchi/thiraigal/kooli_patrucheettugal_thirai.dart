import 'package:elvan_niril/src/adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
import 'package:elvan_niril/src/cheyalpaadugal/amaippugal/tharavu/kooli_niruvana_tharavugal_provider.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:elvan_niril/src/koorugal/podhu_koorugal/elvan_pothu_attai.dart';
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
    final profilesAsync = ref.watch(kooliNiruvanaTharavugalListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(patruSelectionModeProvider);
    final selectedIds = ref.watch(selectedPatruIdsProvider);
    
    final currentLocale = ref.watch(localeProvider);
    final primaryLang = ref.watch(kooliAchuMozhiProvider);
    final secondaryLang = primaryLang == 'Tamil' ? 'English' : 'Tamil';

    return patrugalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (patrugal) {
        final profiles = profilesAsync;

        // Filter by search query
        final filtered = query.isEmpty
            ? patrugal
            : patrugal.where((p) {
                final en = p.patruEn.toLowerCase();
                final peyarPrimary = (p.vaangunarPeyar[primaryLang] ?? '').toLowerCase();
                final peyarSecondary = (p.vaangunarPeyar[secondaryLang] ?? '').toLowerCase();
                final vagai = p.seluthumMurai.toLowerCase();
                return en.contains(query) ||
                    peyarPrimary.contains(query) ||
                    peyarSecondary.contains(query) ||
                    vagai.contains(query);
              }).toList();

        // Empty state
        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.string(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256"><path d="M72,104a8,8,0,0,1,8-8h96a8,8,0,0,1,0,16H80A8,8,0,0,1,72,104Zm8,40h96a8,8,0,0,0,0-16H80a8,8,0,0,0,0,16ZM232,56V208a8,8,0,0,1-11.58,7.15L192,200.94l-28.42,14.21a8,8,0,0,1-7.16,0L128,200.94,99.58,215.15a8,8,0,0,1-7.16,0L64,200.94,35.58,215.15A8,8,0,0,1,24,208V56A16,16,0,0,1,40,40H216A16,16,0,0,1,232,56Zm-16,0H40V195.06l20.42-10.22a8,8,0,0,1,7.16,0L96,199.06l28.42-14.22a8,8,0,0,1,7.16,0L160,199.06l28.42-14.22a8,8,0,0,1,7.16,0L216,195.06Z"></path></svg>',
                    width: 48,
                    height: 48,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white24 : Colors.black26,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    K.patrucheettugalIllai.tr(context, ref),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    K.pudhiyaPatrucheettuPtn.tr(context, ref),
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
        final grouped = <int?, List<PatrugalTharavuru>>{};
        for (final p in filtered) {
          grouped.putIfAbsent(p.niruvanamId, () => []).add(p);
        }

        final slivers = <Widget>[];


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
                      primaryLang: primaryLang,
                      secondaryLang: secondaryLang,
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

}


// ── Receipt Card ────────────────────────────────────────────────────────────

class _PatruCard extends ConsumerWidget {
  const _PatruCard({
    required this.patru,
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

  final PatrugalTharavuru patru;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = SeluthiVagaiX.fromStored(patru.seluthumMurai);

    return ElvanPothuAttai(
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14.0,
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
                    ? (isDark ? Colors.white : Colors.black)
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
                          patru.vaangunarPeyar[primaryLang]?.isNotEmpty == true
                              ? patru.vaangunarPeyar[primaryLang]!
                              : patru.vaangunarPeyar[secondaryLang] ?? patru.patruEn,
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
                            mode.label(context, ref),
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
      );
  }
}
