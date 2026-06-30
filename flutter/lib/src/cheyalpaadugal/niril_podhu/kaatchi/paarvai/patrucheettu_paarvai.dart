import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../../../adippadai/oru_mozhi/oru_mozhi_vaangunar_udhavi.dart';
import '../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import 'elvan_paarvai_oadu.dart';

class PatrucheettuPaarvai extends ConsumerWidget {
  const PatrucheettuPaarvai({
    super.key,
    required this.patru,
    required this.achuMozhi,
    required this.onEdit,
  });

  final PatrugalTharavuru patru;
  final String achuMozhi;
  final VoidCallback onEdit;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = patru;

    final mudhanmaiPeyar = OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(
      p.vaangunarPeyar.cast<String, dynamic>(), 
      achuMozhi
    );
        

    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = SeluthiVagaiX.fromStored(p.seluthumMurai);

    return ElvanPaarvaiOadu(
      title: '${K.patrucheettu.tr(context, ref)} #${p.patruEn}',
      onEdit: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer & Date Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mudhanmaiPeyar,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),

                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _dateFormat.format(p.patruNaal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (mode != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: mode.badgeColor(isDark).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mode.label(context, ref),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: mode.badgeColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Totals
          Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.green.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.2),
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    K.perumMotham.tr(context, ref),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.green.shade200 : Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(p.thogai),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (p.ullkurippu.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              K.kurippu.tr(context, ref),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                p.ullkurippu,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
