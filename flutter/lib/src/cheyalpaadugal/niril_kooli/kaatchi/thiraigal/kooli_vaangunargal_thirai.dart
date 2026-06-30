import 'package:elvan_niril/src/adippadai/nilaimai/achu_mozhi_facade.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/vazhikaattal/niril_nav.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import '../thiruthi/vaangunar/niril_kooli_vaangunar_thiruthi.dart';

class CoolieMerchantsPage extends ConsumerWidget {
  const CoolieMerchantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieMerchantsSearchQueryProvider).toLowerCase();
    final vaangunargalAsync = ref.watch(vaangunargalProvider);
    final primaryLang = ref.watch(primaryLanguageProvider);
    final secondaryLang = ref.watch(secondaryLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = ref.watch(vaangunarSelectionModeProvider);
    final selectedIds = ref.watch(selectedVaangunarIdsProvider);

    return vaangunargalAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (vaangunargal) {
        // Filter by search query (name + city)
        final filtered = query.isEmpty
            ? vaangunargal
            : vaangunargal.where((v) {
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
                  SvgPicture.string(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256"><path d="M117.25,157.92a60,60,0,1,0-66.5,0A95.83,95.83,0,0,0,3.53,195.63a8,8,0,1,0,13.4,8.74,80,80,0,0,1,134.14,0,8,8,0,0,0,13.4-8.74A95.83,95.83,0,0,0,117.25,157.92ZM40,108a44,44,0,1,1,44,44A44.05,44.05,0,0,1,40,108Zm210.14,98.7a8,8,0,0,1-11.07-2.33A79.83,79.83,0,0,0,172,168a8,8,0,0,1,0-16,44,44,0,1,0-16.34-84.87,8,8,0,1,1-5.94-14.85,60,60,0,0,1,55.53,105.64,95.83,95.83,0,0,1,47.22,37.71A8,8,0,0,1,250.14,206.7Z"></path></svg>',
                    width: 48,
                    height: 48,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white24 : Colors.black26,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    K.vaangunargalIllai.tr(context, ref),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    K.vaangunaraiChaerkkavum.tr(context, ref),
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

              // ── Merchant Grid ──
              ElvanResponsiveGrid(
                itemCount: filtered.length,
                desktopCrossAxisCount: 2,
                childAspectRatio: 3.5,
                mobileItemHeight: 80,
                itemBuilder: (context, index) {
                  final vaangunar = filtered[index];
                  final isSelected = selectedIds.contains(vaangunar.id);

                  return _CoolieVaangunarCard(
                    index: index,
                    vaangunar: vaangunar,
                    primaryLang: primaryLang,
                    secondaryLang: secondaryLang,
                    isDark: isDark,
                    isSelecting: isSelecting,
                    isSelected: isSelected,
                    onTap: () {
                      if (isSelecting) {
                        _toggleSelection(ref, vaangunar.id, selectedIds);
                      } else {
                        NirilNav.push(
                          context,
                          CoolieMerchantEditor(vaangunar: vaangunar),
                        );
                      }
                    },
                    onLongPress: () {
                      if (!isSelecting) {
                        ref.read(vaangunarSelectionModeProvider.notifier).state =
                            true;
                        ref.read(selectedVaangunarIdsProvider.notifier).state = {
                          vaangunar.id
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
    ref.read(selectedVaangunarIdsProvider.notifier).state = updated;

    if (updated.isEmpty) {
      ref.read(vaangunarSelectionModeProvider.notifier).state = false;
    }
  }

}


// ── Coolie Merchant Card ────────────────────────────────────────────────────

class _CoolieVaangunarCard extends StatelessWidget {
  const _CoolieVaangunarCard({
    required this.index,
    required this.vaangunar,
    required this.primaryLang,
    required this.secondaryLang,
    required this.isDark,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final int index;
  final VaangunarTharavuru vaangunar;
  final String primaryLang;
  final String secondaryLang;
  final bool isDark;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final primaryName = vaangunar.peyar[primaryLang] ?? '';
    final secondaryName = vaangunar.peyar[secondaryLang] ?? '';
    final primaryCity = vaangunar.oor[primaryLang] ?? '';
    final secondaryCity = vaangunar.oor[secondaryLang] ?? '';

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
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryName,
                    style: const TextStyle(
                      fontSize: 15.2,
                      fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (primaryCity.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      primaryCity,
                      style: TextStyle(
                        fontSize: 13.6,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (secondaryCity.isNotEmpty &&
                      secondaryCity != primaryCity) ...[
                    const SizedBox(height: 2),
                    Text(
                      secondaryCity,
                      style: TextStyle(
                        fontSize: 12.8,
                        color: (isDark ? Colors.white30 : Colors.black.withValues(alpha: 0.30))
                            .withValues(alpha: 0.8),
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
      ),
    );
  }
}
