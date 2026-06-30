import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

/// Pixel-perfect port of React's ElvanCard + renderRecentItem for Silk mode.
/// Shows: index circle + customer name + invoice # + date + amount.
class PattuMugappuAttai extends ConsumerStatefulWidget {
  const PattuMugappuAttai({
    super.key,
    required this.index,
    required this.pattiyal,
    required this.onTap,
  });

  final int index;
  final PattiyalTharavuru pattiyal;
  final VoidCallback onTap;

  @override
  ConsumerState<PattuMugappuAttai> createState() => _PattuMugappuAttaiState();
}

class _PattuMugappuAttaiState extends ConsumerState<PattuMugappuAttai> {
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
    final effectiveLang =
        currentLocale?.languageCode ?? Localizations.localeOf(context).languageCode;

    final primaryLang = effectiveLang == 'ta' ? 'Tamil' : 'English';
    final secondaryLang = effectiveLang == 'ta' ? 'English' : 'Tamil';

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
                                    color: (isDark ? Colors.white : Colors.black)
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                TextSpan(text: _dateFormat.format(p.pattiyalNaal)),
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
                                fontSize: amountStr.length > 11 ? 12.8 : 15.2,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
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
