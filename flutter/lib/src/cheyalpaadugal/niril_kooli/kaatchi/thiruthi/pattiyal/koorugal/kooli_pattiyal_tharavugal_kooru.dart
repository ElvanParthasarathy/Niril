import 'package:flutter/material.dart';

import '../../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';

/// §2 Invoice Details — read-only bill number + date picker in
/// responsive layout (side-by-side on desktop, stacked on mobile).
class KooliPattiyalTharavugalKooru extends StatelessWidget {
  final DateTime pattiyalNaal;
  final ValueChanged<DateTime> onDateChanged;

  const KooliPattiyalTharavugalKooru({
    super.key,
    required this.pattiyalNaal,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 600;
      final billField = TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Bill No.',
          hintText: 'Auto-generated',
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
