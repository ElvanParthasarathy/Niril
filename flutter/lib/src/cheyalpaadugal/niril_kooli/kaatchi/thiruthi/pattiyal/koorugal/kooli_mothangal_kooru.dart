import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import 'kooli_thiruthi_udhavigal.dart';

/// §5 Totals — sub-totals, weight, setharam, ahimsa, courier, other charges,
/// grand total.
class KooliMothangalKooru extends StatelessWidget {
  final KooliMothangal totals;
  final double setharamGrams;
  final double ahimsaPattuThogai;
  final double thapaalThogai;
  final List<PiraVarivu> piraVarivugal;
  final NumberFormat formatter;

  const KooliMothangalKooru({
    super.key,
    required this.totals,
    required this.setharamGrams,
    required this.ahimsaPattuThogai,
    required this.thapaalThogai,
    required this.piraVarivugal,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElvanThiruthiAttai(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            kooliTotalsRow(
              'Sub Total',
              '₹${formatter.format(totals.adippadaiMothangal)}',
              labelWeight: FontWeight.w600,
              labelColor: cs.onSurfaceVariant,
              valueWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),
            if (ahimsaPattuThogai > 0) ...[
              kooliTotalsRow('Ahimsa Silk',
                  '₹${formatter.format(ahimsaPattuThogai)}'),
              const SizedBox(height: 12),
            ],
            if (thapaalThogai > 0) ...[
              kooliTotalsRow(
                  'Courier', '₹${formatter.format(thapaalThogai)}'),
              const SizedBox(height: 12),
            ],
            for (final charge in piraVarivugal)
              if (charge.thogai > 0) ...[
                kooliTotalsRow(
                  charge.peyar.isNotEmpty ? charge.peyar : 'Other',
                  '₹${formatter.format(charge.thogai)}',
                ),
                const SizedBox(height: 12),
              ],
            kooliTotalsRow(
              'Total Weight',
              '${totals.mothaEdai.toStringAsFixed(3)} Kg',
              labelWeight: FontWeight.w600,
              valueWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),
            if (setharamGrams > 0) ...[
              kooliTotalsRow(
                  '+ Setharam', '${setharamGrams.toStringAsFixed(1)} g'),
              const SizedBox(height: 12),
            ],
            const Divider(),
            const SizedBox(height: 12),
            // Grand Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    )),
                Text(
                  '₹${formatter.format(totals.perumMothangal)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
