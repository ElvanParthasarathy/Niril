import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../kalanjiyam/porul_nilaimai.dart';
import '../../kalanjiyam/vaangunar_nilaimai.dart';
import 'koorugal/meetpagam_koorugal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MEETPAGAM — Recycle Bin Screen
// ─────────────────────────────────────────────────────────────────────────────
// Mode-aware: shows deleted items for the current mode (Coolie / Silk).
// Currently supports: Products (Porul).
// Future: Merchants (Vaangunar), Invoices (Pattiyal), Receipts (Patrucheettu).

class MeetpagamThirai extends ConsumerStatefulWidget {
  const MeetpagamThirai({super.key});

  @override
  ConsumerState<MeetpagamThirai> createState() => _MeetpagamThiraiState();
}

class _MeetpagamThiraiState extends ConsumerState<MeetpagamThirai> {
  @override
  void initState() {
    super.initState();
    // Auto-purge items older than 30 days on screen open
    Future.microtask(() {
      ref.read(porulKalanjiyamProvider).purgeExpiredPorulgal(days: 30);
      ref.read(vaangunarKalanjiyamProvider).purgeExpiredVaangunargal(days: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deletedPorulgalAsync = ref.watch(deletedPorulgalProvider);
    final deletedVaangunargalAsync = ref.watch(deletedVaangunargalProvider);
    final primaryLang = ref.watch(primaryLanguageProvider);
    final secondaryLang = ref.watch(secondaryLanguageProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          K.meetpagam.tr(context, ref),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: deletedPorulgalAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (deletedPorulgal) {
          final deletedVaangunargal =
              deletedVaangunargalAsync.value ?? [];

          if (deletedPorulgal.isEmpty && deletedVaangunargal.isEmpty) {
            return MeetpagamVeliNilai(isDark: isDark);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ── 30-day auto-delete info ──
              MeetpagamThanniyakkaNaattam(isDark: isDark),
              const SizedBox(height: 12),

              // ── Section: Deleted Products ──
              if (deletedPorulgal.isNotEmpty) ...[
                MeetpagamPaguthiThalaipu(
                  title: K.azhikkappattaPorulgal.tr(context, ref),
                  count: deletedPorulgal.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...deletedPorulgal.map(
                  (porul) => MeetpagamAzhippuAttai(
                    primaryText: porul.porulPeyar[primaryLang] ?? '',
                    secondaryText: porul.porulPeyar[secondaryLang] ?? '',
                    icon: CupertinoIcons.cube_box,
                    deletedAt: porul.deletedAt,
                    isDark: isDark,
                    onRestore: () =>
                        _restorePorul(context, ref, porul),
                    onPermanentDelete: () =>
                        _permanentDeletePorul(context, ref, porul),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Section: Deleted Merchants ──
              if (deletedVaangunargal.isNotEmpty) ...[
                MeetpagamPaguthiThalaipu(
                  title: K.azhikkappattaVaangunargal.tr(context, ref),
                  count: deletedVaangunargal.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...deletedVaangunargal.map(
                  (vaangunar) => MeetpagamAzhippuAttai(
                    primaryText: vaangunar.peyar[primaryLang] ?? '',
                    secondaryText: vaangunar.peyar[secondaryLang] ?? '',
                    icon: CupertinoIcons.person,
                    deletedAt: vaangunar.deletedAt,
                    isDark: isDark,
                    onRestore: () =>
                        _restoreVaangunar(context, ref, vaangunar),
                    onPermanentDelete: () =>
                        _permanentDeleteVaangunar(context, ref, vaangunar),
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  void _restorePorul(
      BuildContext context, WidgetRef ref, PorulEntry porul) {
    ref.read(porulKalanjiyamProvider).restorePorul(porul.id);
    ref.invalidate(porulgalProvider);
    ref.invalidate(deletedPorulgalProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(K.meeteduppuVetri.tr(context, ref)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _permanentDeletePorul(
      BuildContext context, WidgetRef ref, PorulEntry porul) {
    showElvanActionSheet(
      context: context,
      title: K.nirandharaAzhippuUrudhi.tr(context, ref),
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(porulKalanjiyamProvider).permanentDeletePorul(porul.id);
        ref.invalidate(deletedPorulgalProvider);
      },
    );
  }

  void _restoreVaangunar(
      BuildContext context, WidgetRef ref, VaangunarEntry vaangunar) {
    ref.read(vaangunarKalanjiyamProvider).restoreVaangunar(vaangunar.id);
    ref.invalidate(vaangunargalProvider);
    ref.invalidate(deletedVaangunargalProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(K.meeteduppuVetri.tr(context, ref)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _permanentDeleteVaangunar(
      BuildContext context, WidgetRef ref, VaangunarEntry vaangunar) {
    showElvanActionSheet(
      context: context,
      title: K.nirandharaAzhippuUrudhi.tr(context, ref),
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(vaangunarKalanjiyamProvider).permanentDeleteVaangunar(vaangunar.id);
        ref.invalidate(deletedVaangunargalProvider);
      },
    );
  }
}
