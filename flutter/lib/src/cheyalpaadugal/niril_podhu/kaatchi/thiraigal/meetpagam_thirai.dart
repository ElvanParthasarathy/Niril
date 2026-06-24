import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../kalanjiyam/porul_nilaimai.dart';
import '../../kalanjiyam/vanigar_nilaimai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MEETPAGAM — Recycle Bin Screen
// ─────────────────────────────────────────────────────────────────────────────
// Mode-aware: shows deleted items for the current mode (Coolie / Silk).
// Currently supports: Products (Porul).
// Future: Merchants (Vanigar), Invoices (Pattiyal), Receipts (Patrucheettu).

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
      ref.read(vanigarKalanjiyamProvider).purgeExpiredVanigargal(days: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deletedPorulgalAsync = ref.watch(deletedPorulgalStreamProvider);
    final deletedVanigargalAsync = ref.watch(deletedVanigargalStreamProvider);
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
          final deletedVanigargal =
              deletedVanigargalAsync.value ?? [];

          if (deletedPorulgal.isEmpty && deletedVanigargal.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ── 30-day auto-delete info ──
              _AutoDeleteBanner(isDark: isDark),
              const SizedBox(height: 12),

              // ── Section: Deleted Products ──
              if (deletedPorulgal.isNotEmpty) ...[
                _SectionHeader(
                  title: K.azhikkappattaPorulgal.tr(context, ref),
                  count: deletedPorulgal.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...deletedPorulgal.map(
                  (porul) => _DeletedPorulCard(
                    porul: porul,
                    primaryLang: primaryLang,
                    secondaryLang: secondaryLang,
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
              if (deletedVanigargal.isNotEmpty) ...[
                _SectionHeader(
                  title: K.azhikkappattaVanigargal.tr(context, ref),
                  count: deletedVanigargal.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...deletedVanigargal.map(
                  (vanigar) => _DeletedVanigarCard(
                    vanigar: vanigar,
                    primaryLang: primaryLang,
                    secondaryLang: secondaryLang,
                    isDark: isDark,
                    onRestore: () =>
                        _restoreVanigar(context, ref, vanigar),
                    onPermanentDelete: () =>
                        _permanentDeleteVanigar(context, ref, vanigar),
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
      },
    );
  }

  void _restoreVanigar(
      BuildContext context, WidgetRef ref, VanigarEntry vanigar) {
    ref.read(vanigarKalanjiyamProvider).restoreVanigar(vanigar.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(K.meeteduppuVetri.tr(context, ref)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _permanentDeleteVanigar(
      BuildContext context, WidgetRef ref, VanigarEntry vanigar) {
    showElvanActionSheet(
      context: context,
      title: K.nirandharaAzhippuUrudhi.tr(context, ref),
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.neekkuPtn.tr(context, ref),
      confirmColor: Colors.red,
      onConfirm: () {
        ref.read(vanigarKalanjiyamProvider).permanentDeleteVanigar(vanigar.id);
      },
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.trash,
            size: 56,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) => Text(
              K.meetpagamKaaliyanadhu.tr(context, ref),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
  });

  final String title;
  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Deleted Product Card ────────────────────────────────────────────────────

class _DeletedPorulCard extends StatelessWidget {
  const _DeletedPorulCard({
    required this.porul,
    required this.primaryLang,
    required this.secondaryLang,
    required this.isDark,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  final PorulEntry porul;
  final String primaryLang;
  final String secondaryLang;
  final bool isDark;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  @override
  Widget build(BuildContext context) {
    final primary = porul.porulPeyar[primaryLang] ?? '';
    final secondary = porul.porulPeyar[secondaryLang] ?? '';
    final deletedAt = porul.deletedAt;
    final timeAgo = deletedAt != null ? _formatTimeAgo(deletedAt) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Deleted icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.cube_box,
                size: 20,
                color: Colors.red.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.black54,
                      decoration: TextDecoration.lineThrough,
                      decorationColor:
                          isDark ? Colors.white24 : Colors.black26,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary.isNotEmpty)
                    Text(
                      secondary,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (timeAgo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            const SizedBox(width: 8),

            // Restore button
            GestureDetector(
              onTap: onRestore,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.arrow_counterclockwise,
                  size: 18,
                  color: Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Permanent delete button
            GestureDetector(
              onTap: onPermanentDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: Colors.red.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// ── Deleted Merchant Card ───────────────────────────────────────────────────

class _DeletedVanigarCard extends StatelessWidget {
  const _DeletedVanigarCard({
    required this.vanigar,
    required this.primaryLang,
    required this.secondaryLang,
    required this.isDark,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  final VanigarEntry vanigar;
  final String primaryLang;
  final String secondaryLang;
  final bool isDark;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  @override
  Widget build(BuildContext context) {
    final primary = vanigar.peyar[primaryLang] ?? '';
    final secondary = vanigar.peyar[secondaryLang] ?? '';
    final deletedAt = vanigar.deletedAt;
    final timeAgo = deletedAt != null ? _formatTimeAgo(deletedAt) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Deleted icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.person,
                size: 20,
                color: Colors.red.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),

            // Merchant details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.black54,
                      decoration: TextDecoration.lineThrough,
                      decorationColor:
                          isDark ? Colors.white24 : Colors.black26,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary.isNotEmpty)
                    Text(
                      secondary,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (timeAgo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            const SizedBox(width: 8),

            // Restore button
            GestureDetector(
              onTap: onRestore,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.arrow_counterclockwise,
                  size: 18,
                  color: Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Permanent delete button
            GestureDetector(
              onTap: onPermanentDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: Colors.red.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// ── 30-Day Auto-Delete Banner ───────────────────────────────────────────────

class _AutoDeleteBanner extends ConsumerWidget {
  const _AutoDeleteBanner({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.06)
            : Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 16,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              K.meetpagam30Naal.tr(context, ref),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
