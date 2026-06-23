import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../adippadai/vazhikaattal/niril_nav.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';
import '../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';
import '../thiruthi/niril_kooli_porul_thiruthi.dart';

class CoolieItemsPage extends ConsumerWidget {
  const CoolieItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieItemsSearchQueryProvider).toLowerCase();
    final porulgalAsync = ref.watch(porulgalStreamProvider);
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
          sliver: ElvanResponsiveGrid(
            itemCount: filtered.length,
            desktopCrossAxisCount: 2,
            childAspectRatio: 3.5,
            mobileItemHeight: 72,
            itemBuilder: (context, index) {
              final porul = filtered[index];
              return _CooliePorulCard(
                porul: porul,
                primaryLang: primaryLang,
                secondaryLang: secondaryLang,
                isDark: isDark,
                onTap: () {
                  NirilNav.push(
                    context,
                    CoolieItemEditor(product: porul),
                  );
                },
                onLongPress: () {
                  _showDeleteDialog(context, ref, porul);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, PorulEntry porul) {
    final primaryLang = ref.read(primaryLanguageProvider);
    final name = porul.porulPeyar[primaryLang] ?? '';

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(K.porulAzhikkappattadhu.tr(context, ref)),
        content: Text(name),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(K.illai.tr(context, ref)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(K.neekkuPtn.tr(context, ref)),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(porulKalanjiyamProvider).deletePorul(porul.id);
            },
          ),
        ],
      ),
    );
  }
}

class _CooliePorulCard extends StatelessWidget {
  const _CooliePorulCard({
    required this.porul,
    required this.primaryLang,
    required this.secondaryLang,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  final PorulEntry porul;
  final String primaryLang;
  final String secondaryLang;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final primary = porul.porulPeyar[primaryLang] ?? '';
    final secondary = porul.porulPeyar[secondaryLang] ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                primary,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
