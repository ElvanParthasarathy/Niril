import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../../../adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';

import '../../../../adippadai/oru_mozhi/oru_mozhi_vaangunar_udhavi.dart';

/// Pixel-perfect port of React's ElvanCard + renderRecentItem for Kooli mode.
/// Shows: index circle + customer name (primary + secondary) + invoice # + date + oor + amount.
class KooliMugappuAttai extends ConsumerStatefulWidget {
  const KooliMugappuAttai({
    super.key,
    required this.index,
    required this.pattiyal,
    required this.onTap,
  });

  final int index;
  final PattiyalTharavuru pattiyal;
  final VoidCallback onTap;

  @override
  ConsumerState<KooliMugappuAttai> createState() => _KooliMugappuAttaiState();
}

class _KooliMugappuAttaiState extends ConsumerState<KooliMugappuAttai> {
  bool _isPressed = false;
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.pattiyal;
    final amountStr = _currencyFormat.format(p.mothaThogai);

    final kooliAchuMozhi = ref.watch(kooliAchuMozhiProvider);
    
    final mudhanmaiPeyar = OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(
      p.vaangunarPeyar.cast<String, dynamic>(), 
      kooliAchuMozhi
    );
    final thunaiPeyar = OruMozhiVaangunarUdhavi.thunaiPeyarFromMap(
      p.vaangunarPeyar.cast<String, dynamic>(), 
      kooliAchuMozhi
    );
    final showThunai = thunaiPeyar.isNotEmpty && thunaiPeyar != mudhanmaiPeyar;
    
    final mudhanmaiOor = OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(
      p.vaangunarMunvari.cast<String, dynamic>(), 
      kooliAchuMozhi
    );

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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mudhanmaiPeyar.isNotEmpty ? mudhanmaiPeyar : '-',
                                      style: const TextStyle(
                                        fontSize: 16.8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (showThunai) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        thunaiPeyar,
                                        style: TextStyle(
                                          fontSize: 13.6,
                                          color: isDark ? Colors.white54 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ],
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  mudhanmaiOor,
                                  style: TextStyle(
                                    fontSize: 13.6,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                                Text(
                                  amountStr,
                                  style: TextStyle(
                                    fontSize: amountStr.length > 11 ? 12.0 : 14.4,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                            ],
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
