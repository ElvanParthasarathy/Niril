import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';

/// §2 Invoice Details — read-only bill number + date picker in
/// responsive layout (side-by-side on desktop, stacked on mobile).
class KooliPattiyalTharavugalKooru extends ConsumerWidget {
  final DateTime pattiyalNaal;
  final ValueChanged<DateTime> onDateChanged;
  final String previewBillNumber;

  const KooliPattiyalTharavugalKooru({
    super.key,
    required this.pattiyalNaal,
    required this.onDateChanged,
    this.previewBillNumber = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 600;
      final billField = TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: K.pattiyalKuriyeedu.tr(context, ref),
          hintText: previewBillNumber.isNotEmpty
              ? previewBillNumber
              : K.thaaniyangki.tr(context, ref),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      );
      final dateField = PattiyalNaalKooru(
        selectedDate: pattiyalNaal,
        onDateChanged: onDateChanged,
      );

      if (isDesktop) {
        return Row(
          children: [
            Expanded(child: billField),
            const SizedBox(width: 16),
            dateField,
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          billField,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: dateField),
        ],
      );
    });
  }
}
