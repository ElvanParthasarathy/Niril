import 'package:elvan_niril/src/adippadai/nilaimai/achu_mozhi_facade.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/vazhikaattal/niril_nav.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';
import 'package:elvan_niril/src/koorugal/podhu_koorugal/elvan_pothu_attai.dart';
import '../thiruthi/porul/niril_kooli_porul_thiruthi.dart';
class CoolieItemsPage extends ConsumerWidget {
  const CoolieItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieItemsSearchQueryProvider).toLowerCase();
    final porulgalAsync = ref.watch(porulgalProvider);
    final primaryLang = ref.watch(primaryLanguageProvider);
    final secondaryLang = ref.watch(secondaryLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;


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
                return primary.contains(query) || secondary.contains(query);
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

              // ── Product Grid ──
              ElvanResponsiveGrid(
                itemCount: filtered.length,
                desktopCrossAxisCount: 2,
                childAspectRatio: 3.5,
                mobileItemHeight: 72,
                itemBuilder: (context, index) {
                  final porul = filtered[index];
                  return Consumer(
                    builder: (context, ref, _) {
                      final isSelecting = ref.watch(porulSelectionModeProvider);
                      final isSelected = ref.watch(
                        selectedPorulIdsProvider.select((ids) => ids.contains(porul.id)),
                      );
                      return _CooliePorulCard(
                        index: index,
                        porul: porul,
                        primaryLang: primaryLang,
                        secondaryLang: secondaryLang,
                        isDark: isDark,
                        isSelecting: isSelecting,
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelecting) {
                            final currentIds = ref.read(selectedPorulIdsProvider);
                            _toggleSelection(ref, porul.id, currentIds);
                          } else {
                            NirilNav.push(
                              context,
                              CoolieItemEditor(product: porul),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!isSelecting) {
                            // Enter selection mode + select this item
                            ref.read(porulSelectionModeProvider.notifier).state =
                                true;
                            ref.read(selectedPorulIdsProvider.notifier).state = {
                              porul.id
                            };
                          }
                        },
                      );
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

    // Auto-exit selection mode when nothing selected
    if (updated.isEmpty) {
      ref.read(porulSelectionModeProvider.notifier).state = false;
    }
  }

}


// ── Product Card Widget ─────────────────────────────────────────────────────

class _CooliePorulCard extends StatelessWidget {
  const _CooliePorulCard({
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
  final PorulTharavuru porul;
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

    return ElvanPothuAttai(
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      padding: const EdgeInsets.all(16),
      borderRadius: 24.0,
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
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08)),
              ),
              alignment: Alignment.center,
              child: (isSelecting && isSelected)
                  ? Icon(
                      CupertinoIcons.checkmark_alt,
                      size: 16,
                      color: isDark ? Colors.black : Colors.white,
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

            // Product name
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
                ],
              ),
            ),
          ],
        ),
      );
  }
}
