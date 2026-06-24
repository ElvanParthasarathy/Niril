import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';

/// Displays invoice totals — subtotal, discount, taxes, round off, and grand total.
class PattuMothangalKooru extends StatelessWidget {
  const PattuMothangalKooru({super.key, required this.totals});

  final PattuMothangal totals;

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 24),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '4',
                  style: TextStyle(
                    color: cs.surface,
                    fontSize: 12.8,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Totals',
                style: TextStyle(
                  fontSize: 17.6,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ElvanThiruthiAttai(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _totalsRow('Subtotal', totals.adippadaiMothangal, cs, tt),
                if (totals.thallupadiMothangal > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('Discount', -totals.thallupadiMothangal, cs, tt,
                      color: Colors.red),
                ],
                if (totals.cgst > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('CGST', totals.cgst, cs, tt),
                ],
                if (totals.sgst > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('SGST', totals.sgst, cs, tt),
                ],
                if (totals.igst > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('IGST', totals.igst, cs, tt),
                ],
                if (totals.suttruOff != 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('Round Off', totals.suttruOff, cs, tt),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: cs.outlineVariant),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total',
                        style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    Text(_inrFormat.format(totals.mothaMothangal),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: cs.primary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalsRow(
      String label, double amount, ColorScheme cs, TextTheme tt,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        Text(_inrFormat.format(amount),
            style: tt.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500, color: color ?? cs.onSurface)),
      ],
    );
  }
}
