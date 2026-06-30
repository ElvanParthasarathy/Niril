import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';

// ── Stats Card (Bento Grid Item) ────────────────────────────────────────────

/// A flat, monochrome stats card matching React's MugappuLayout design.
/// Used in the bento grid on the home screen.
class ElvanStatsCard extends StatelessWidget {
  const ElvanStatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 160;
              final cardPadding = isNarrow ? 16.0 : 20.0;

              final iconBox = Container(
                width: isNarrow ? 40 : 48,
                height: isNarrow ? 40 : 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
                ),
                child: Icon(icon, size: isNarrow ? 20 : 24,
                    color: isDark ? Colors.white : Colors.black),
              );

              final textContent = Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isNarrow ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isLoading)
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    else
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: isNarrow
                              ? _adaptiveFontSize(value) * 0.8
                              : _adaptiveFontSize(value),
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                  ],
                ),
              );

              // Column layout on narrow mobile, Row on wider screens
              if (isNarrow) {
                return Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      iconBox,
                      const SizedBox(height: 8),
                      textContent,
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const SizedBox(width: 16),
                    textContent,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Adaptive font size based on value length (matches React logic)
  double _adaptiveFontSize(String val) {
    if (val.length > 14) return 15;
    if (val.length > 11) return 18;
    return 24;
  }
}

// ── Recent Activity Header ──────────────────────────────────────────────────

class RecentActivityHeader extends StatelessWidget {
  const RecentActivityHeader({
    super.key,
    required this.onSeeAll,
  });

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer(
            builder: (context, ref, _) => Text(
              K.arugilSeyalgal.tr(context, ref),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, _) => GestureDetector(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    K.anaiththaiyumPaarPtn.tr(context, ref),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Invoice Card ─────────────────────────────────────────────────────

/// Pixel-perfect port of React's ElvanCard + renderRecentItem.
/// Shows: index circle + customer name + invoice # + date + amount.
class ElvanRecentCard extends ConsumerStatefulWidget {
  const ElvanRecentCard({
    super.key,
    required this.index,
    required this.pattiyal,
    required this.onTap,
  });

  final int index;
  final PattiyalTharavuru pattiyal;
  final VoidCallback onTap;

  @override
  ConsumerState<ElvanRecentCard> createState() => _ElvanRecentCardState();
}

class _ElvanRecentCardState extends ConsumerState<ElvanRecentCard> {
  bool _isPressed = false;
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.pattiyal;
    final amountStr = _currencyFormat.format(p.mothaThogai);
    
    final currentLocale = ref.watch(localeProvider);
    final effectiveLang = currentLocale?.languageCode ?? Localizations.localeOf(context).languageCode;
    
    String primaryLang;
    String secondaryLang;

    if (p.seyaliVagai == 'coolie') {
      final kooliAchuMozhi = ref.watch(kooliAchuMozhiProvider);
      primaryLang = kooliAchuMozhi;
      secondaryLang = kooliAchuMozhi == 'Tamil' ? 'English' : 'Tamil';
    } else {
      primaryLang = effectiveLang == 'ta' ? 'Tamil' : 'English';
      secondaryLang = effectiveLang == 'ta' ? 'English' : 'Tamil';
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1.0,
        duration: _isPressed
            ? const Duration(milliseconds: 100)
            : const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Index circle
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (widget.index + 1).toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 11.2,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row 1: Customer name + chevron
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.vaangunarPeyar[primaryLang]?.isNotEmpty == true
                                      ? p.vaangunarPeyar[primaryLang]!
                                      : p.vaangunarPeyar[secondaryLang] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 15.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_right,
                                size: 18,
                                color: isDark
                                    ? const Color(0xFF555555)
                                    : const Color(0xFFAAAAAA),
                              ),
                            ],
                          ),
                          // Row 2: Invoice # + Date
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: p.patrucheettuEn),
                                TextSpan(
                                  text: '  •  ',
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.4),
                                  ),
                                ),
                                TextSpan(
                                    text:
                                        _dateFormat.format(p.pattiyalNaal)),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 13.6,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Row 3: Amount (right-aligned)
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              amountStr,
                              style: TextStyle(
                                fontSize:
                                    amountStr.length > 11 ? 12.8 : 15.2,
                                fontWeight: FontWeight.w800,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class MugappuEmptyState extends StatelessWidget {
  const MugappuEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 48,
              color: isDark
                  ? Colors.white24
                  : Colors.black26,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) => Text(
                K.pattiyalgalIllai.tr(context, ref),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Skeleton ────────────────────────────────────────────────────────

class MugappuLoadingSkeleton extends StatelessWidget {
  const MugappuLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
               color: isDark
                  ? const Color(0xFF111111)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                // Circle skeleton
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Text skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 180,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Amount skeleton
                Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
