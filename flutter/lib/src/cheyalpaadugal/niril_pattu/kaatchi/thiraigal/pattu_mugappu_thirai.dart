import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../adippadai/vazhikaattal/navigation_provider.dart';
import '../../../../adippadai/vazhikaattal/navigation_destination.dart';
import '../../../../adippadai/vazhikaattal/niril_nav.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/kaatchi/koorugal/mugappu_tharavugal_kooru.dart';
import '../thiruthi/niril_pattu_pattiyal_thiruthi.dart';

/// Silk Home Page — pixel-perfect port of React Mugappu (GST mode).
/// Shows: 3 stats cards (bento grid) + 6 recent invoice cards.
class SilkHomePage extends ConsumerWidget {
  const SilkHomePage({super.key});

  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pattiyalgalAsync = ref.watch(pattiyalgalStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return pattiyalgalAsync.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              _buildStatsGrid(context, ref, [], isDark, true),
              const SizedBox(height: 24),
              const MugappuLoadingSkeleton(),
            ],
          ),
        ),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (pattiyalgal) {
        // Sort by date descending, take top 6
        final sorted = [...pattiyalgal]
          ..sort((a, b) => b.pattiyalNaal.compareTo(a.pattiyalNaal));
        final recentBills = sorted.take(6).toList();

        return SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats bento grid
                _buildStatsGrid(
                    context, ref, pattiyalgal, isDark, false),
                const SizedBox(height: 8),

                // Recent activity header
                RecentActivityHeader(
                  onSeeAll: () {
                    ref
                        .read(nirilNavigationProvider.notifier)
                        .goTo(NirilDestination.pattiyal);
                  },
                ),

                // Recent invoice cards
                if (pattiyalgal.isEmpty)
                  const MugappuEmptyState()
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 800;
                      if (isDesktop) {
                        return _buildDesktopGrid(recentBills, context, ref);
                      }
                      return _buildMobileList(recentBills, context, ref);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Stats Bento Grid ────────────────────────────────────────────────────

  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref,
    List<PatrucheettuEntry> pattiyalgal,
    bool isDark,
    bool isLoading,
  ) {
    // Compute stats
    double totalAmount = 0;
    double totalTax = 0;

    for (final b in pattiyalgal) {
      totalAmount += b.mothaThogai;
      totalTax += b.variThogai;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        final gap = isDesktop ? 24.0 : 16.0;

        if (isDesktop) {
          // 3-column grid
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ElvanStatsCard(
                  icon: CupertinoIcons.money_dollar_circle,
                  label: K.mothaKanakku.tr(context, ref),
                  value: _currencyFormat.format(totalAmount),
                  isLoading: isLoading,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: ElvanStatsCard(
                  icon: CupertinoIcons.graph_square,
                  label: K.variThirattiyavai.tr(context, ref),
                  value: _currencyFormat.format(totalTax),
                  isLoading: isLoading,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: ElvanStatsCard(
                  icon: CupertinoIcons.doc_text,
                  label: K.pattiyalEnnikai.tr(context, ref),
                  value: '${pattiyalgal.length}',
                  isLoading: isLoading,
                ),
              ),
            ],
          );
        }

        // Mobile: 2-col only (third card hidden on mobile — matches React)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ElvanStatsCard(
                icon: CupertinoIcons.money_dollar_circle,
                label: K.mothaKanakku.tr(context, ref),
                value: _currencyFormat.format(totalAmount),
                isLoading: isLoading,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: ElvanStatsCard(
                icon: CupertinoIcons.graph_square,
                label: K.variThirattiyavai.tr(context, ref),
                value: _currencyFormat.format(totalTax),
                isLoading: isLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Desktop 2-col grid ──────────────────────────────────────────────────

  Widget _buildDesktopGrid(
    List<PatrucheettuEntry> items,
    BuildContext context,
    WidgetRef ref,
  ) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ElvanRecentCard(
                  index: i,
                  pattiyal: items[i],
                  onTap: () => _openEditor(context, items[i]),
                ),
              ),
              const SizedBox(width: 16),
              if (i + 1 < items.length)
                Expanded(
                  child: ElvanRecentCard(
                    index: i + 1,
                    pattiyal: items[i + 1],
                    onTap: () => _openEditor(context, items[i + 1]),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  // ── Mobile list ─────────────────────────────────────────────────────────

  Widget _buildMobileList(
    List<PatrucheettuEntry> items,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElvanRecentCard(
              index: entry.key,
              pattiyal: entry.value,
              onTap: () => _openEditor(context, entry.value),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openEditor(BuildContext context, PatrucheettuEntry pattiyal) {
    NirilNav.push(
      context,
      SilkInvoiceEditor(editingEntry: pattiyal),
    );
  }
}
