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
import '../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import '../thiruthi/vaangunar/niril_pattu_vaangunar_thiruthi.dart';

class SilkMerchantsPage extends ConsumerWidget {
  const SilkMerchantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(silkMerchantsSearchQueryProvider).toLowerCase();
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
        // Filter by search query (name, city, gstin, phone, email)
        final filtered = query.isEmpty
            ? vaangunargal
            : vaangunargal.where((v) {
                final pName = (v.peyar[primaryLang] ?? '').toLowerCase();
                final sName = (v.peyar[secondaryLang] ?? '').toLowerCase();
                final pCity = (v.oor[primaryLang] ?? '').toLowerCase();
                final gstin = v.gstin.toLowerCase();
                final phone = v.tholaipaesi.toLowerCase();
                final email = v.minnanjal.toLowerCase();
                return pName.contains(query) ||
                    sName.contains(query) ||
                    pCity.contains(query) ||
                    gstin.contains(query) ||
                    phone.contains(query) ||
                    email.contains(query);
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
              // ── Selection Bar ──
              if (isSelecting)
                SliverToBoxAdapter(
                  child: _SelectionBar(
                    selectedCount: selectedIds.length,
                    isDark: isDark,
                    onSelectAll: () {
                      ref.read(selectedVaangunarIdsProvider.notifier).state =
                          filtered.map((v) => v.id).toSet();
                    },
                    onDelete: () {
                      _showBulkDeleteConfirm(
                          context, ref, selectedIds.toList());
                    },
                    onCancel: () {
                      ref.read(vaangunarSelectionModeProvider.notifier).state =
                          false;
                      ref.read(selectedVaangunarIdsProvider.notifier).state = {};
                    },
                  ),
                ),

              // ── Merchant Grid ──
              ElvanResponsiveGrid(
                itemCount: filtered.length,
                desktopCrossAxisCount: 2,
                childAspectRatio: 2.8,
                mobileItemHeight: 100,
                itemBuilder: (context, index) {
                  final vaangunar = filtered[index];
                  final isSelected = selectedIds.contains(vaangunar.id);

                  return _SilkVaangunarCard(
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
                          SilkMerchantEditor(vaangunar: vaangunar),
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

  void _showBulkDeleteConfirm(
      BuildContext context, WidgetRef ref, List<int> ids) {
    if (ids.isEmpty) return;

    showElvanActionSheet(
      context: context,
      title: '${ids.length} ${K.vaangunarAzhikkappattadhu.tr(context, ref)}',
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(vaangunarKalanjiyamProvider).bulkDeleteVaangunargal(ids);
        ref.invalidate(vaangunargalProvider);
        ref.read(vaangunarSelectionModeProvider.notifier).state = false;
        ref.read(selectedVaangunarIdsProvider.notifier).state = {};
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

// ── Silk Merchant Card ──────────────────────────────────────────────────────

class _SilkVaangunarCard extends StatelessWidget {
  const _SilkVaangunarCard({
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
  final VaangunarEntry vaangunar;
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
    final gstin = vaangunar.gstin;
    final phone = vaangunar.tholaipaesi;

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
                  if (gstin.isNotEmpty || phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [if (gstin.isNotEmpty) gstin, if (phone.isNotEmpty) phone]
                          .join(' · '),
                      style: TextStyle(
                        fontSize: 13.6,
                        color: isDark ? Colors.white38 : Colors.black38,
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
