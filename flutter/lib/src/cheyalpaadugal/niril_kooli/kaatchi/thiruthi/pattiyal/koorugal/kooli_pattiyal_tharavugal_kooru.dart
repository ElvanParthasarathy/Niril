import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';

/// §2 Invoice Details — bill number + date picker in
/// responsive layout (side-by-side on desktop, stacked on mobile).
class KooliPattiyalTharavugalKooru extends ConsumerWidget {
  final DateTime pattiyalNaal;
  final ValueChanged<DateTime> onDateChanged;
  final String previewBillNumber;
  final bool isEditing;

  const KooliPattiyalTharavugalKooru({
    super.key,
    required this.pattiyalNaal,
    required this.onDateChanged,
    this.previewBillNumber = '',
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 600;
      final cs = Theme.of(context).colorScheme;
      final tt = Theme.of(context).textTheme;

      // When editing, show the existing bill number as a styled read-only label.
      // When creating, show a hint for the auto-generated number.
      final billField = isEditing && previewBillNumber.isNotEmpty
          ? InputDecorator(
              decoration: InputDecoration(
                labelText: K.pattiyalKuriyeedu.tr(context, ref),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
              ),
              child: Text(
                previewBillNumber,
                style: tt.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            )
          : TextField(
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
