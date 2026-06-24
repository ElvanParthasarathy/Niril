import 'package:flutter/material.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';

/// கழிவு கூறு — Global Discount row with a text field and
/// percentage / amount toggle (SegmentedButton).
class PattuKazhivuKooru extends StatelessWidget {
  const PattuKazhivuKooru({
    super.key,
    required this.controller,
    required this.discountType,
    required this.onValueChanged,
    required this.onTypeChanged,
  });

  /// Controller for the discount value text field.
  final TextEditingController controller;

  /// Current discount mode — `'percentage'` or `'amount'`.
  final String discountType;

  /// Fires when the user edits the discount value text.
  final ValueChanged<String> onValueChanged;

  /// Fires when the user toggles between percentage and amount.
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return ElvanThiruthiAttai(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Global Discount',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: onValueChanged,
            ),
          ),
          const SizedBox(width: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'percentage', label: Text('%')),
              ButtonSegment(value: 'amount', label: Text('₹')),
            ],
            selected: {discountType},
            onSelectionChanged: (s) => onTypeChanged(s.first),
          ),
        ],
      ),
    );
  }
}
